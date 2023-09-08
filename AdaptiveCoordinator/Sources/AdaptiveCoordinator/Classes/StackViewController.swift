//
//  StackViewController.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import Combine
import UIKit

public class StackViewController: UINavigationController {
  public var didAddViewController = PassthroughSubject<Void, Never>()
  public var didRemoveViewController = PassthroughSubject<UIViewController, Never>()
  
  ///
  /// The view controller that is being popped or dismissed.
  ///
  private var removingViewController: UIViewController?
  
  /// https://stackoverflow.com/questions/12904410/completion-block-for-popviewcontroller
  private func executeAfterTransition(animated: Bool, completion: @escaping VoidHandler) {
    if let coordinator = transitionCoordinator, animated {
      coordinator.animate(alongsideTransition: nil, completion: { _ in
        completion()
      })
    } else {
      DispatchQueue.main.async {
        completion()
      }
    }
  }
  
  @discardableResult
  override public func popViewController(animated: Bool) -> UIViewController? {
    removingViewController = super.popViewController(animated: animated)
    executeAfterTransition(animated: animated) { [weak self] in
      if let viewController = self?.removingViewController {
        self?.didRemoveViewController.send(viewController)
        self?.removingViewController = nil
      }
    }
    return nil
  }
}

extension StackViewController: UIAdaptivePresentationControllerDelegate {
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

public extension StackViewController {
  func push(_ viewController: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
    pushViewController(viewController, animated: animated)
    executeAfterTransition(animated: animated) { [weak self] in
        self?.didAddViewController.send()
        completion?()
    }
  }

  func pop(animated: Bool = true, completion: VoidHandler? = nil) {
    popViewController(animated: animated)
  }
  
  override func present(_ viewController: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
    viewController.presentationController?.delegate = self
    super.present(viewController, animated: animated) { [weak self] in
      self?.didAddViewController.send()
      completion?()
    }
  }
  
  override func dismiss(animated: Bool = true, completion: VoidHandler? = nil) {
    let viewController = visibleViewController
    super.dismiss(animated: animated) { [weak self] in
      if let viewController {
        self?.didRemoveViewController.send(viewController)
        completion?()
      }
    }
  }
}
