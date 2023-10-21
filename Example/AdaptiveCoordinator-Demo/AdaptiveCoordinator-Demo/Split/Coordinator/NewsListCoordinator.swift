//
//  NewsListCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/10/22.
//

import AdaptiveCoordinator
import Combine
import Foundation

enum NewsListRoute: Route {
  case list
  case info
  case detail(String)
}

class NewsListCoordinator: StackCoordinator<NewsListRoute> {
  override func prepare(to route: NewsListRoute) -> StackTransfer {
    switch route {
    case .list:
      let viewController = NewsListViewController(unownedRouter)
      return .push(viewController)
    case .info:
      return .none
    case .detail:
      return .none
    }
  }
}
