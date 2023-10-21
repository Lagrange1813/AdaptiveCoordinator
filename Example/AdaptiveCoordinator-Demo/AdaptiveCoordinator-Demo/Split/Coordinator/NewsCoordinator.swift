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
  case root
  
  case listRoute(NewsListRoute)
  case detailRoute(NewsDetailRoute)
  
  init?(deeplink: String) {
    nil
  }
}

class NewsCoordinator: SplitCoordinator<NewsRoute> {
  var cancellables = Set<AnyCancellable>()
  
  init(basicViewController: SplitCoordinator<NewsRoute>.BasicViewControllerType = .init(), initialRoute: NewsRoute) {
    super.init(basicViewController: basicViewController, configure: { svc in
      svc.preferredSplitBehavior = .tile
      svc.preferredDisplayMode = .oneBesideSecondary
    }, initialRoute: initialRoute)
    
    basicViewController.didAddViewController
      .sink { [unowned self] in
        print(dump() + "\n")
      }
      .store(in: &cancellables)
    
    basicViewController.didRemoveViewController
      .sink { [unowned self] _ in
        print(dump() + "\n")
      }
      .store(in: &cancellables)
  }
  
  override func prepare(to route: NewsRoute) -> SplitTransfer {
    switch route {
    case .list:
      let coordinator = NewsListCoordinator(basicViewController: basicViewController.primary, initialRoute: .list)
      pullback(subCoordinator: coordinator) {
        .listRoute($0)
      }
      return .primary(.handover(coordinator))
    case .root:
      return .dimiss()
      
    // Pull-back
      
    case let .listRoute(route):
      switch route {
      case .list:
        return .none
      case .info:
        let viewController = NewsInfoViewController(unownedRouter)
        return .present(viewController)
      case let .detail(str):
        let coordinator = NewsDetailCoordinator(basicViewController: basicViewController.secondary, initialRoute: .detail(str))
        pullback(subCoordinator: coordinator) {
          .detailRoute($0)
        }
        return .secondary(.handover(coordinator))
      }
      
    case let .detailRoute(route):
      switch route {
      case .detail:
        return .none
      case .info:
        let viewController = NewsInfoViewController(unownedRouter)
        return .present(viewController)
      }
    }
  }
}
