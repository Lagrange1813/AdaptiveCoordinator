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
  private var isPresenting: Bool = false
  public var cancellables = Set<AnyCancellable>()
  
  public var rootRoute: (() -> RouteType)?

  public override init(basicViewController: BasicViewControllerType = .init(), initialType: RouteType) {
    currentRoute = initialType
    super.init(basicViewController: basicViewController, initialType: initialType)
    bindEvents()
  }
  
  func bindEvents() {
    basicViewController
      .didRemoveViewController
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
