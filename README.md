# AdaptiveCoordinator

AdaptiveCoordinator is a navigation library for mixed use of UIKit and SwiftUI.
[Chinese Documentation](README.cn.md)

- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)

Basic Usage
---

First, you need to create an enumeration that includes all nodes that can be reached from the current node, as well as the current node itself. Typically, these nodes represent either a `UIViewController` or a `SwiftUI` view wrapped by `UIHostingController`.

We define the root node as the current node, which represents the view that the `Coordinator` will display upon its initial appearance.

In the following example, we use the `ColorListRoute` enumeration to represent all nodes that can be reached from the `list` root node with just one view transition:

```swift
enum ColorListRoute: Route {
  // root
  case list
  case color(String)
  case settings
  case info
}
```

In this example, `list` is the root node. From here, we can navigate to a specific `color` node, the `settings` node, or the `info` node. We can also utilize the associated values of the enumeration to pass information required during the view transition.

Next, based on the required navigation controller type, create the corresponding `Coordinator` subclass and implement it. Here, taking `StackCoordinator` as an example, we create a `ColorListCoordinator` for the `ColorListRoute`:

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

When initializing the `Coordinator`, if it is the root `Coordinator`, you need to create a corresponding `BasicViewControllerType` instance. Then, override the `prepare` method, instructing the framework how to handle the given route. For simple navigations, simply return `.transfer(<TransferType>)`.

The associated value of the transfer type represents the specific navigation method:

- `push` corresponds to `navigationController.pushViewController`
- `pop` corresponds to `navigationController.popViewController`
- `present` corresponds to `navigationController.present`
- `dismiss` corresponds to `navigationController.dismiss`
- `set` sets the view controller stack of the `navigationController`. Use this with caution as it might clear view controllers not belonging to the current `Coordinator`
- `backToRoot` safely navigates back to the root node
- `handover` indicates that you've handed over the control of the `baseViewController` to another `Coordinator`. It's recommended to use this method when navigating to non-leaf nodes.

How do you use the `Coordinator`? When in use, the view controller or `SwiftUI` view doesn't need to know most of the details about the `Coordinator`. Thus, simply inject a `WeakRouter` or `UnownedRouter` instance to offer basic navigation capabilities.

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

Advanced Usage
---

After mastering the basic functions, we offer a series of advanced tools to enhance your navigation experience.

### `pullback` Method

When an application only needs to display one view at a time, all navigation actions can be viewed as descending or ascending operations on a view tree. You can start from the root node and delve deeper layer by layer until you reach the leaf node. We have introduced how to use basic methods to navigate within a single level of the tree, such as entering a child node or returning to the parent node. However, these basic operations are insufficient when dealing with scenarios involving `UISplitViewController`, or when it is necessary to display and manage multiple view controllers simultaneously.

For this reason, we provide the `pullback` method —— inspired by the highly acclaimed [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). In simple terms, it allows you to listen to events from a child coordinator (`Coordinator`). If a child coordinator cannot handle a given navigation action, the parent coordinator can listen and respond to the action accordingly.

For example, when using `SplitCoordinator` and `SplitViewController`, navigation within the `Primary Column / Master` is handled by a `StackCoordinator`. If a view needs to be displayed in the `Secondary Column / Detail`, and this task cannot be directly managed by the `StackCoordinator` in the `Primary Column`, we can listen to the `StackCoordinator` events in the `SplitCoordinator` and `transfer` or `handover` them to the `StackCoordinator` located in the `Secondary Column / Detail` for processing.

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
        return .transfer(.dismiss())
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

In the code above, we first define `listRoute` and `detailRoute` in `NewsRoute` to distinguish and convert events during subscription. Then, when creating instances of `NewsListCoordinator` and `NewsDetailCoordinator`, we used the `pullback` method and passed closures to specify how to convert events. Thus, when `NewsListCoordinator` receives an event to navigate to `info` or `detail`, the `NewsCoordinator` will also be notified and processed in the `case let .listRoute(route):` block.