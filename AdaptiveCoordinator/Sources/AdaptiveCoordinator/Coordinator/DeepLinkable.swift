//
//  DeepLink.swift
//  
//
//  Created by Lagrange1813 on 2023/9/27.
//

import Foundation

public protocol DeepLinkable: Route {
  init?(link: String)
}
