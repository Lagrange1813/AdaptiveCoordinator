//
//  WeakRouter.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import Foundation

public class WeakErased<Value> {
  private var _valueBuilder: () -> Value?
  public var wrappedValue: Value? {
    _valueBuilder()
  }

  init(_ value: @escaping () -> Value?) {
    self._valueBuilder = value
  }

  init<Erasable: AnyObject>(_ erasable: Erasable, erase: @escaping (Erasable?) -> Value?) {
    self._valueBuilder = { [weak erasable] in erase(erasable) }
  }
}

public typealias WeakRouter<RouteType: Route> = WeakErased<StrongRouter<RouteType>>

extension WeakErased: Router where Value: Router {
  public typealias RouteType = Value.RouteType

  public func transfer(to route: RouteType) {
    wrappedValue?.transfer(to: route)
  }
}

public extension WeakRouter {
  ///
  /// Create a empty weak router.
  ///
  static func mock<RouteType: Route>() -> WeakRouter<RouteType> {
    let empty = EmptyRouter<RouteType>()
    return WeakRouter(empty, erase: { _ in nil })
  }
}
