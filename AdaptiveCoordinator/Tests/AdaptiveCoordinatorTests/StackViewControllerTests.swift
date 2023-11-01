//
//  StackViewControllerTests.swift
//
//
//  Created by Lagrange1813 on 2023/10/16.
//

@testable import AdaptiveCoordinator
import XCTest

final class StackViewControllerTests: XCTestCase {
  func testPush() {
    let expectation = XCTestExpectation(description: "Push")
    
    let stack = StackViewController(rootViewController: UIViewController())
    let vc1 = UIViewController()
    stack.push(vc1, animated: false) {
      XCTAssertEqual(stack.viewControllers.count, 2)
      let vc2 = UIViewController()
      stack.push(vc2, animated: false) {
        XCTAssertEqual(stack.viewControllers.count, 3)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testContinuousPush() {
    let expectation = XCTestExpectation(description: "ContinuousPush")
    
    let stack = StackViewController(rootViewController: UIViewController())
    for _ in 0...10 {
      stack.push(UIViewController(), animated: false)
    }
    
    XCTAssertEqual(stack.viewControllers.count, 12)
    expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testPop() {
    let expectation = XCTestExpectation(description: "Pop")
    
    let stack = StackViewController(rootViewController: UIViewController())
    let vc1 = UIViewController()
    stack.push(vc1, animated: false) {
      XCTAssertEqual(stack.viewControllers.count, 2)
      stack.popViewController(animated: false) {
        XCTAssertEqual(stack.viewControllers.count, 1)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testContinuousPop() {
    let expectation = XCTestExpectation(description: "ContinuousPop")
    
    let stack = StackViewController(rootViewController: UIViewController())
    for _ in 0...10 {
      stack.push(UIViewController(), animated: false)
    }
    for _ in 0...10 {
      stack.pop(animated: false)
    }
    
    XCTAssertEqual(stack.viewControllers.count, 1)
    expectation.fulfill()
    
    wait(for: [expectation], timeout: 1.0)
  }
}
