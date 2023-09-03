//
//  ColorCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/3.
//

import AdaptiveCoordinator
import UIKit

enum ColorRoute: Route {
  case color(String)
  case meaning(String)
  case colors
}

class ColorCoordinator: StackCoordinator<ColorRoute> {
  override func navigate(to route: ColorRoute) {
    switch route {
    case .color(let string):
      break
    case .meaning(let string):
      break
    case .colors:
      dismiss()
    }
  }
}
