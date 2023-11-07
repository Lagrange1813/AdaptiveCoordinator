//
//  NewsDetailViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/8.
//

import AdaptiveCoordinator
import UIKit

class NewsDetailViewController: UIViewController {
  let news: String
  let router: WeakRouter<NewsDetailRoute>
  
  init(
    _ news: String,
    router: WeakRouter<NewsDetailRoute>
  ) {
    self.news = news
    self.router = router
    super.init(nibName: nil, bundle: nil)
    configure()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    view.backgroundColor = .white
    
    title = news
    
    let infoBarButtonItem = UIBarButtonItem(
      image: UIImage(systemName: "info.circle"),
      style: .plain,
      target: self,
      action: #selector(infoBarButtonItemDidTouch)
    )
    navigationItem.rightBarButtonItem = infoBarButtonItem
  }
  
  @objc func infoBarButtonItemDidTouch() {
    router.transfer(to: .info)
  }
}
