//
//  TransferType.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import UIKit
import SwiftUI

///
/// The type of transfer when the navigation controller transfers the view controller.
///
public enum TransferType {
  case push(UIViewController)
  case pop
  case present(UIViewController)
  case dimiss
  case backToRoot
  case none
}

public enum TargetType {
  case viewController(UIViewController)
  case view(any View)
}
