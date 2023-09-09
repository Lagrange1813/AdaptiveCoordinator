//
//  NewsCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/7.
//

import AdaptiveCoordinator
import UIKit

enum NewsRoute: Route {
  case list
  case day
  case news(String)
  case info
}

class NewsCoordinator: SplitCoordinator<NewsRoute> {
  init(basicViewController: SplitCoordinator<NewsRoute>.BasicViewControllerType = .init(), initialType: NewsRoute) {
    super.init(basicViewController: basicViewController, configure: { svc in
      svc.preferredSplitBehavior = .tile
      svc.preferredDisplayMode = .oneBesideSecondary
    }, initialType: initialType)
  }
  
  override func prepare(to route: NewsRoute) -> SplitTransfer {
    switch route {
    case .list:
      let viewController = NewsListViewController(unownedRouter)
      return .primary(.push(viewController, true))
    case .day:
      return .none
    case .news(let str):
      let viewController = NewsDetailViewController(str)
      return .secondary(.set(viewController))
    case .info:
      let viewController = NewsInfoViewController()
      return .present(viewController)
    }
  }
}
