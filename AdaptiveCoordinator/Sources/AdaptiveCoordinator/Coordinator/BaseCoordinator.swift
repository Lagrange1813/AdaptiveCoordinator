//
//  Coordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import CasePaths
import Combine
import UIKit

open class BaseCoordinator<RouteType: Route, BasicViewControllerType: UIViewController, TransferType: Transfer>: Coordinator {
  public typealias RouteType = RouteType
  public typealias BasicViewControllerType = BasicViewControllerType
  public typealias TransferType = TransferType
  
  public weak var displayer: (any Coordinator)?
  
  public private(set) var basicViewController: BasicViewControllerType
  public var children = [any Displayable]()
  
  let _forwarder = PassthroughSubject<RouteType, Never>()
  public lazy var forwarder: AnyPublisher<RouteType, Never> = _forwarder.eraseToAnyPublisher()
  
  var _cancellables = Set<AnyCancellable>()
  
  init(basicViewController: BasicViewControllerType, initialRoute: RouteType) {
    self.basicViewController = basicViewController
    _addSubscriber()
    transfer(to: initialRoute)
  }
  
  @MainActor
  public func _prepare(to route: RouteType) -> TransferType {
    fatalError()
  }
  
  @MainActor
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
  
  @MainActor
  public func drop(animated: Bool = true) {
    for child in children {
      if let coordinator = child as? any Coordinator {
        coordinator.drop(animated: animated)
      }
    }
    print("Drop: \(String(describing: type(of: self)))")
  }
}

public extension BaseCoordinator {
  func transfer(to route: RouteType) {
    _forwarder.send(route)
  }
  
  fileprivate func _addSubscriber() {
    forwarder
      .sink { [unowned self] route in
        Task {
          await perform(_prepare(to: route))
        }
      }
      .store(in: &_cancellables)
  }
  
  func pullback<SubCoordinator: Coordinator>(
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
