//
//  ColorListCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/2.
//

import AdaptiveCoordinator
import Combine
import Foundation

// 比色卡
enum ColorListRoute: Route, DeepLinkable {
  case list
  case color(String)
  case settings
  case info
  // equal to list here
  case root
  
  init?(link: String) {
    self.init(link)
  }
  
  init?(_ str: String) {
    if str == "list" {
      self = .list
    } else if str.starts(with: "color") {
      let components = str.components(separatedBy: ":")
      guard
        components.count == 2,
        let argu = components.last
      else { return nil }
      self = .color(argu)
    } else if str == "settings" {
      self = .settings
    } else if str == "info" {
      self = .info
    } else {
      return nil
    }
  }
}

class ColorListCoordinator: StackCoordinator<ColorListRoute> {
  var cancellables = Set<AnyCancellable>()
  
  override init(
    basicViewController: StackCoordinator<ColorListRoute>.BasicViewControllerType = .init(),
    initialRoute: ColorListRoute,
    rootRoute: ColorListRoute? = nil
  ) {
    super.init(
      basicViewController: basicViewController,
      initialRoute: initialRoute,
      rootRoute: rootRoute
    )
    
    basicViewController.didAddViewController
      .sink { [unowned self] in
        print(dump() + "\n")
      }.store(in: &cancellables)
    
    basicViewController.didRemoveViewController
      .sink { [unowned self] _ in
        print(dump() + "\n")
      }.store(in: &cancellables)
  }
  
  override func prepare(to route: ColorListRoute) -> TransferType {
    switch route {
    case .list:
      let viewController = ColorListViewController(unownedRouter)
      return .push(viewController)
    case .color(let str):
      let coordinator = ColorCoordinator(basicViewController: basicViewController, initialRoute: .color(str))
      return .handover(coordinator)
    case .settings:
      let coordinator = SettingsCoordinator(basicViewController: basicViewController, initialRoute: .list)
      return .handover(coordinator)
    case .info:
      let viewController = InfoViewController(unownedRouter)
      return .present(viewController)
    case .root:
      return .backToRoot()
    }
  }
}
