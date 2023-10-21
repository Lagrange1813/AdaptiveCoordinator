//
//  StackCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Combine
import UIKit

open class StackCoordinator<RouteType: Route>: BaseCoordinator<RouteType, StackViewController, StackTransfer> {
  @Published public private(set) var currentRoute: RouteType
  public private(set) var rootRoute: RouteType
  
  private var isPresenting: Bool = false
  public private(set) var isInitial: Bool = true

  public init(
    basicViewController: BasicViewControllerType = .init(),
    initialRoute: RouteType,
    rootRoute: RouteType? = nil
  ) {
    currentRoute = initialRoute
    self.rootRoute = rootRoute ?? initialRoute
    super.init(basicViewController: basicViewController, initialRoute: self.rootRoute)
    isInitial = false
    if rootRoute != nil {
      transfer(to: initialRoute)
    }
    bindEvents()
  }
  
  func bindEvents() {
    basicViewController
      .didRemoveViewController
      .sink { [unowned self] viewControllers in
        for viewController in viewControllers {
          let idx = children.firstIndex { shouldRemove(child: $0, with: viewController) }
          if let idx {
            children.remove(at: idx)
            currentRoute = rootRoute
          }
        }
      }.store(in: &_cancellables)
  }
  
  open func prepare(to route: RouteType) -> StackTransfer {
    fatalError("Please override the \(#function) method.")
  }
  
  override public func _prepare(to route: RouteType) -> StackTransfer {
    let transfer = prepare(to: route)
    currentRoute = route
    return transfer
  }

  override public func perform(_ transfer: StackTransfer) {
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
      
    case .none:
      break
    }
  }
  
  override public func drop(animated: Bool = true) {
    super.drop(animated: animated)
    perform(.pop(animated))
  }
}