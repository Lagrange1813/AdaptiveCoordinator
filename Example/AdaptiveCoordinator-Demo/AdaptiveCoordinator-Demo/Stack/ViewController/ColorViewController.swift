//
//  ColorViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/3.
//

import UIKit
import AdaptiveCoordinator

class ColorViewController: UIViewController {
  let router: UnownedRouter<ColorRoute>
  let color: String
  
  init(router: UnownedRouter<ColorRoute>, color: String) {
    self.router = router
    self.color = color
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  func configure() {
    view.backgroundColor = .white
    
    title = color
    
    let button = UIButton()
    button.setTitle("Meaning", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.addTarget(self, action: #selector(meaningButtonDidTap), for: .touchUpInside)
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }
  
  func configureNavigationBar() {
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  @objc func meaningButtonDidTap() {
    router.transfer(to: .meaning(color + " Meaning"))
  }
}
