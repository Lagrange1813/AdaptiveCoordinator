//
//  Presentable.swift
//
//
//  Created by Lagrange1813 on 2023/9/2.
//

import UIKit

public protocol Presentable {
  var viewController: UIViewController { get }
}

extension UIViewController: Presentable {
  public var viewController: UIViewController { self }
}
