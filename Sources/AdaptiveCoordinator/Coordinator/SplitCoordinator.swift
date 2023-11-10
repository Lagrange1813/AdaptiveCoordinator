//
//  SplitCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Combine
import UIKit

open class SplitCoordinator<RouteType: Route>: Coordinator {
  public enum Strategy {
    case merge
    case custom(SplitViewController)
  }
  
  private enum Column {
    case primary
    case supplementary
    case secondary
  }
  
  // MARK: - Coordinator
  
  public typealias RouteType = RouteType
  public typealias BasicViewControllerType = SplitViewController
  public typealias TransferType = SplitTransfer
  
  public var displayerID: UUID?
  
  public let id: UUID
  public private(set) var basicViewController: BasicViewControllerType
  ///
  /// The displayables of all columns.
  ///
  public var children = [any Displayable]()
  private let _forwarder = PassthroughSubject<RouteType, Never>()
  public lazy var forwarder: AnyPublisher<RouteType, Never> = _forwarder.eraseToAnyPublisher()
  
  // MARK: - End
  
  private var origins: [UUID: Column] = [:]
  public private(set) var isInitial: Bool = true
  
  private var _cancellables = Set<AnyCancellable>()
  
  public init(
    strategy: Strategy,
    initialRoute: RouteType
  ) {
    self.id = UUID()
    self.basicViewController = switch strategy {
    case .merge:
      UniversalSplitViewController()
    case let .custom(splitViewController):
      splitViewController
    }
    
    _addSubscriber()
    transfer(to: initialRoute)
    
    // MARK: - Todo
    
    basicViewController.willCollapse = { [weak self] in
      guard let self else { return }
      
      for child in children {
        if let coordinator = child as? any Coordinator {
          coordinator.trySetBasicViewController(basicViewController.compact)
        }
      }
    }
    
    basicViewController.willExpand = { [weak self] in
      guard let self else { return }
      
      for child in children {
        if let coordinator = child as? any Coordinator {
          print(coordinator, origins[coordinator.id], stack(of: origins[coordinator.id]))
          coordinator.trySetBasicViewController(stack(of: origins[coordinator.id]))
        }
      }
    }
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
          removeChild(with: viewController)
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

// MARK: - Coordinator

public extension SplitCoordinator {
  var primary: StackViewController {
    isCollapsed ? basicViewController.compact : basicViewController.primary
  }

  var supplementary: StackViewController {
    isCollapsed ? basicViewController.compact : basicViewController.supplementary
  }

  var secondary: StackViewController {
    isCollapsed ? basicViewController.compact : basicViewController.secondary
  }
}

public extension SplitCoordinator {
  func trySetBasicViewController(_ viewController: UIViewController?) {}
}

public extension SplitCoordinator {
  private func addChild(_ displayable: Displayable, in column: Column?) {
    print(displayable, column)
    
    children.append(displayable)
    displayable.displayerID = id
    
    if
      let coordinator = displayable as? any Coordinator,
      let column
    {
      origins[coordinator.id] = column
    }
  }
  
  private func removeChild(with viewController: UIViewController) {
    let idx = children.firstIndex { shouldRemove(child: $0, with: viewController) }
    if let idx {
      if let coordinator = children[idx] as? any Coordinator {
        origins.removeValue(forKey: coordinator.id)
      }
      children.remove(at: idx)
    }
  }
  
  @MainActor
  func perform(_ transfer: SplitTransfer) {
    switch transfer {
    case let .primary(transferType),
         let .supplementary(transferType),
      let .secondary(transferType):
      handle(transferType, in: stack(of: transfer), column: column(of: transfer))
      
    case let .present(viewController, animated):
      basicViewController.present(viewController, animated: animated)
      addChild(viewController, in: nil)
      
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
  func stack(of transfer: SplitTransfer) -> StackViewController? {
    if isCollapsed {
      switch transfer {
      case .primary, .supplementary, .secondary:
        basicViewController.compact
      case .present, .dimiss:
        nil
      }
      
    } else {
      switch transfer {
      case .primary:
        basicViewController.primary
      case .supplementary:
        basicViewController.supplementary
      case .secondary:
        basicViewController.secondary
      case .present, .dimiss:
        nil
      }
    }
  }
  
  private func column(of transfer: SplitTransfer) -> Column? {
    switch transfer {
    case .primary:
      .primary
    case .supplementary:
      .supplementary
    case .secondary:
      .secondary
    case .present, .dimiss:
      nil
    }
  }
  
  private func handle(_ type: SplitTransfer.TransferType, in stack: StackViewController?, column: Column?) {
    switch type {
    case let .push(viewController, animated):
      stack?.push(viewController, animated: animated)
      addChild(viewController, in: column)
      
    case let .pop(animated):
      stack?.pop(animated: animated)
      
    case let .set(viewControllers):
      stack?.set(viewControllers)
      viewControllers.forEach { addChild($0, in: column) }
      
    case .backToRoot:
      break
      
    case let .handover(coordinator):
      addChild(coordinator, in: column)
    }
  }
  
  private func stack(of column: Column?) -> StackViewController? {
    switch column {
    case .primary:
      basicViewController.primary
    case .supplementary:
      basicViewController.supplementary
    case .secondary:
      basicViewController.secondary
    default:
      nil
    }
  }
}
