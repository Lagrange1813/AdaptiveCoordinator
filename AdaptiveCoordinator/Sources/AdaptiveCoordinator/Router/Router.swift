//
//  Router.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

public protocol Router: Presentable {
  associatedtype RouteType: Route
  func transfer(to route: RouteType)
}

extension Router {
  public var strongRouter: StrongRouter<RouteType> {
    StrongRouter(self)
  }
}
