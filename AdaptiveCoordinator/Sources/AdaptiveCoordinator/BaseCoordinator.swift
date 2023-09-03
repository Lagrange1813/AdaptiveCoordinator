//
//  Coordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

open class BaseCoordinator<RouteType: Route, BasicViewControllerType: UIViewController>: Coordinator {
  private(set) public var basicViewController: BasicViewControllerType
  
  public init(basicViewController: BasicViewControllerType) {
    self.basicViewController = basicViewController
  }
  
  public var viewController: UIViewController {
    basicViewController
  }
  
  open func navigate(to route: RouteType) {}
  open func navigate(to presentable: Presentable) {}
}
