//
//  NewsCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/7.
//

import AdaptiveCoordinator
import UIKit
import Combine

enum NewsRoute: Route {
  case list
  case day
  case news(String)
  case info
  case root
  
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
      let viewController = NewsListViewController(unownedRouter)
      return .primary(.push(viewController, true))
    case .day:
      return .none
    case .news(let str):
      let viewController = NewsDetailViewController(str)
      return .secondary(.set(viewController))
    case .info:
      let viewController = NewsInfoViewController(unownedRouter)
      return .present(viewController)
    case .root:
      return .dimiss()
    }
  }
}
