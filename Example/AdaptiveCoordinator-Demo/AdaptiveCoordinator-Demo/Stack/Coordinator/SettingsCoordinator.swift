//
//  SettingsCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/6.
//

import AdaptiveCoordinator
import SwiftUI

enum SettingsRoute: Route {
  case list(Bool)
  case general
  case about
}

class SettingsCoordinator: StackCoordinator<SettingsRoute> {
  override func prepare(to route: SettingsRoute) -> TransferType {
    switch route {
    case let .list(animated):
      if isInitial {
        let viewController = SettingsViewController(unownedRouter)
        return .push(viewController, animated)
      } else {
        return .backToRoot()
      }
    case .general:
      let viewController = UIHostingController { GeneralView() }
      return .push(viewController)
    case .about:
      let viewController = UIHostingController { AboutView() }
      return .push(viewController)
    }
  }
}
