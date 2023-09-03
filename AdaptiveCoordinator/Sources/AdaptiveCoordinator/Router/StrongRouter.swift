//
//  StrongRouter.swift
//
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit

public final class StrongRouter<RouteType: Route> {
  private var _viewController: UIViewController
  private var _navigate: (RouteType) -> Void
  
  init<RouterType: Router>(_ router: RouterType) where RouteType == RouterType.RouteType {
    _viewController = router.viewController
    _navigate = router.navigate(to:)
  }
  
  public var viewController: UIViewController {
    _viewController
  }
  
  public func navigate(to route: RouteType) {
    _navigate(route)
  }
}
