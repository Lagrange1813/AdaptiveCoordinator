//
//  StackCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit
import Combine

open class StackCoordinator<RouteType: Route>: BaseCoordinator<RouteType, StackViewController> {
  var cancellables = Set<AnyCancellable>()
  
  override public init(basicViewController: BasicViewControllerType = .init(), initialType: RouteType) {
    super.init(basicViewController: basicViewController, initialType: initialType)
    
    basicViewController
      .didPopViewController
      .sink { [unowned self] viewController in
        children.removeAll { $0 === viewController || ($0 === viewController.presenter && viewController.presenter?.numOfChildren ?? 0 <= 1) }
      }
      .store(in: &cancellables)
  }
  
  func shouldRemove(child: Presentable, with viewController: UIViewController) -> Bool {
    child === viewController ||
    (child === viewController.presenter && 
     (viewController.presenter?.numOfChildren == .some(0) ||
      (viewController.presenter?.numOfChildren == .some(1) && viewController === viewController.presenter?.children[0])
     ))
  }

  override open func prepare(to route: RouteType) -> TransferType {
    fatalError("Please override the \(#function) method.")
  }

  public override func perform(_ transfer: TransferType) {
    switch transfer {
    case .push(let viewController):
      addChild(viewController)
      basicViewController.push(viewController)
    case .none:
      break
    }
  }
}
