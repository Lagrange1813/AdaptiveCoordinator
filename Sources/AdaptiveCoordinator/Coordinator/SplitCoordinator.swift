//
//  SplitCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Combine
import UIKit

open class SplitCoordinator<RouteType: Route>: Coordinator {
  public typealias RouteType = RouteType
  public typealias BasicViewControllerType = SplitViewController
  public typealias TransferType = SplitTransfer
  
  public var displayerID: UUID?
  
  public let id: UUID
  public private(set) var basicViewController: BasicViewControllerType
  public var children = [any Displayable]()
  private let _forwarder = PassthroughSubject<RouteType, Never>()
  public lazy var forwarder: AnyPublisher<RouteType, Never> = _forwarder.eraseToAnyPublisher()
  private var _cancellables = Set<AnyCancellable>()
  
  public private(set) var isInitial: Bool = true
  
  public init(
    basicViewController: BasicViewControllerType = .init(),
    configure: ((BasicViewControllerType) -> Void)? = nil,
    initialRoute: RouteType
  ) {
    self.id = UUID()
    self.basicViewController = basicViewController
    
    _addSubscriber()
    transfer(to: initialRoute)
  }
  
  func _addSubscriber() {
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
    
    basicViewController
      .didRemoveViewController
      .sink { [unowned self] viewControllers in
        for viewController in viewControllers {
          let idx = children.firstIndex { shouldRemove(child: $0, with: viewController) }
          if let idx {
            children.remove(at: idx)
          }
        }
      }.store(in: &_cancellables)
  }
  
  public var isCollapsed: Bool {
    basicViewController.isCollapsed
  }
  
  @MainActor
  open func prepare(to route: RouteType) -> ActionType<TransferType, RouteType> {
    fatalError("Please override the \(#function) method.")
  }
}

public extension SplitCoordinator {
  func transfer(to route: RouteType) {
    _forwarder.send(route)
  }
}

public extension SplitCoordinator {
  @MainActor
  func perform(_ transfer: SplitTransfer) {
    switch transfer {
    case let .primary(transferType),
         let .secondary(transferType),
         let .supplmentary(transferType):
      handle(type: transferType, in: targetStack(of: transfer))
      
    case let .present(viewController, animated):
      basicViewController.present(viewController, animated: animated)
      addChild(viewController)
      
    case let .dimiss(animated):
      basicViewController.dismiss(animated: animated)
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
    print("Drop: \(String(describing: type(of: self)))")
  }
}

extension SplitCoordinator {
  func targetStack(of transfer: SplitTransfer) -> StackViewController? {
    switch transfer {
    case .primary:
      basicViewController.primary
    case .secondary:
      basicViewController.secondary
    case .supplmentary:
      nil
    case .present, .dimiss:
      nil
    }
  }
  
  func handle(type: SplitTransfer.TransferType, in stack: StackViewController?) {
    switch type {
    case let .push(viewController, animated):
      stack?.push(viewController, animated: animated)
      addChild(viewController)
      
    case let .pop(animated):
      stack?.pop(animated: animated)
      
    case let .set(viewControllers):
      stack?.set(viewControllers)
      viewControllers.forEach { addChild($0) }
      
    case .backToRoot:
      break
      
    case let .handover(coordinator):
      addChild(coordinator)
    }
  }
}
