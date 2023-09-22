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
  private var isPresenting: Bool = false
  public var cancellables = Set<AnyCancellable>()
  
  public var rootRoute: RouteType
  
//  public var user: User?

  public init(basicViewController: BasicViewControllerType = .init(), initialRoute: RouteType, rootRoute: RouteType? = nil) {
    currentRoute = initialRoute
    self.rootRoute = rootRoute ?? initialRoute
    super.init(basicViewController: basicViewController, initialRoute: initialRoute)
    bindEvents()
  }
  
//  public init(initialRoute: RouteType, user: User) where User.RouteType == RouteType, User.TransferType == StackTransfer {
//    self.currentRoute = initialRoute
//    self.rootRoute = initialRoute
//    self.user = user
//    super.init(basicViewController: BasicViewControllerType(), initialRoute: initialRoute)
//  }
  
  func bindEvents() {
    basicViewController
      .didRemoveViewController
      .sink { [unowned self] viewController in
        let idx = children.firstIndex { shouldRemove(child: $0, with: viewController) }
        if let idx {
          children.remove(at: idx)
          currentRoute = rootRoute
        }
      }
      .store(in: &cancellables)
  }

  private func shouldRemove(child: any Presentable, with viewController: UIViewController) -> Bool {
    child === viewController || (
      child === viewController.presenter && (
        viewController.presenter?.numOfChildren == .some(0) || (
          viewController.presenter?.numOfChildren == .some(1) &&
            viewController === viewController.presenter?.children[0]
        )
      )
    )
  }

  @discardableResult
  override open func prepare(to route: RouteType) -> StackTransfer {
    currentRoute = route
    return .none
  }

  override public func perform(_ transfer: StackTransfer) {
    switch transfer {
    case .push(let viewController):
      basicViewController.push(viewController)
      addChild(viewController)
    case .pop:
      basicViewController.pop()
    case .present(let viewController):
      basicViewController.present(viewController)
      addChild(viewController)
      isPresenting = true
    case .dimiss:
      basicViewController.dismiss()
      isPresenting = false
    case .backToRoot:
      if isPresenting {
        perform(.dimiss)
      } else {
        if numOfChildren > 1 {
          perform(.pop)
        }
      }
    case .none:
      break
    }
  }
}
