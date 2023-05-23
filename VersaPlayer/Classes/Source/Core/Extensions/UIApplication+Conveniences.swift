//
//  UIApplication+Conveniences.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 22/05/2023.
//

import UIKit

public extension UIApplication {

  func currentUIWindow() -> UIWindow? {
    let connectedScenes = connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .compactMap { $0 as? UIWindowScene }

    let window = connectedScenes.first?.windows.first { $0.isKeyWindow }

    return window
  }

  static func setRootViewVC(_ viewController: UIViewController){
    UIApplication.shared.currentUIWindow()?.rootViewController = viewController
  }

}
