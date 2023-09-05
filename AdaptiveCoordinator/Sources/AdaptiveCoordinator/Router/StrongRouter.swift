//
//  StrongRouter.swift
//
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit

public final class StrongRouter<RouteType: Route> {
  private var _viewController: UIViewController
  private var _transfer: (RouteType) -> Void
  
  init<RouterType: Router>(_ router: RouterType) where RouteType == RouterType.RouteType {
    _viewController = router.viewController
    _transfer = router.transfer(to:)
  }
  
  public var viewController: UIViewController {
    _viewController
  }
  
  public func transfer(to route: RouteType) {
    _transfer(route)
  }
}
