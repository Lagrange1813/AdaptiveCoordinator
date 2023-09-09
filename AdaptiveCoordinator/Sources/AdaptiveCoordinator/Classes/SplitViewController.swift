//
//  SplitViewController.swift
//  
//
//  Created by Lagrange1813 on 2023/9/4.
//

import UIKit
import Combine

public class InternalStackViewController: StackViewController {
  func set(_ viewController: UIViewController, completion: VoidHandler? = nil) {
    viewControllers = [viewController]
    DispatchQueue.main.async {
      completion?()
    }
  }
}

public class SplitViewController: UISplitViewController {
  public var didAddViewController = PassthroughSubject<Void, Never>()
  public var didRemoveViewController = PassthroughSubject<UIViewController, Never>()
  
  lazy var primary = InternalStackViewController()
  lazy var secondary = InternalStackViewController()
  lazy var compact = InternalStackViewController()
  
  private var removingViewController: UIViewController?
  
  public init() {
    super.init(style: .doubleColumn)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    setViewController(primary, for: .primary)
    setViewController(secondary, for: .secondary)
    setViewController(compact, for: .compact)
  }
}

extension SplitViewController: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    removingViewController = presentedViewController
  }
  
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if let viewController = removingViewController {
      didRemoveViewController.send(viewController)
      removingViewController = nil
    }
  }
}

extension SplitViewController {
  public override func present(_ viewController: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
    viewController.presentationController?.delegate = self
    super.present(viewController, animated: animated) { [weak self] in
      self?.didAddViewController.send()
      completion?()
    }
  }
  
  public override func dismiss(animated: Bool = true, completion: VoidHandler? = nil) {
    let viewController = presentedViewController
    super.dismiss(animated: animated) { [weak self] in
      if let viewController {
        self?.didRemoveViewController.send(viewController)
        completion?()
      }
    }
  }
}
