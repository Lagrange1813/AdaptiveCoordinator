//
//  SettingsViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/2.
//

import AdaptiveCoordinator
import SwiftUI
import UIKit

class SettingsViewController: UIHostingController<SettingsView> {
  let router: UnownedRouter<SettingsRoute>

  init(_ router: UnownedRouter<SettingsRoute>) {
    self.router = router
    super.init(rootView: SettingsView(router: router))
    title = "Settings"
  }

  @available(*, unavailable)
  @MainActor dynamic required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

struct SettingsView: View {
  let router: UnownedRouter<SettingsRoute>

  var body: some View {
    List {
      Section(header: Text("General")) {
        Button {
          router.transfer(to: .general)
        } label: {
          Label("General", systemImage: "gear")
        }
      }

      Section(header: Text("About")) {
        Button {
          router.transfer(to: .about)
        } label: {
          Label("About", systemImage: "info.circle")
        }
      }
    }
    .listStyle(InsetGroupedListStyle())
  }
}

struct GeneralView: View {
  var body: some View {
    Text("General")
  }
}

struct AboutView: View {
  var body: some View {
    Text("About")
  }
}
