//
//  Coordinator.swift
//  
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit
import Combine

public protocol Coordinator: Displayable, Router {
  associatedtype BasicViewControllerType: UIViewController
  associatedtype TransferType: Transfer
  
  var strongRouter: StrongRouter<RouteType> { get }
  var unownedRouter: UnownedRouter<RouteType> { get }
  
  var basicViewController: BasicViewControllerType { get }
  var children: [any Displayable] { get set }
//  var numOfChildren: Int { get }
  
  var forwarder: AnyPublisher<RouteType, Never> { get }
  
  func _prepare(to route: RouteType) -> TransferType
  func perform(_ transfer: TransferType)
  
//  func addChild(_ displayable: any Displayable)
//  func removeChild(_ displayable: any Displayable)
  func drop(animated: Bool)
}

extension Coordinator {
  var numOfChildren: Int {
    children.count
  }
  
  func addChild(_ displayable: Displayable) {
    children.append(displayable)
    displayable.displayer = self
  }
  
  func removeChild(_ displayable: Displayable) {
    children.removeAll { $0.viewController === displayable.viewController }
  }
}

// MARK: - Displayable

extension Coordinator {
  public var viewController: UIViewController {
    basicViewController
  }
}

// MARK: - Router
//extension Coordinator {
//  public func transfer(to route: RouteType) {
//    perform(_prepare(to: route))
//  }
//}

extension Coordinator {
  public var strongRouter: StrongRouter<RouteType> {
    StrongRouter(self)
  }
  
  public var unownedRouter: UnownedRouter<RouteType> {
    UnownedRouter(self, erase: { $0.strongRouter })
  }
  
  public var weakRouter: WeakRouter<RouteType> {
    WeakRouter(self, erase: { $0?.strongRouter })
  }
}

// MARK: - DeepLink

extension Coordinator {
  public func handle(links: [String]) {
    guard
      let route = (RouteType.self as? any DeepLinkable.Type)?.init(link: links[0]) as? Self.RouteType
    else { return }
    transfer(to: route)
    guard links.count > 1 else { return }
    let remaining = Array(links[1...])
    children.forEach { ($0 as? any Coordinator)?.handle(links: remaining) }
  }
}
