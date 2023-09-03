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
  override func navigate(to route: ColorListRoute) {
    switch route {
    case .list:
      let viewController = ColorListViewController(strongRouter)
      navigate(to: viewController)
    case .color(let str):
      let viewController = ColorViewController(color: str)
      navigate(to: viewController)
    case .settings:
      let viewController = SettingsViewController()
      navigate(to: viewController)
    }
  }
}

