//
//  StackCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Combine
import UIKit

open class StackCoordinator<RouteType: Route>: BaseCoordinator<RouteType, StackViewController> {
  @Published public private(set) var currentRoute: RouteType
  public var cancellables = Set<AnyCancellable>()
  
  public var rootRoute: (() -> RouteType)?

  override public init(basicViewController: BasicViewControllerType = .init(), initialType: RouteType) {
    currentRoute = initialType
    super.init(basicViewController: basicViewController, initialType: initialType)
    bindEvents()
  }
  
  func bindEvents() {
    basicViewController
      .didPopViewController
      .sink { [unowned self] viewController in
        let idx = children.firstIndex { shouldRemove(child: $0, with: viewController) }
        if let idx {
          children.remove(at: idx)
          if let rootRoute {
            currentRoute = rootRoute()
          }
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
  override open func prepare(to route: RouteType) -> TransferType {
    currentRoute = route
    return .none
  }

  override public func perform(_ transfer: TransferType) {
    switch transfer {
    case .push(let viewController):
      addChild(viewController)
      basicViewController.push(viewController)
    case .pop:
      basicViewController.pop()
    case .popToRoot:
      if numOfChildren > 1 {
        basicViewController.pop()
      }
    case .none:
      break
    }
  }
}
