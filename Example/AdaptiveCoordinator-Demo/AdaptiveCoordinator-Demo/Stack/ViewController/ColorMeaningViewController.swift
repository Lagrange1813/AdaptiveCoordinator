//
//  ColorMeaningViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/6.
//

import AdaptiveCoordinator
import UIKit

class ColorMeaningViewController: UIViewController {
  let router: UnownedRouter<ColorRoute>
  let meaning: String
  
  init(router: UnownedRouter<ColorRoute>, meaning: String) {
    self.router = router
    self.meaning = meaning
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("ColorMeaningViewController Deinit\n")
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
    
    let backButton = UIButton()
    backButton.setTitle("Back", for: .normal)
    backButton.setTitleColor(.systemBlue, for: .normal)
    backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    view.addSubview(backButton)
    backButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      backButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  @objc func backButtonDidTap() {
    router.transfer(to: .color(nil))
  }
  
  @objc func settingsButtonDidTap() {
    router.transfer(to: .settings)
  }
}
