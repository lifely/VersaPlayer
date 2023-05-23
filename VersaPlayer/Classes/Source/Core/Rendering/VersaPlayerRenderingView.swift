//
//  VPlayerRenderingView.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import AVKit


open class VersaPlayerRenderingView: View {

  // MARK: - Properties

  /// VersaPlayer instance being rendered by renderingLayer
  public weak var handler: VersaPlayerView!

  // MARK: - Properties Overrides

  #if os(iOS)
  override open class var layerClass: AnyClass {
      return AVPlayerLayer.self
  }
  #endif

  // MARK: - Computed Properties -

  lazy public var playerLayer: AVPlayerLayer = {
     #if os(iOS)
        return layer as! AVPlayerLayer
     #else
      return AVPlayerLayer()
    #endif
  }()

  var layerObserver: NSKeyValueObservation?

  // MARK: - Initializers -

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Constructor
  ///
  /// - Parameters:
  ///     - player: VersaPlayer instance to render.
  public init(with handler: VersaPlayerView) {
    super.init(frame: CGRect.zero)

    self.handler = handler
    playerLayer.player = handler.player

//    layerObserver = playerLayer.observe(\.isReadyForDisplay, options: [.initial, .new], changeHandler: { [weak self] layer, value in
//      print("TestING RenderingView ReadyForDisplay; layer = \(layer); isReadyForDisplay = \(value.newValue ?? false)")
//      guard value.newValue == true else { return }
////      let start = CMTime(value: 001, timescale: 1)
////      self?.playerLayer.player?.seek(to: start, toleranceBefore: .zero, toleranceAfter: .zero) { success in
////           print("seek finished success = ", success)
////       }
//    })
  }

  // MARK: - CALayer (life-cycle) -

  #if os(macOS)

  override open func makeBackingLayer() -> CALayer {
    return playerLayer
  }

  #endif

  // MARK: - Memory Management && Deconstructions -

  deinit {
  }

}
