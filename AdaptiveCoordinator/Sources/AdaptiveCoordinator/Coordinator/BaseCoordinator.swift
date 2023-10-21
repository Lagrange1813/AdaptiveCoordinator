//
//  Coordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit
import Combine
import CasePaths

open class BaseCoordinator<RouteType: Route, BasicViewControllerType: UIViewController, TransferType: Transfer>: Coordinator {
  public typealias RouteType = RouteType
  public typealias BasicViewControllerType = BasicViewControllerType
  public typealias TransferType = TransferType
  
  weak public var displayer: (any Coordinator)?
  
  private(set) public var basicViewController: BasicViewControllerType
  public var children = [any Displayable]()
  
  let _forwarder = PassthroughSubject<RouteType, Never>()
  public lazy var forwarder: AnyPublisher<RouteType, Never> = _forwarder.eraseToAnyPublisher()
  
  var _cancellables = Set<AnyCancellable>()
  
  init(basicViewController: BasicViewControllerType, initialRoute: RouteType) {
    self.basicViewController = basicViewController
    _addSubscriber()
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
  
  public func drop(animated: Bool = true) {
    for child in children {
      if let coordinator = child as? any Coordinator {
        coordinator.drop(animated: animated)
      }
    }
    print("Drop: \(String(describing: type(of: self)))")
  }
}

extension BaseCoordinator {
  public func transfer(to route: RouteType) {
    _forwarder.send(route)
  }
  
  fileprivate func _addSubscriber() {
    forwarder
      .sink { [unowned self] in
        perform(_prepare(to: $0))
      }
      .store(in: &_cancellables)
  }
  
  public func pullback<SubCoordinator: Coordinator>(
    subCoordinator: SubCoordinator,
    _ transformer: @escaping (SubCoordinator.RouteType) -> RouteType
  ) {
    subCoordinator
      .forwarder
      .map(transformer)
      .subscribe(_forwarder)
      .store(in: &_cancellables)
  }
}
