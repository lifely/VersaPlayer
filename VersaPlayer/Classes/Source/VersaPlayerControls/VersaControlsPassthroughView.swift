//
//  VersaControlsPassthroughView.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 18/05/2023.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import AVFoundation
import AVKit

#if os(iOS)
import MediaPlayer
#endif

open class VersaControlsPassthroughView: UIView {

#if os(macos)

  open override func hitTest(_ point: NSPoint) -> NSView? {
    let view = super.hitTest(point)
    return view == self || !(view is NSControl) ? nil : view
  }

#else

  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    return view == self || !(view is UIControl) ? nil : view
  }

#endif

}
