//
//  Coordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

open class BaseCoordinator<RouteType: Route, BasicViewControllerType: UIViewController, TransferType: Transfer>: Coordinator {
  public typealias BasicViewControllerType = BasicViewControllerType
  public typealias TransferType = TransferType
  
  public weak var presenter: (any Coordinator)?
  
  private(set) public var basicViewController: BasicViewControllerType
  public var children = [any Presentable]()
  
  init(basicViewController: BasicViewControllerType, initialRoute: RouteType) {
    self.basicViewController = basicViewController
    transfer(to: initialRoute)
  }
  
  open func prepare(to route: RouteType) -> TransferType {
    fatalError("Please override the \(#function) method.")
  }
  
  public func perform(_ transfer: TransferType) {
    fatalError("Please override the \(#function) method.")
  }
}
