//
//  TransferType.swift
//
//
//  Created by Lagrange1813 on 2023/9/4.
//

import UIKit

public protocol Transfer {}

///
/// The type of transfer when the navigation controller transfers the view controller.
///
public enum StackTransfer: Transfer {
  case push(UIViewController, Bool = true)
  case pop(Bool = true)
  case present(UIViewController, Bool = true)
  case dimiss(Bool = true)
  case set([UIViewController])
  case backToRoot(Bool = true)
  case handover(any Coordinator)
}

public enum SplitTransfer: Transfer {
  public enum TransferType {
    case push(UIViewController, Bool = true)
    case pop(Bool = true)
    case set([UIViewController])
    case backToRoot(Bool = true)
    case handover(any Coordinator)
  }

  case primary(TransferType)
  case secondary(TransferType)
  case supplmentary(TransferType)
  case present(UIViewController, Bool = true)
  case dimiss(Bool = true)
  case none
}
