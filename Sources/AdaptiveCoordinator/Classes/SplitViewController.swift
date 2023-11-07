//
//  SplitViewController.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import Combine
import UIKit

open class SplitViewController: UISplitViewController {
  private var _didAddViewController = PassthroughSubject<Void, Never>()
  private var _didRemoveViewController = PassthroughSubject<[UIViewController], Never>()
  
  public lazy var didAddViewController = _didAddViewController.eraseToAnyPublisher()
  public lazy var didRemoveViewController = _didRemoveViewController.eraseToAnyPublisher()
  
  public lazy var primary = StackViewController()
  public lazy var supplementary = StackViewController()
  public lazy var secondary = StackViewController()
  public lazy var compact = StackViewController()
  
  private var removingViewController: UIViewController?
  
  public var cancellables = Set<AnyCancellable>()
  
  public init() {
    super.init(style: .doubleColumn)
    configure()
    addSubscriber()
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure() {
    setViewController(primary, for: .primary)
    setViewController(secondary, for: .secondary)
//    setViewController(compact, for: .compact)
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

public class UniversalSplitViewController: SplitViewController, UISplitViewControllerDelegate {
  private var stackForExpanding: [UIViewController] = []
  
  override init() {
    super.init()
    delegate = self
  }
  
  public func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
    let viewControllers = secondary.viewControllers
    secondary.viewControllers = []
    primary.viewControllers.append(contentsOf: viewControllers)
    return .primary
  }
  
  public func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
    let count = primary.viewControllers.count
    if count > 1 {
      stackForExpanding.append(contentsOf: primary.viewControllers[1..<count])
      primary.viewControllers.removeSubrange(1..<count)
    }
    return preferredDisplayMode
  }
  
  public func splitViewControllerDidExpand(_ svc: UISplitViewController) {
    secondary.viewControllers.append(contentsOf: stackForExpanding)
    stackForExpanding.removeAll()
  }
}
