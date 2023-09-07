//
//  File.swift
//  
//
//  Created by Lagrange1813 on 2023/9/4.
//

import UIKit

///
/// The type of transfer when the navigation controller transfers the view controller.
///
public enum TransferType {
  case push(UIViewController)
  case pop
  case popToRoot
  case none
}

//public struct Transfer {
//  let type: TransferType
//  let viewController: UIViewController? = nil
//}
