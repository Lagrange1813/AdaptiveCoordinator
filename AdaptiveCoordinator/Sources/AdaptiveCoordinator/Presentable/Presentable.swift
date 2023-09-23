//
//  Presentable.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

public protocol Presentable: AnyObject, Dumpable {
  var viewController: UIViewController { get }
  var presenter: (any Coordinator)? { get set }
}

private enum AssociatedKeys {
  static var coordinator: UInt8 = 0
}

extension UIViewController: Presentable {
  public var viewController: UIViewController { self }
  public weak var presenter: (any Coordinator)? {
    get {
      guard let box = objc_getAssociatedObject(self, &AssociatedKeys.coordinator) as? WeakBoxOfCoordinator else {
        return nil
      }
      return box.value
    }
    set(newValue) {
      let box = WeakBoxOfCoordinator(newValue)
      objc_setAssociatedObject(self, &AssociatedKeys.coordinator, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
