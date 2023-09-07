//
//  StackViewController.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import Combine
import UIKit

public class StackViewController: UINavigationController {
  public var didPushViewController = PassthroughSubject<Void, Never>()
  public var didPopViewController = PassthroughSubject<UIViewController, Never>()
  
  public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    super.pushViewController(viewController, animated: animated)
    didPushViewController.send()
  }

  @discardableResult
  override public func popViewController(animated: Bool) -> UIViewController? {
    let viewController = super.popViewController(animated: animated)
    if let viewController {
      didPopViewController.send(viewController)
    }
    return viewController
  }
}

public extension StackViewController {
  func push(_ viewController: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
    pushViewController(viewController, animated: animated)
    completion?()
  }

  func pop(animated: Bool = true, completion: VoidHandler? = nil) {
    popViewController(animated: animated)
    completion?()
  }
}
