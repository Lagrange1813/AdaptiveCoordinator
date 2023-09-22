//
//  Coordinator.swift
//  
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit

public protocol Coordinator: Presentable, Router {
  associatedtype BasicViewControllerType: UIViewController
  associatedtype TransferType: Transfer
  
  var strongRouter: StrongRouter<RouteType> { get }
  var unownedRouter: UnownedRouter<RouteType> { get }
  
  var basicViewController: BasicViewControllerType { get }
  var children: [any Presentable] { get set }
  var numOfChildren: Int { get }
  
  func prepare(to route: RouteType) -> TransferType
  func perform(_ transfer: TransferType)
  
  func addChild(_ presentable: any Presentable)
  func removeChild(_ presentable: any Presentable)
}

extension Coordinator {
  public var numOfChildren: Int {
    children.count
  }
  
  public func addChild(_ presentable: Presentable) {
    children.append(presentable)
    presentable.presenter = self
  }
  
  public func removeChild(_ presentable: Presentable) {
    children.removeAll { $0.viewController === presentable.viewController }
  }
}

// MARK: - Presentable

extension Coordinator {
  public var viewController: UIViewController {
    basicViewController
  }
}

// MARK: - Router
extension Coordinator {
  public func transfer(to route: RouteType) {
    perform(prepare(to: route))
  }
}

extension Coordinator {
  public var strongRouter: StrongRouter<RouteType> {
    StrongRouter(self)
  }
  
  public var unownedRouter: UnownedRouter<RouteType> {
    UnownedRouter(self, erase: { $0.strongRouter })
  }
}
