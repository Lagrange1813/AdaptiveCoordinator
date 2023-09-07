//
//  WeakBoxOfCoordinator.swift
//
//
//  Created by Lagrange1813 on 2023/9/5.
//

import Foundation

// Can't use WeakBox<T: AnyObject>.
final class WeakBoxOfCoordinator {
  weak var value: (any Coordinator)?
  init(_ value: (any Coordinator)?) {
    self.value = value
  }
}
