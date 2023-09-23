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
  
  weak public var presenter: (any Coordinator)?
  
  private(set) public var basicViewController: BasicViewControllerType
  public var children = [any Presentable]()
  
  init(basicViewController: BasicViewControllerType, initialRoute: RouteType) {
    self.basicViewController = basicViewController
    transfer(to: initialRoute)
  }
  
  public func _prepare(to route: RouteType) -> TransferType {
    fatalError()
  }
  
  public func perform(_ transfer: TransferType) {
    fatalError()
  }
  
  func shouldRemove(child: any Presentable, with viewController: UIViewController) -> Bool {
    child === viewController || (
      child === viewController.presenter && (
        viewController.presenter?.numOfChildren == .some(0) || (
          viewController.presenter?.numOfChildren == .some(1) &&
            viewController === viewController.presenter?.children[0]
        )
      )
    )
  }
}
