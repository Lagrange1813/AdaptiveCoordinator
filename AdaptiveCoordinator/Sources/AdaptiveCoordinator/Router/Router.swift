//
//  Router.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

public protocol Router {
  associatedtype RouteType: Route
  func transfer(to route: RouteType)
}
