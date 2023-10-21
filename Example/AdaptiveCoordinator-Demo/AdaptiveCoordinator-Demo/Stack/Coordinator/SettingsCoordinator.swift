//
//  SettingsCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/6.
//

import AdaptiveCoordinator
import SwiftUI

// The default implementation provides `init?(rawValue: String)`
enum SettingsRoute: String, Route, DeepLinkable {
  case list
  case general
  case about
  
  init?(link: String) {
    self.init(rawValue: link)
  }
}

class SettingsCoordinator: StackCoordinator<SettingsRoute> {
  override func prepare(to route: SettingsRoute) -> TransferType {
    switch route {
    case .list:
      if isInitial {
        let viewController = SettingsViewController(unownedRouter)
        return .push(viewController)
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
