//
//  NewsCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/7.
//

import AdaptiveCoordinator
import Combine
import UIKit

enum NewsRoute: Route {
  case list
  
  case listRoute(NewsListRoute)
  case detailRoute(NewsDetailRoute)
  
  init?(deeplink: String) {
    nil
  }
}

class NewsCoordinator: SplitCoordinator<NewsRoute> {
  var cancellables = Set<AnyCancellable>()
  
  init(
    initialRoute: NewsRoute
  ) {
    super.init(
      strategy: .merge,
      initialRoute: initialRoute
    )
    
    basicViewController
      .didAddViewController
      .sink { [unowned self] in
        print(dump() + "\n")
      }
      .store(in: &cancellables)
    
    basicViewController
      .didRemoveViewController
      .sink { [unowned self] _ in
        print(dump() + "\n")
      }
      .store(in: &cancellables)
  }
  
  override func prepare(to route: NewsRoute) -> ActionType<SplitTransfer, NewsRoute> {
    switch route {
    case .list:
      if isInitial {
        let coordinator = NewsListCoordinator(
          basicViewController: primary,
          initialRoute: .list
        )
        pullback(subCoordinator: coordinator) {
          .listRoute($0)
        }
        return .transfer(.primary(.handover(coordinator)))
      } else {
        return .transfer(.dimiss())
      }
      
    // Pull-back
      
    case let .listRoute(route):
      switch route {
      case .list:
        return .none
        
      case .info:
        let viewController = NewsInfoViewController(unownedRouter)
        return .transfer(.present(viewController))
        
      case let .detail(str):
        let coordinator = NewsDetailCoordinator(
          basicViewController: secondary,
          initialRoute: .detail(str),
          isCollapsed: isCollapsed
        )
        pullback(subCoordinator: coordinator) {
          .detailRoute($0)
        }
        return .transfer(.secondary(.handover(coordinator)))
      }
      
    case let .detailRoute(route):
      switch route {
      case .detail:
        return .none
        
      case .additional:
        return .none
        
      case .info:
        let viewController = NewsInfoViewController(unownedRouter)
        return .transfer(.present(viewController))
      }
    }
  }
}
