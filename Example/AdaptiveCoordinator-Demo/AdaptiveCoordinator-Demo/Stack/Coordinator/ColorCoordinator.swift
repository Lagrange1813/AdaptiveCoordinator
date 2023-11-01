//
//  ColorCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/3.
//

import AdaptiveCoordinator
import UIKit

enum ColorRoute: Route, DeepLinkable {
  case color(String)
  case meaning(String)
  case colors
  case settings
  case general
  
  init?(link: String) {
    self.init(link)
  }
  
  init?(_ str: String) {
    if str.starts(with: "meaning") {
      let components = str.components(separatedBy: ":")
      guard
        components.count == 2,
        let argu = components.last
      else { return nil }
      self = .meaning(argu)
    } else {
      return nil
    }
  }
}

class ColorCoordinator: StackCoordinator<ColorRoute> {
  override func prepare(to route: ColorRoute) -> ActionType<TransferType, ColorRoute> {
    switch route {
    case .color(let str):
      if isInitial {
        let viewController = ColorViewController(router: unownedRouter, color: str)
        return .transfer(.push(viewController))
      } else {
        return .transfer(.backToRoot())
      }
    case .meaning(let str):
      let viewController = ColorMeaningViewController(router: unownedRouter, meaning: str)
      return .transfer(.push(viewController))
    case .colors:
      return .transfer(.pop())
    case .settings:
      return .none
    case .general:
      return .none
    }
  }
}
