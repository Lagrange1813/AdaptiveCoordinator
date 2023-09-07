//
//  StrongRouter.swift
//
//
//  Created by Lagrange1813 on 2023/9/3.
//

import Foundation

public final class StrongRouter<RouteType: Route>: Router {
  private var _transfer: (RouteType) -> Void
  
  init<RouterType: Router>(_ router: RouterType) where RouteType == RouterType.RouteType {
    _transfer = router.transfer(to:)
  }
  
  public func transfer(to route: RouteType) {
    _transfer(route)
  }
}
