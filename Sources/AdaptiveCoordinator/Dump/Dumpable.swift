//
//  Dumpable.swift
//
//
//  Created by Lagrange1813 on 2023/9/7.
//

import UIKit

public protocol Dumpable {
  func dump() -> String
}

extension UIViewController: Dumpable {
  public func dump() -> String {
    "- \(NSStringFromClass(Self.self))"
  }
}

public extension Coordinator {
  func dump() -> String {
    let prefix = children.isEmpty ? "-" : "▿"
    var res = "\(prefix) \(NSStringFromClass(Self.self))"
    let sub = children.reduce("") { r, n in
      r + "\n" + n.dump()
    }
    res += sub.indenting(by: 2)
    return res
  }
}
