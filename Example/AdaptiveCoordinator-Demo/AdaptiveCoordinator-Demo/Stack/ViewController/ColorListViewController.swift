//
//  ColorListViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/2.
//

import AdaptiveCoordinator
import UIKit

class ColorListViewController: UIViewController {
  let level: Int
  let router: UnownedRouter<ColorListRoute>
  
  let colors = ["Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Violet"]
  lazy var tableView = UITableView()
  
  init(level: Int, _ router: UnownedRouter<ColorListRoute>) {
    self.level = level
    self.router = router
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("ColorListViewController Deinit\n")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  func configure() {
    view.backgroundColor = .white
    title = "Palette \(level)"
    
    let infoButton = UIBarButtonItem(title: "Info", primaryAction: UIAction { [unowned self] _ in
      router.transfer(to: .info)
    })
    navigationItem.leftBarButtonItem = infoButton
    
    let recursiveButton = UIBarButtonItem(title: "Recursive", primaryAction: UIAction { [unowned self] _ in
      router.transfer(to: .newList)
    })
    let settingsButton = UIBarButtonItem(title: "Settings", primaryAction: UIAction { [unowned self] _ in
      router.transfer(to: .settings)
    })
    navigationItem.rightBarButtonItems = [settingsButton, recursiveButton]
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
}

extension ColorListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return colors.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
    let color = colors[indexPath.row]
    cell.textLabel?.text = color
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let color = colors[indexPath.row]
    router.transfer(to: .color(color))
  }
}
