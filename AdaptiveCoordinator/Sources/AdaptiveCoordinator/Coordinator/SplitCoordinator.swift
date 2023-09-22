//
//  SplitCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Combine
import UIKit

open class SplitCoordinator<RouteType: Route>: BaseCoordinator<RouteType, SplitViewController, SplitTransfer> {
  public init(basicViewController: BasicViewControllerType = .init(), configure: ((BasicViewControllerType) -> Void)? = nil, initialRoute: RouteType) {
    super.init(basicViewController: basicViewController, initialRoute: initialRoute)
    configure?(basicViewController)
  }
  
  private var isCollapsed: Bool {
    basicViewController.isCollapsed
  }
  
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
  
  override public func perform(_ transfer: SplitTransfer) {
    switch transfer {
    case let .primary(transferType),
         let .secondary(transferType),
         let .supplmentary(transferType):
      handle(type: transferType, in: targetStack(of: transfer))
    case let .present(viewController):
      basicViewController.present(viewController)
      addChild(viewController)
    case .dimiss:
      break
    case .none:
      break
    }
  }
  
  func handle(type: SplitTransfer.TransferType, in stack: InternalStackViewController?) {
    switch type {
    case let .push(viewController, animated):
      stack?.push(viewController, animated: animated)
      addChild(viewController)
    case .pop:
      stack?.pop()
    case let .set(viewController):
      stack?.set(viewController)
      addChild(viewController)
    case .backToRoot:
      break
    }
  }
}
