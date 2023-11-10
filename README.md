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

### `drop` Method

Within our framework, we have implemented a basic mechanism for the automatic disposal of `Coordinator` objects that are no longer needed. However, when dealing with complex multilevel structures, relying on this automatic disposal mechanism can pose problems. Therefore, we recommend using the `drop` method to explicitly manage the recycling of the view tree when there is a need to reset a large number of view levels (for example, to remove an entire navigation branch). This method performs a post-order traversal of the view tree, releasing the corresponding view controllers or `UIHostingController` at each level.

```swift
case let .colorRoute(route):
  switch route {
    case .settings:
      drop(animated: false)
      // or use `return prepare(to: .settings)`
      let coordinator = SettingsCoordinator(basicViewController: basicViewController, initialRoute: .list(false))
      return .transfer(.handover(coordinator))
```

For instance, in the code above, we manually invoke the `drop` method to reset the child view nodes of the current `StackCoordinator` before initiating the `SettingsCoordinator` to carry out the subsequent operation. This approach allows us to switch the entire view branch securely and in one go.

### `handle` Method

Complementing the `drop` method, we also provide a `handle` method that enables one-time navigation to a deep-level view, also known as "deeplinking." When you need to navigate to a deep view in one step, you can directly provide the appropriate `route` and `prepare` methods at a higher-level view node to simplify the pushing of the deep view. If you need to build intermediate views at the same time, you can implement the `deeplinkable` protocol at each level and invoke the `handle` method at the top level. Consequently, the framework will construct the respective `Coordinator` layer by layer, based on the provided methods, and recursively call the `handle` method to complete the navigation to the deep view.

### Re-sending

Consider a scenario where we need to navigate recursively to a view, but we want the root view node to handle the navigation request, not the node that first received the event. In such cases, we might consider using `pullback` to subscribe to events from a child `Coordinator`. But what if the hierarchy is not fixed? At this juncture, we can return `.send(<RouteType>)` within the `prepare` method for event re-sending, which is equivalent to the `Coordinator` directly receiving the navigation request for that `RouteType`. By re-sending events, we can transform and recursively propagate navigation requests from non-root view nodes.

```swift
case let .newListRoute(route):
  if case let .colorRoute(colorRoute) = route {
    return .send(.colorRoute(colorRoute))
  }
  return .none
      
case let .colorRoute(route):
  if isRoot {
    switch route {
    case .settings:
      drop(animated: false)
      // or use `return prepare(to: .settings)`
      let coordinator = SettingsCoordinator(basicViewController: basicViewController, initialRoute: .list(false))
      return .transfer(.handover(coordinator))
         
    default:
      return .none
    }
  } else {
    return .none
  }
```

In the code example provided, we can recursively push the `NewsListCoordinator`, subscribing to and processing events from the child `NewsListCoordinator`. Here, we transform the `colorRoute` event from the child `NewsListCoordinator` and re-send it as our own `colorRoute`. This ensures that, regardless of the depth of the hierarchy, we can handle `colorRoute` events from any depth in the root `NewsListCoordinator`.
