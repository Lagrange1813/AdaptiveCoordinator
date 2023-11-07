//
//  NewsDetailCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/10/22.
//

import AdaptiveCoordinator
import Combine
import Foundation

enum NewsDetailRoute: Route {
  case detail(String)
  case info
}

class NewsDetailCoordinator: StackCoordinator<NewsDetailRoute> {
  let isCollapsed: Bool
  
  init(
    basicViewController: StackViewController,
    initialRoute: NewsDetailRoute,
    isCollapsed: Bool
  ) {
    self.isCollapsed = isCollapsed
    
    super.init(
      basicViewController: basicViewController,
      initialRoute: initialRoute
    )
  }
  
  override func prepare(to route: NewsDetailRoute) -> ActionType<StackTransfer, NewsDetailRoute> {
    switch route {
    case .detail(let str):
      let viewController = NewsDetailViewController(str, router: weakRouter)
      return .transfer(isCollapsed ? .push(viewController) : .set([viewController]))
    case .info:
      return .none
    }
  }
}
