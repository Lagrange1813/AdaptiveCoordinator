//
//  ColorListCoordinator.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/2.
//

import AdaptiveCoordinator
import Combine
import Foundation

// 比色卡
enum ColorListRoute: Route, DeepLinkable {
  case list
  case newList
  case color(String)
  case settings
  case info
  
  indirect case newListRoute(ColorListRoute)
  case colorRoute(ColorRoute)
  
  init?(link: String) {
    self.init(link)
  }
  
  init?(_ str: String) {
    if str == "list" {
      self = .list
    } else if str.starts(with: "color") {
      let components = str.components(separatedBy: ":")
      guard
        components.count == 2,
        let argu = components.last
      else { return nil }
      self = .color(argu)
    } else if str == "settings" {
      self = .settings
    } else if str == "info" {
      self = .info
    } else {
      return nil
    }
  }
}

class ColorListCoordinator: StackCoordinator<ColorListRoute> {
  let isRoot: Bool
  let level: Int
  var cancellables = Set<AnyCancellable>()
  
  init(
    isRoot: Bool = false,
    level: Int,
    basicViewController: StackCoordinator<ColorListRoute>.BasicViewControllerType = .init(),
    initialRoute: ColorListRoute
  ) {
    self.isRoot = isRoot
    self.level = level
    
    super.init(
      basicViewController: basicViewController,
      initialRoute: initialRoute
    )
    
    if isRoot {
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
  }
  
  override func prepare(to route: ColorListRoute) -> ActionType<TransferType, ColorListRoute> {
    switch route {
    case .list:
      if isInitial {
        let viewController = ColorListViewController(level: level, unownedRouter)
        return .transfer(.push(viewController))
      } else {
        return .transfer(.backToRoot())
      }
      
    case .newList:
      let coordinator = ColorListCoordinator(level: level + 1, basicViewController: basicViewController, initialRoute: .list)
      pullback(subCoordinator: coordinator) { .newListRoute($0) }
      return .transfer(.handover(coordinator))
      
    case let .color(str):
      let coordinator = ColorCoordinator(basicViewController: basicViewController, initialRoute: .color(str))
      pullback(subCoordinator: coordinator) {
        .colorRoute($0)
      }
      return .transfer(.handover(coordinator))
      
    case .settings:
      let coordinator = SettingsCoordinator(basicViewController: basicViewController, initialRoute: .list(true))
      return .transfer(.handover(coordinator))
      
    case .info:
      let viewController = InfoViewController(unownedRouter)
      return .transfer(.present(viewController))
      
    case let .newListRoute(route):
      if case let .colorRoute(colorRoute) = route {
        return .send(.colorRoute(colorRoute))
      }
      return .none
      
    case let .colorRoute(route):
      if isRoot {
        switch route {
        case .settings:
          drop(animated: false)
          // or use `return prepare(to: .settings)`
          let coordinator = SettingsCoordinator(basicViewController: basicViewController, initialRoute: .list(false))
          return .transfer(.handover(coordinator))

        case .general:
          print("General")
          return .none
          
        default:
          return .none
        }
      } else {
        return .none
      }
    }
  }
}
