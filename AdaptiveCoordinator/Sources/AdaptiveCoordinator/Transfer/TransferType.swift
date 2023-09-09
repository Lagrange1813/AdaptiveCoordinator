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
  case push(UIViewController)
  case pop
  case present(UIViewController)
  case dimiss
  case backToRoot
  case none
}

public enum SplitTransfer: Transfer {
  public enum TransferType {
    case push(UIViewController, Bool)
    case pop
    case set(UIViewController)
    case backToRoot
  }
  
  case primary(TransferType)
  case secondary(TransferType)
  case supplmentary(TransferType)
  case present(UIViewController)
  case dimiss
  case none
}

//public protocol _Transfer {}
//
//public struct _SplitTransferInfo: _Transfer {
//  enum _SplitTransferType {
//    case primary
//    case secondary
//    case supplmentary
//    case none
//  }
//  
//  let type: _SplitTransferType
//  let viewController: UIViewController? = nil
//  let animated: Bool = true
//}
