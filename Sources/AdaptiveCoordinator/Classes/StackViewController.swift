//
//  StackViewController.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import Combine
import DequeModule
import UIKit

open class StackViewController: UINavigationController {
  var _didAddViewController = PassthroughSubject<Void, Never>()
  var _didRemoveViewController = PassthroughSubject<[UIViewController], Never>()
  
  public lazy var didAddViewController =
    _didAddViewController
      .eraseToAnyPublisher()
  
  public lazy var didRemoveViewController =
    _didRemoveViewController
      .eraseToAnyPublisher()
  
  ///
  /// The view controllers that are being popped or dismissed.
  ///
  private var removingViewControllers = Deque<UIViewController>()
  
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
    if let viewController = super.popViewController(animated: animated) {
      removingViewControllers.append(viewController)
    }
    executeAfterTransition(animated: animated) { [weak self] in
      if let viewController = self?.removingViewControllers.popFirst() {
        self?._didRemoveViewController.send([viewController])
      }
    }
    return nil
  }
  
  public func popViewController(
    animated: Bool,
    completion: VoidHandler? = nil
  ) {
    if let viewController = super.popViewController(animated: animated) {
      removingViewControllers.append(viewController)
    }
    executeAfterTransition(animated: animated) { [weak self] in
      if let viewController = self?.removingViewControllers.popFirst() {
        self?._didRemoveViewController.send([viewController])
        completion?()
      }
    }
  }
}

extension StackViewController: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    if let viewController = presentedViewController {
      removingViewControllers.append(viewController)
    }
  }
  
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if let viewController = removingViewControllers.popFirst() {
      _didRemoveViewController.send([viewController])
    }
  }
}

public extension StackViewController {
  func push(
    _ viewController: UIViewController,
    animated: Bool = true,
    completion: VoidHandler? = nil
  ) {
    pushViewController(viewController, animated: animated)
    executeAfterTransition(animated: animated) { [weak self] in
      self?._didAddViewController.send()
      completion?()
    }
  }

  func pop(animated: Bool = true, completion: VoidHandler? = nil) {
    popViewController(animated: animated, completion: completion)
  }
  
  override func present(_ viewController: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
    viewController.presentationController?.delegate = self
    super.present(viewController, animated: animated) { [weak self] in
      self?._didAddViewController.send()
      completion?()
    }
  }
  
  override func dismiss(animated: Bool = true, completion: VoidHandler? = nil) {
    let viewController = visibleViewController
    super.dismiss(animated: animated) { [weak self] in
      if let viewController {
        self?._didRemoveViewController.send([viewController])
        completion?()
      }
    }
  }
  
  func set(_ viewControllers: [UIViewController], completion: VoidHandler? = nil) {
    let removedViewControllers = self.viewControllers
    self.viewControllers = viewControllers
    DispatchQueue.main.async { [weak self] in
      if !removedViewControllers.isEmpty {
        self?._didRemoveViewController.send(removedViewControllers)
      }
      self?._didAddViewController.send()
      completion?()
    }
  }
}
