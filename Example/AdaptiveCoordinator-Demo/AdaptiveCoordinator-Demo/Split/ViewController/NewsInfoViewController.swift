//
//  NewsInfoViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/9.
//

import UIKit

class NewsInfoViewController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    view.backgroundColor = .systemRed
  }
}
