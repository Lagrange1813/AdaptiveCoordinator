//
//  UnownedRouter.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import Foundation

public class UnownedErased<Value> {
  private var _valueBuilder: () -> Value
  public var wrappedValue: Value {
    _valueBuilder()
  }

  init(_ value: @escaping () -> Value) {
    self._valueBuilder = value
  }

  init<Erasable: AnyObject>(_ erasable: Erasable, erase: @escaping (Erasable) -> Value) {
    self._valueBuilder = { [unowned erasable] in erase(erasable) }
  }
}

public typealias UnownedRouter<RouteType: Route> = UnownedErased<StrongRouter<RouteType>>

extension UnownedErased: Router where Value: Router {
  public typealias RouteType = Value.RouteType

  public func transfer(to route: RouteType) {
    wrappedValue.transfer(to: route)
  }
}
