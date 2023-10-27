//
//  NewsInfoViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/9.
//

import UIKit
import AdaptiveCoordinator

class NewsInfoViewController: UIViewController {
  let router: UnownedRouter<NewsRoute>
  
  init(_ router: UnownedRouter<NewsRoute>) {
    self.router = router
    super.init(nibName: nil, bundle: nil)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    view.backgroundColor = .systemRed
    
    let button = UIButton()
    button.setTitle("Back", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }
  
  @objc func backButtonDidTap() {
    router.transfer(to: .list)
  }
}
