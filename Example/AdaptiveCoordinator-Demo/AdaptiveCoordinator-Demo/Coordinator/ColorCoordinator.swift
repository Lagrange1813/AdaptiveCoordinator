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
  deinit {
    print("ColorCoordinator - Deinit")
  }
  
  override func prepare(to route: ColorRoute) -> TransferType {
    switch route {
    case .color(let str):
      let viewController = ColorViewController(color: str)
      return .push(viewController)
    case .meaning(let str):
      print(str)
      return .none
    case .colors:
      return .none
    }
  }
}
