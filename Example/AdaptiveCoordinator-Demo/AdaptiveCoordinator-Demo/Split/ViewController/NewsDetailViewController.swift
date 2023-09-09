//
//  NewsDetailViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/8.
//

import UIKit
import AdaptiveCoordinator

class NewsDetailViewController: UIViewController {
  let news: String
  
  init(_ news: String) {
    self.news = news
    super.init(nibName: nil, bundle: nil)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    view.backgroundColor = .white
    
    title = news
  }
}
