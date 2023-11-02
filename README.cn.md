# AdaptiveCoordinator

AdaptiveCoordinator是一个导航库，用于混合使用UIKit和SwiftUI。

- [基本使用](#基本使用)
- [进阶使用](#进阶使用)

基本使用
---

首先，你需要创建一个枚举，包括当前节点可以抵达的所有节点以及当前节点自身。通常，这些节点背后代表的是一个 `UIViewController`，或者一个由 `UIHostingController` 包装的 `SwiftUI` 视图。

我们定义当前节点为根节点，也就是 `Coordinator` 首次显示时会展示的视图。

以下示例中，我们使用 `ColorListRoute` 这个枚举来表示当 `list` 为根节点时，经过一次视图转换可以抵达的所有节点：

```swift
enum ColorListRoute: Route {
  // root
  case list
  case color(String)
  case settings
  case info
}
```

在上面的示例中，`list` 是根节点。从这个节点，我们可以导航到具体的 `color` 节点，`settings` 节点或 `info` 节点。我们还可以利用枚举的关联值来传递转换视图所需的信息。

接下来，根据需要的导航控制器类型，创建相应的 `Coordinator` 子类并实现它。以下以 `StackCoordinator` 为例，我们会为 `ColorListRoute` 创建一个 `ColorListCoordinator`：

```swift
class ColorListCoordinator: StackCoordinator<ColorListRoute> {
  init(
    basicViewController: StackCoordinator<ColorListRoute>.BasicViewControllerType = .init(),
    initialRoute: ColorListRoute
  ) {
    super.init(
      basicViewController: basicViewController,
      initialRoute: initialRoute
    )
  }
  
  override func prepare(to route: ColorListRoute) -> ActionType<TransferType, ColorListRoute> {
    switch route {
    case .list:
      // If invoked during the coordinator's initialization, instantiate and push `ColorListViewController`.
      // Otherwise, navigate back to the root view controller.
      if isInitial {
        let viewController = ColorListViewController(level: level, unownedRouter)
        return .transfer(.push(viewController))
      } else {
        return .transfer(.backToRoot())
      }
      
    case let .color(str):
      let coordinator = ColorCoordinator(basicViewController: basicViewController, initialRoute: .color(str))
      return .transfer(.handover(coordinator))
      
    case .settings:
      let coordinator = SettingsCoordinator(basicViewController: basicViewController, initialRoute: .list(true))
      return .transfer(.handover(coordinator))
      
    case .info:
      let viewController = InfoViewController(unownedRouter)
      return .transfer(.present(viewController))
    }
  }
}
```

在初始化 `Coordinator` 时，如果它是根 `Coordinator`，你需要创建一个相应的 `BasicViewControllerType` 实例。接着，重写 `prepare` 方法，指示框架对于指定的路由应该如何处理。若只是简单的导航，直接返回 `.transfer(<TransferType>)`。

转移类型的关联值代表具体的导航方式：

- `push` 对应于 `navigationController.pushViewController`
- `pop` 对应于 `navigationController.popViewController`
- `present` 对应于 `navigationController.present`
- `dismiss` 对应于 `navigationController.dismiss`
- `set` 对应于设置 `navigationController` 的视图控制器堆栈，但使用时需谨慎，此操作可能会清除不属于当前 `Coordinator` 的视图控制器
- `backToRoot` 会安全地导航回根节点
- `handover` 表示你已将 `baseViewController` 的控制权交给另一个 `Coordinator`。建议在导航到非叶节点时使用此方式。

如何使用 `Coordinator`？在使用时，视图控制器或 `SwiftUI` 视图不需要知道关于 `Coordinator` 的细节，所以只需注入 `WeakRouter` 或 `UnownedRouter` 实例，为其提供基本的导航功能。

```swift
class ColorListViewController: UIViewController {
  let router: UnownedRouter<ColorListRoute>
  ...
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let color = colors[indexPath.row]
    router.transfer(to: .color(color))
  }
}
```

进阶使用
---

在掌握了基础功能之后，我们还提供了一系列高级工具来优化您的导航体验。

### `pullback` 方法

当应用程序中仅需一次显示一个视图时，所有的导航行为可以被视作在一颗视图树上进行下行或上行操作。您可以从根节点开始，逐层深入直至到达叶节点。我们已经介绍了如何使用基础方法来在树的单一层级中导航，比如进入一个子节点或者返回到父节点。然而，面对涉及 `UISplitViewController` 的场景，或是需要同时展示和管理多个视图控制器的复杂情况，仅仅依赖这些基本操作是不够的。

为此，我们提供了 `pullback` 方法 ———— 这一概念源自于备受赞誉的 [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)。简言之，它允许您监听子协调器（`Coordinator`）的事件。如果某个子协调器无法处理一个给定的导航操作，这个操作可以被父协调器监听并相应地处理。

举例来说，使用 `SplitCoordinator` 和 `SplitViewController` 时，在 `Primary Column / Master` 中通过 `StackCoordinator` 进行导航。如果需要在 `Secondary Column / Detail` 中展示一个视图，而该任务无法由 `Primary Column` 中的 `StackCoordinator` 直接处理，我们就可以在 `SplitCoordinator` 中监听 `StackCoordinator` 的事件，并将它们 `transfer` 或 `handover` 给位于 `Secondary Column / Detail` 中的 `StackCoordinator` 来进行处理。

```swift
enum NewsRoute: Route {
  case list
  case listRoute(NewsListRoute)
  case detailRoute(NewsDetailRoute)
}

class NewsCoordinator: SplitCoordinator<NewsRoute> {
  init( ... ) { ... }
  
  override func prepare(to route: NewsRoute) -> ActionType<SplitTransfer, NewsRoute> {
    switch route {
    case .list:
      if isInitial {
        let coordinator = NewsListCoordinator(basicViewController: basicViewController.primary, initialRoute: .list)
        pullback(subCoordinator: coordinator) {
          .listRoute($0)
        }
        return .transfer(.primary(.handover(coordinator)))
      } else {
        return .transfer(.dimiss())
      }
      
    // Pull-back
      
    case let .listRoute(route):
      switch route {
      case .list:
        return .none
        
      case .info:
        let viewController = NewsInfoViewController(unownedRouter)
        return .transfer(.present(viewController))
        
      case let .detail(str):
        let coordinator = NewsDetailCoordinator(basicViewController: basicViewController.secondary, initialRoute: .detail(str))
        pullback(subCoordinator: coordinator) {
          .detailRoute($0)
        }
        return .transfer(.secondary(.handover(coordinator)))
      }
      
    case let .detailRoute(route):
      switch route {
      case .detail:
        return .none
        
      case .info:
        let viewController = NewsInfoViewController(unownedRouter)
        return .transfer(.present(viewController))
      }
    }
  }
}
```

在上述代码中，我们首先在 `NewsRoute` 中对 `listRoute` 和 `detailRoute` 进行了定义，以便在事件订阅时进行区分并转换。接着，在创建 `NewsListCoordinator` 和 `NewsDetailCoordinator` 的实例时，我们使用了 `pullback` 方法并传递了闭包来指定如何转换事件。这样一来，当 `NewsListCoordinator` 收到跳转到 `info` 或 `detail` 的事件时，`NewsCoordinator` 也会被相应地通知，并在 `case let .listRoute(route):` 块中进行处理。

