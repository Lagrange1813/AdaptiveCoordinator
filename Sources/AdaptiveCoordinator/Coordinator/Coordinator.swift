//
//  Coordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/3.
//

import Combine
import UIKit

public enum ActionType<TransferType: Transfer, RouteType: Route> {
  case transfer(TransferType)
  case send(RouteType)
  case none
}

public protocol Coordinator: Displayable, Router, Dumpable {
  // Type
  associatedtype BasicViewControllerType: UIViewController
  associatedtype TransferType: Transfer

  // Properties
  var id: UUID { get }
  var basicViewController: BasicViewControllerType { get }
  var children: [any Displayable] { get set }
  var forwarder: AnyPublisher<RouteType, Never> { get }

  // Functions
  func perform(_ transfer: TransferType)
  func pullback<SubCoordinator: Coordinator>(
    subCoordinator: SubCoordinator,
    _ transformer: @escaping (SubCoordinator.RouteType) -> RouteType
  )
  func handle(links: [String])
  func drop(animated: Bool)

  // Router
  var strongRouter: StrongRouter<RouteType> { get }
  var unownedRouter: UnownedRouter<RouteType> { get }
}

// MARK: - Displayable

public extension Coordinator {
  var viewController: UIViewController {
    basicViewController
  }
}

// MARK: - Router

public extension Coordinator {
  var strongRouter: StrongRouter<RouteType> {
    StrongRouter(self)
  }

  var unownedRouter: UnownedRouter<RouteType> {
    UnownedRouter(self, erase: { $0.strongRouter })
  }

  var weakRouter: WeakRouter<RouteType> {
    WeakRouter(self, erase: { $0?.strongRouter })
  }
}

// MARK: - Coordinator

extension Coordinator {
  var numOfChildren: Int {
    children.count
  }

  func addChild(_ displayable: Displayable) {
    children.append(displayable)
    displayable.displayerID = id
  }

  func removeChild(_ displayable: Displayable) {
    children.removeAll { $0.viewController === displayable.viewController }
  }

  func shouldRemove(child: any Displayable, with viewController: UIViewController) -> Bool {
    if child === viewController { return true }

    if let coordinator = child as? any Coordinator {
      return coordinator.id == viewController.displayerID && (
        coordinator.numOfChildren == .some(0) || (
          coordinator.numOfChildren == .some(1) &&
            viewController === coordinator.children[0]
        )
      )
    }

    return false
  }
}

public extension Coordinator {
  func handle(links: [String]) {
    guard
      let route = (RouteType.self as? any DeepLinkable.Type)?.init(link: links[0]) as? Self.RouteType
    else { return }
    transfer(to: route)
    guard links.count > 1 else { return }
    let remaining = Array(links[1...])
    children.forEach { ($0 as? any Coordinator)?.handle(links: remaining) }
  }
}
