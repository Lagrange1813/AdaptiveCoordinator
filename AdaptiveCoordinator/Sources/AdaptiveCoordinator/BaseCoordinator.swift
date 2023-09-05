//
//  Coordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

open class BaseCoordinator<RouteType: Route, BasicViewControllerType: UIViewController>: Coordinator {
  public typealias BasicViewControllerType = BasicViewControllerType
  
  private(set) public var basicViewController: BasicViewControllerType
  public var children = [Presentable]()
  
  public var numOfChildren: Int {
    children.count
  }
  
  public final var viewController: UIViewController {
    basicViewController
  }
  
  public weak var presenter: (any Coordinator)?
  
  init(basicViewController: BasicViewControllerType, initialType: RouteType) {
    self.basicViewController = basicViewController
    transfer(to: initialType)
  }
  
  open func prepare(to route: RouteType) -> TransferType {
    fatalError("Please override the \(#function) method.")
  }
  
  public func perform(_ transfer: TransferType) {
    fatalError("Please override the \(#function) method.")
  }
  
  final public func addChild(_ presentable: Presentable) {
    children.append(presentable)
    presentable.presenter = self
  }
  
  final public func removeChild(_ presentable: Presentable) {
    children.removeAll { $0.viewController === presentable.viewController }
  }
}
