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
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
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
    
    let button = UIButton(configuration: .bordered())
    button.setTitle("Additional", for: .normal)
    button.addTarget(self, action: #selector(additionalButtonDidTouch), for: .touchUpInside)
    
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      button.widthAnchor.constraint(equalToConstant: 100),
      button.heightAnchor.constraint(equalToConstant: 50),
    ])
  }
  
  @objc func infoBarButtonItemDidTouch() {
    router.transfer(to: .info)
  }
  
  @objc func additionalButtonDidTouch() {
    router.transfer(to: .additional(news))
  }
}
