//
//  NewsListViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/8.
//

import UIKit
import AdaptiveCoordinator
import SwiftUI

class NewsListViewController: UIHostingController<NewsList> {
  let router: UnownedRouter<NewsListRoute>
  
  init(_ router: UnownedRouter<NewsListRoute>) {
    self.router = router
    super.init(rootView: NewsList(router: router))
    configure()
  }

  func configure() {
    title = "News"
  }
  
  @MainActor required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

struct NewsList: View {
  let router: UnownedRouter<NewsListRoute>
  
  var body: some View {
    List {
      ForEach(0..<10) { index in
        Button{
          router.transfer(to: .detail("News \(index)"))
        } label: {
          Text("News \(index)")
            .foregroundStyle(.black)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          router.transfer(to: .info)
        } label: {
          Image(systemName: "info.circle")
        }
      }
    }
  }
}
