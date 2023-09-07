//
//  UnownedRouter.swift
//  
//
//  Created by Lagrange1813 on 2023/9/4.
//

import UIKit

public class UnownedErased<Value> {
  private var _valueBuilder: () -> Value
  
  init(_ value: @escaping () -> Value) {
    self._valueBuilder = value
  }
  
  init<Erasable: AnyObject>(_ erasable: Erasable,  erase: @escaping (Erasable) -> Value) {
    self._valueBuilder = { [unowned erasable] in erase(erasable) }
  }
  
  public lazy var wrappedValue: Value = _valueBuilder()
}

//public class UnownedRouter<RouteType: Route, BasicViewControllerType: UIViewController>: UnownedErased<StrongRouter<RouteType>>, Router {
//  init(_ coordinator: BaseCoordinator<RouteType, BasicViewControllerType>) {
//    super.init(coordinator, erase: { $0.strongRouter })
//  }
//  
//  public func transfer(to route: RouteType) {
//    wrappedValue.transfer(to: route)
//  }
//}

public typealias UnownedRouter<RouteType: Route> = UnownedErased<StrongRouter<RouteType>>

extension UnownedErased: Router where Value: Router {
  public typealias RouteType = Value.RouteType
  
  public func transfer(to route: RouteType) {
    wrappedValue.transfer(to: route)
  }
}
