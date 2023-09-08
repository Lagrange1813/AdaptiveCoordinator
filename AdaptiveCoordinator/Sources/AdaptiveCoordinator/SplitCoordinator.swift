//
//  SplitCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit
import Combine

open class SplitCoordinator<RouteType: Route>: BaseCoordinator<RouteType, SplitViewController> {
  public override init(basicViewController: BasicViewControllerType = .init(), initialType: RouteType) {
    super.init(basicViewController: basicViewController, initialType: initialType)
  }
  
  public override func perform(_ transfer: TransferType) {
    switch transfer {
    case .push(let viewController):
      break
    case .pop:
      break
    case .present(let viewController):
      break
    case .dimiss:
      break
    case .backToRoot:
      break
    case .none:
      break
    }
  }
}
