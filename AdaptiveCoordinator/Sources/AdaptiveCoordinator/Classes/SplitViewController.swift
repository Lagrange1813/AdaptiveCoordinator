//
//  SplitViewController.swift
//  
//
//  Created by Lagrange1813 on 2023/9/4.
//

import UIKit

public class InternalStackViewController: UINavigationController {
  
}

public class SplitViewController: UISplitViewController {
  lazy var primary = InternalStackViewController()
  lazy var secondary = InternalStackViewController()
  
  public init() {
    super.init(nibName: nil, bundle: nil)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    setViewController(primary, for: .primary)
    setViewController(secondary, for: .secondary)
  }
}
