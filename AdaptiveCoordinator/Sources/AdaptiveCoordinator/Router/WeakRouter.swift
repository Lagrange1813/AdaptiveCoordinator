//
//  WeakRouter.swift
//
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit

public final class WeakRouter<RouteType: Route> {
  private weak var _strongRouter: StrongRouter<RouteType>?
  
  init(_ strongRouter: StrongRouter<RouteType>) {
    self._strongRouter = strongRouter
  }
  
  public var viewController: UIViewController? {
    _strongRouter?.viewController
  }
  
  public func navigate(to route: RouteType) {
    _strongRouter?.navigate(to: route)
  }
}
