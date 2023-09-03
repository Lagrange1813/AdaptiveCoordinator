//
//  Coordinator.swift
//  
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit

protocol Coordinator: Router {
  associatedtype BasicViewControllerType
  var basicViewController: BasicViewControllerType { get }
  func navigate(to presentable: Presentable)
}
