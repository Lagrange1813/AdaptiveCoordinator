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
  
  deinit {
    print("ColorViewController Deinit\n")
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
    
    let meaningButton = UIButton()
    meaningButton.setTitle("Meaning", for: .normal)
    meaningButton.setTitleColor(.systemBlue, for: .normal)
    meaningButton.addTarget(self, action: #selector(meaningButtonDidTap), for: .touchUpInside)
    view.addSubview(meaningButton)
    meaningButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      meaningButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      meaningButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    
    let settingsButton = UIButton()
    settingsButton.setTitle("Settings", for: .normal)
    settingsButton.setTitleColor(.systemBlue, for: .normal)
    settingsButton.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
    view.addSubview(settingsButton)
    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      settingsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
    ])
  }
  
  func configureNavigationBar() {
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  @objc func meaningButtonDidTap() {
    router.transfer(to: .meaning(color + " Meaning"))
  }
  
  @objc func settingsButtonDidTap() {
    router.transfer(to: .settings)
  }
}
