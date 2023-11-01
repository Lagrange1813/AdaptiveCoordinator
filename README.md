# AdaptiveCoordinator

Getting Started
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
