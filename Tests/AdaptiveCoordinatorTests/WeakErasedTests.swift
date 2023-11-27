//
//  WeakErasedTests.swift
//
//
//  Created by Lagrange1813 on 2023/11/27.
//

import XCTest
@testable import AdaptiveCoordinator

final class WeakErasedTests: XCTestCase {
  class Example {
    let number = 1
  }
  
  func test() throws {
    var example: Example = Example()
    print(CFGetRetainCount(example))
    let weakErasedExample = WeakErased<Example>(example) { example in
      return example
    }
    print(CFGetRetainCount(example))
    XCTAssertNotNil(weakErasedExample.wrappedValue?.number)
    example = Example()
    XCTAssertNil(weakErasedExample.wrappedValue?.number)
  }
}

