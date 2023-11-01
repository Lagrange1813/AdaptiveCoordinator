//
//  Displayable.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

public protocol Displayable: AnyObject, Dumpable {
  var viewController: UIViewController { get }
  var displayerID: UUID? { get set }
}

private enum AssociatedKeys {
  static var id: UInt8 = 0
}

extension UIViewController: Displayable {
  public var viewController: UIViewController { self }
  public var displayerID: UUID? {
    get {
      guard let id = objc_getAssociatedObject(self, &AssociatedKeys.id) as? UUID else {
        return nil
      }
      return id
    }
    set(newValue) {
      objc_setAssociatedObject(self, &AssociatedKeys.id, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
