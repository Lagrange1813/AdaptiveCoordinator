//
//  Coordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

open class BaseCoordinator<RouteType: Route, BasicViewControllerType: UIViewController, TransferType: Transfer>: Coordinator {
  public typealias RouteType = RouteType
  public typealias BasicViewControllerType = BasicViewControllerType
  public typealias TransferType = TransferType
  
  weak public var displayer: (any Coordinator)?
  
  private(set) public var basicViewController: BasicViewControllerType
  public var children = [any Displayable]()
  
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
  
  func shouldRemove(child: any Displayable, with viewController: UIViewController) -> Bool {
    child === viewController || (
      child === viewController.displayer && (
        viewController.displayer?.numOfChildren == .some(0) || (
          viewController.displayer?.numOfChildren == .some(1) &&
            viewController === viewController.displayer?.children[0]
        )
      )
    )
  }
}
