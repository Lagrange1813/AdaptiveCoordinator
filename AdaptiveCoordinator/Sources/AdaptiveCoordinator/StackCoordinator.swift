//
//  StackCoordinator.swift
//  
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

open class StackCoordinator<RouteType: Route>: BaseCoordinator<RouteType, UINavigationController> {
  public init(initialType: RouteType) {
    super.init(basicViewController: UINavigationController())
    navigate(to: initialType)
  }
  
  open override func navigate(to route: RouteType) {
    fatalError()
  }
  
  public override func navigate(to presentable: Presentable) {
    let viewController = presentable.viewController
    basicViewController.pushViewController(viewController, animated: true)
  }
  
  public func dismiss() {
    basicViewController.dismiss(animated: true)
  }
}
