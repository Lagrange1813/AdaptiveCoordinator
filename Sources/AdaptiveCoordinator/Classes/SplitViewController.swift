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
  ///
  /// Internal use.
  ///
  lazy var compact = StackViewController()
  
  private var removingViewController: UIViewController?
  
  public var cancellables = Set<AnyCancellable>()
  
  // MARK: - Todo
  
  var willCollapse: (() -> Void)?
  var willExpand: (() -> Void)?
  
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
//    setViewController(supplementary, for: .supplementary)
    setViewController(secondary, for: .secondary)
    setViewController(compact, for: .compact)
  }
  
  func addSubscriber() {
    primary.didAddViewController
      .subscribe(_didAddViewController)
      .store(in: &cancellables)
    
    primary.didRemoveViewController
      .subscribe(_didRemoveViewController)
      .store(in: &cancellables)
    
    secondary.didAddViewController
      .subscribe(_didAddViewController)
      .store(in: &cancellables)
    
    secondary.didRemoveViewController
      .subscribe(_didRemoveViewController)
      .store(in: &cancellables)
    
    compact.didAddViewController
      .subscribe(_didAddViewController)
      .store(in: &cancellables)
    
    compact.didRemoveViewController
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
  private var primaryViewControllers: [UIViewController] = []
  private var secondaryViewControllers: [UIViewController] = []
  
  override init() {
    super.init()
    delegate = self

    preferredDisplayMode = .oneBesideSecondary
    preferredSplitBehavior = .tile
  }
  
  public func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
    var viewControllers: [UIViewController] = []
    
    let primaryViewControllers = primary.viewControllers
    primary.viewControllers = []
    viewControllers.append(contentsOf: primaryViewControllers)
    
    let secondaryViewControllers = secondary.viewControllers
    secondary.viewControllers = []
    viewControllers.append(contentsOf: secondaryViewControllers)
    
    for viewController in viewControllers {
      compact.push(viewController, animated: false)
    }
    
    willCollapse?()
    
    return .compact
  }
  
  public func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
    let count = compact.viewControllers.count
    
    if count > 1 {
      secondaryViewControllers.append(contentsOf: compact.viewControllers[1..<count])
      compact.viewControllers.removeSubrange(1..<count)
    }
    
    if count > 0 {
      primaryViewControllers.append(compact.viewControllers[0])
      compact.viewControllers.removeAll()
    }
    
    willExpand?()
    
    return preferredDisplayMode
  }
  
  public func splitViewControllerDidExpand(_ svc: UISplitViewController) {
    primary.viewControllers.append(contentsOf: primaryViewControllers)
    primaryViewControllers.removeAll()
    
    secondary.viewControllers.append(contentsOf: secondaryViewControllers)
    secondaryViewControllers.removeAll()
  }
}
