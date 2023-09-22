//
//  UserCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/22.
//

import Foundation

public protocol UserCoordinator {
  associatedtype RouteType: Route
  associatedtype TransferType: Transfer
  
  var initialRoute: RouteType { get set }
  var rootRoute: RouteType { get set }
  func prepare(to route: RouteType) -> TransferType
}
