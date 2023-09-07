//
//  Coordinator.swift
//  
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit

public protocol Coordinator: Presentable, Router {
  associatedtype BasicViewControllerType
  
  var basicViewController: BasicViewControllerType { get }
  var children: [any Presentable] { get set }
  var numOfChildren: Int { get }
  
  func prepare(to route: RouteType) -> TransferType
  func perform(_ transfer: TransferType)
  func addChild(_ presentable: any Presentable)
  func removeChild(_ presentable: any Presentable)
}

// Router
extension Coordinator {
  public func transfer(to route: RouteType) {
    perform(prepare(to: route))
  }
}
