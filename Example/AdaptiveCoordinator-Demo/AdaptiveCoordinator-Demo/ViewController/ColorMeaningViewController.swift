//
//  ColorMeaningViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/6.
//

import UIKit
import AdaptiveCoordinator

class ColorMeaningViewController: UIViewController {
  let router: UnownedRouter<ColorRoute>
  let meaning: String
  
  init(router: UnownedRouter<ColorRoute>, meaning: String) {
    self.router = router
    self.meaning = meaning
    super.init(nibName: nil, bundle: nil)
  }
  
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
    
    let label = UILabel()
    label.text = meaning
    label.textColor = .label
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
    ])
    
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
  
  func configureNavigationBar() {
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  @objc func backButtonDidTap() {
    router.transfer(to: .root)
  }
}
