//
//  Router.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Foundation

public protocol Router: Presentable {
  associatedtype RouteType: Route
  func navigate(to route: RouteType)
}

extension Router {
  public var strongRouter: StrongRouter<RouteType> {
    StrongRouter(self)
  }
  
  public var weakRouter: WeakRouter<RouteType> {
    WeakRouter(strongRouter)
  }
}
