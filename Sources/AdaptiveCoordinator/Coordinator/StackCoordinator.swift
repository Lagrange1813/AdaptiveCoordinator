//
//  StackCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Combine
import UIKit

open class StackCoordinator<RouteType: Route>: Coordinator {
  // Type Declation
  public typealias RouteType = RouteType
  public typealias BasicViewControllerType = StackViewController
  public typealias TransferType = StackTransfer
  
  // Displayable
  public var displayerID: UUID?
  
  // Coordinator
  public let id: UUID
  public private(set) var basicViewController: BasicViewControllerType {
    didSet {
      _subscribeAutoRemove()
    }
  }

  public var children = [any Displayable]()
  private let _forwarder = PassthroughSubject<RouteType, Never>()
  public lazy var forwarder: AnyPublisher<RouteType, Never> = _forwarder.eraseToAnyPublisher()
  private var _cancellables = Set<AnyCancellable>()
  
  // Stack
  private var _autoRemoveCancellable: AnyCancellable?
  private var isPresenting: Bool = false
  public private(set) var isInitial: Bool = true

  public init(
    basicViewController: BasicViewControllerType = .init(),
    initialRoute: RouteType
  ) {
    self.id = UUID()
    self.basicViewController = basicViewController

    _addSubscriber()
    transfer(to: initialRoute)
  }
  
  private func _addSubscriber() {
    forwarder
      .sink { [unowned self] route in
        Task {
          let action = await prepare(to: route)
          
          switch action {
          case let .transfer(transferType):
            await perform(transferType)
          case let .send(routeType):
            _forwarder.send(routeType)
          case .none:
            break
          }
          
          if isInitial {
            isInitial = false
          }
        }
      }
      .store(in: &_cancellables)
    
    _subscribeAutoRemove()
  }
  
  func _subscribeAutoRemove() {
    _autoRemoveCancellable = basicViewController
      .didRemoveViewController
      .sink { [unowned self] viewControllers in
        for viewController in viewControllers {
          let idx = children.firstIndex { shouldRemove(child: $0, with: viewController) }
          if let idx {
            children.remove(at: idx)
          }
        }
      }
  }
  
  @MainActor
  open func prepare(to route: RouteType) -> ActionType<TransferType, RouteType> {
    fatalError("Please override the \(#function) method.")
  }
}

// Router
public extension StackCoordinator {
  func transfer(to route: RouteType) {
    _forwarder.send(route)
  }
}

// MARK: - Coordinator

public extension StackCoordinator {
  func trySetBasicViewController(_ viewController: UIViewController?) {
    if let new = viewController as? StackViewController {
      basicViewController = new
    }
  }
}

public extension StackCoordinator {
  private func addChild(_ displayable: Displayable) {
    children.append(displayable)
    displayable.displayerID = id
  }
  
  @MainActor
  func perform(_ transfer: StackTransfer) {
    switch transfer {
    case let .push(viewController, animated):
      basicViewController.push(viewController, animated: animated)
      addChild(viewController)
      
    case let .pop(animated):
      basicViewController.pop(animated: animated)
      
    case let .present(viewController, animated):
      basicViewController.present(viewController, animated: animated)
      addChild(viewController)
      isPresenting = true
      
    case let .dimiss(animated):
      basicViewController.dismiss(animated: animated)
      isPresenting = false
      
    case let .set(viewControllers):
      drop(animated: false)
      basicViewController.set(viewControllers)
      viewControllers.forEach { addChild($0) }
      
    case let .backToRoot(animated):
      if isPresenting {
        perform(.dimiss(animated))
      } else {
        if numOfChildren > 1 {
          perform(.pop(animated))
        }
      }
      
    case let .handover(coordinator):
      addChild(coordinator)
    }
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
  
  @MainActor
  func drop(animated: Bool = true) {
    for child in children {
      if let coordinator = child as? any Coordinator {
        coordinator.drop(animated: animated)
      }
    }
    perform(.pop(animated))
  }
}
