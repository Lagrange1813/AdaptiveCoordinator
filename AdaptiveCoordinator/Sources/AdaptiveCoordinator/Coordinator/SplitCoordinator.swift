//
//  SplitCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Combine
import UIKit

open class SplitCoordinator<RouteType: Route>: BaseCoordinator<RouteType, SplitViewController, SplitTransfer> {
  @Published public private(set) var currentRoute: RouteType
  
  public init(basicViewController: BasicViewControllerType = .init(), configure: ((BasicViewControllerType) -> Void)? = nil, initialRoute: RouteType) {
    currentRoute = initialRoute
    super.init(basicViewController: basicViewController, initialRoute: initialRoute)
    configure?(basicViewController)
    addSubscriber()
  }
  
  func addSubscriber() {
    basicViewController
      .didRemoveViewController
      .sink { [unowned self] viewControllers in
        for viewController in viewControllers {
          let idx = children.firstIndex { shouldRemove(child: $0, with: viewController) }
          if let idx {
            children.remove(at: idx)
          }
        }
      }.store(in: &_cancellables)
  }
  
  private var isCollapsed: Bool {
    basicViewController.isCollapsed
  }
  
  open func prepare(to route: RouteType) -> SplitTransfer {
    fatalError("Please override the \(#function) method.")
  }
  
  public override func _prepare(to route: RouteType) -> SplitTransfer {
    let transfer = prepare(to: route)
    currentRoute = route
    return transfer
  }
  
  override public func perform(_ transfer: SplitTransfer) {
    switch transfer {
    case let .primary(transferType),
         let .secondary(transferType),
         let .supplmentary(transferType):
      handle(type: transferType, in: targetStack(of: transfer))
      
    case let .present(viewController, animated):
      basicViewController.present(viewController, animated: animated)
      addChild(viewController)
      
    case let .dimiss(animated):
      basicViewController.dismiss(animated: animated)
      
    case .none:
      break
    }
  }
}

extension SplitCoordinator {
  func targetStack(of transfer: SplitTransfer) -> InternalStackViewController? {
    switch transfer {
    case .primary:
      basicViewController.primary
    case .secondary:
      basicViewController.secondary
    case .supplmentary:
      nil
    case .present, .dimiss, .none:
      nil
    }
  }
  
  func handle(type: SplitTransfer.TransferType, in stack: InternalStackViewController?) {
    switch type {
    case let .push(viewController, animated):
      stack?.push(viewController, animated: animated)
      addChild(viewController)
      
    case let .pop(animated):
      stack?.pop(animated: animated)
      
    case let .set(viewController):
      stack?.set(viewController)
      addChild(viewController)
      
    case .backToRoot:
      break
      
    case let .handover(coordinator):
      addChild(coordinator)
    }
  }
}
