//
//  String+Exts.swift
//
//
//  Created by Lagrange1813 on 2023/9/7.
//

import Foundation

extension String {
  func indenting(by count: Int) -> String {
    self.indenting(with: String(repeating: " ", count: count))
  }

  func indenting(with prefix: String) -> String {
    prefix.isEmpty ? self : "\(self.replacingOccurrences(of: "\n", with: "\n\(prefix)"))"
  }
}
