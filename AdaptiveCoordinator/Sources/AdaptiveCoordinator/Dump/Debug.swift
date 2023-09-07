//
//  Debug.swift
//
//
//  Created by Lagrange1813 on 2023/9/7.
//

import Foundation

class TestDump {
  var children: [TestDump] = []
  
  func debug() -> String {
    let prefix = children.isEmpty ? "-" : "▿"
    var res = "\(prefix) \(NSStringFromClass(Self.self))"
    let sub = children.reduce("") { r, n in
      r + "\n" + n.debug()
    }
    res += sub.indenting(by: 2)
    return res
  }
}

public func testDebug() {
  let root = TestDump()
  let left = TestDump()
  let left2 = TestDump()
  left.children = [left2]
  let right = TestDump()
  let rightleft = TestDump()
  right.children = [rightleft]
  root.children = [left, right]
  print(root.debug())
}

let example = """
-InfixOperatorExprSyntax
├─leftOperand: DeclReferenceExprSyntax
│ ╰─baseName: identifier("a")
├─operator: BinaryOperatorExprSyntax
│ ╰─operator: binaryOperator("+")
╰─rightOperand: DeclReferenceExprSyntax
  ╰─baseName: identifier("b")
"""

