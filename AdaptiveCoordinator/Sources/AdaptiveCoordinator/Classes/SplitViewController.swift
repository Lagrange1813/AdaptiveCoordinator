//
//  SplitViewController.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import Combine
import UIKit

public class InternalStackViewController: StackViewController {
  func set(_ viewController: UIViewController, completion: VoidHandler? = nil) {
    let removedViewControllers = viewControllers
    viewControllers = [viewController]
    DispatchQueue.main.async { [unowned self] in
      if !removedViewControllers.isEmpty {
        _didRemoveViewController.send(removedViewControllers)
      }
      _didAddViewController.send()
      completion?()
    }
  }
}

public class SplitViewController: UISplitViewController {
  private var _didAddViewController = PassthroughSubject<Void, Never>()
  private var _didRemoveViewController = PassthroughSubject<[UIViewController], Never>()
  
  public lazy var didAddViewController = _didAddViewController.eraseToAnyPublisher()
  public lazy var didRemoveViewController = _didRemoveViewController.eraseToAnyPublisher()
  
  public lazy var primary = InternalStackViewController()
  public lazy var secondary = InternalStackViewController()
  public lazy var compact = InternalStackViewController()
  
  private var removingViewController: UIViewController?
  
  public var cancellables = Set<AnyCancellable>()
  
  public init() {
    super.init(style: .doubleColumn)
    configure()
    addSubscriber()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    setViewController(primary, for: .primary)
    setViewController(secondary, for: .secondary)
    setViewController(compact, for: .compact)
  }
  
  func addSubscriber() {
    primary.didAddViewController
      .subscribe(_didAddViewController)
      .store(in: &cancellables)
    
    secondary.didAddViewController
      .subscribe(_didAddViewController)
      .store(in: &cancellables)
    
    primary.didRemoveViewController
      .subscribe(_didRemoveViewController)
      .store(in: &cancellables)
    
    secondary.didRemoveViewController
      .subscribe(_didRemoveViewController)
      .store(in: &cancellables)
  }
}

extension SplitViewController: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    removingViewController = presentedViewController
  }
  
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if let viewController = removingViewController {
      _didRemoveViewController.send([viewController])
      removingViewController = nil
    }
  }
}

public extension SplitViewController {
  override func present(_ viewController: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
    viewController.presentationController?.delegate = self
    super.present(viewController, animated: animated) { [weak self] in
      self?._didAddViewController.send()
      completion?()
    }
  }
  
  override func dismiss(animated: Bool = true, completion: VoidHandler? = nil) {
    let viewController = presentedViewController
    super.dismiss(animated: animated) { [weak self] in
      if let viewController {
        self?._didRemoveViewController.send([viewController])
        completion?()
      }
    }
  }
}
