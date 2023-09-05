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
}

class ColorListCoordinator: StackCoordinator<ColorListRoute> {
  override func prepare(to route: ColorListRoute) -> TransferType {
    switch route {
    case .list:
      let viewController = ColorListViewController(strongRouter)
      return .push(viewController)
    case .color(let str):
      addChild(ColorCoordinator(basicViewController: basicViewController, initialType: .color(str)))
      return .none
    case .settings:
      let viewController = SettingsViewController()
      return .push(viewController)
    }
  }
}

