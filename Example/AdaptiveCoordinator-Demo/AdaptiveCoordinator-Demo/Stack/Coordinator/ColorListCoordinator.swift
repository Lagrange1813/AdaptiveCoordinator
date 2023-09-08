//
//  ColorListCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/2.
//

import Foundation
import AdaptiveCoordinator

// 比色卡
enum ColorListRoute: Route {
  // main route
  case list
  case color(String)
  case settings
  case info
  case root
}

class ColorListCoordinator: StackCoordinator<ColorListRoute> {
  override init(basicViewController: StackCoordinator<ColorListRoute>.BasicViewControllerType = .init(), initialType: ColorListRoute) {
    super.init(basicViewController: basicViewController, initialType: initialType)
    rootRoute = { .list }
    
    basicViewController.didAddViewController
      .sink { [unowned self] in
        print(dump() + "\n")
      }
      .store(in: &cancellables)
    
    basicViewController.didRemoveViewController
      .sink { [unowned self] _ in
        print(dump() + "\n")
      }
      .store(in: &cancellables)
  }
  
  override func prepare(to route: ColorListRoute) -> TransferType {
    super.prepare(to: route)
    switch route {
    case .list:
      let viewController = ColorListViewController(unownedRouter)
      return .push(viewController)
    case .color(let str):
      addChild(ColorCoordinator(basicViewController: basicViewController, initialType: .color(str)))
      return .none
    case .settings:
      addChild(SettingsCoordinator(basicViewController: basicViewController, initialType: .list))
      return .none
    case .info:
      let viewController = InfoViewController(unownedRouter)
      return .present(viewController)
    case .root:
      return .backToRoot
    }
  }
}

