//
//  SettingsViewController.swift
//  AdaptiveCoordinator-Demo
//
//  Created by Lagrange1813 on 2023/9/2.
//

import SwiftUI
import UIKit

class SettingsViewController: UIHostingController<SettingsView> {
  init() {
    super.init(rootView: SettingsView())
    title = "Settings"
  }

  @available(*, unavailable)
  @MainActor dynamic required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

struct SettingsView: View {
  var body: some View {
    List {
      Section(header: Text("General")) {
        Button {} label: {
          Label("General", systemImage: "gear")
        }
      }

      Section(header: Text("About")) {
        Button {} label: {
          Label("About", systemImage: "info.circle")
        }
      }
    }
    .listStyle(InsetGroupedListStyle())
  }
}
