//
//  UIHostingController+Exts.swift
//
//
//  Created by Lagrange1813 on 2023/9/6.
//

import SwiftUI

public extension UIHostingController {
  convenience init(@ViewBuilder _ viewBuilder: () -> Content) {
    self.init(rootView: viewBuilder())
  }
}
