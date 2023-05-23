//
//  VersaPlayerControlsCoordinator.swift
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
import CoreMedia
import AVFoundation

open class VersaPlayerControlsCoordinator: View, VersaPlayerGestureRecieverViewDelegate {

  // MARK: - Properties -

  /// VersaPlayer instance being used
  public weak var handler: VersaPlayerView!

  /// VersaPlayerControls instance being used
  public weak var controls: VersaPlayerControls!

  /// VersaPlayerGestureRecieverView instance being used
  public var gestureReciever: VersaPlayerGestureRecieverView!

  // MARK: - Initializer -

  convenience init(handler: VersaPlayerView!, controls: VersaPlayerControls!,
                   gestureReciever: VersaPlayerGestureRecieverView!) {
    self.init()

    self.handler = handler
    self.controls = controls
    self.gestureReciever = gestureReciever

    controls.controlsCoordinator = self
  }

  // MARK: - UIView (life-cycle)

#if os(macOS)

  override open func viewDidMoveToSuperview() {
    super.viewDidMoveToSuperview()
    guard superview != nil else { return }
    configureView()
  }

  open override func layout() {
    super.layout()
    stretchToEdges()
  }

#else

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    guard superview != nil else { return }
    configureView()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    stretchToEdges()
  }

#endif

  // MARK: - Configurations -
    
  public func configureView() {
    if let controls = controls { addSubview(controls) }

    if gestureReciever == nil {
      gestureReciever = VersaPlayerGestureRecieverView(delegate: self)
#if os(macOS)
      addSubview(gestureReciever, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
#else
      addSubview(gestureReciever)
      sendSubviewToBack(gestureReciever)
#endif
    }

    stretchToEdges()
  }

  // MARK: - Actions && Events -
    
  /// Notifies when pinch was recognized
  ///
  /// - Parameters:
  ///     - scale: CGFloat value
  open func didPinch(with scale: CGFloat) {

  }
    
  /// Notifies when tap was recognized
  ///
  /// - Parameters:
  ///     - point: CGPoint at which tap was recognized
  open func didTap(at point: CGPoint) {
    if controls.behaviour.showingControls {
      controls.behaviour.hide()
    } else {
      controls.behaviour.show()
    }
  }

  /// Notifies when tap was recognized
  ///
  /// - Parameters:
  ///     - point: CGPoint at which tap was recognized
  open func didDoubleTap(at point: CGPoint) {
    if handler.renderingView.playerLayer.videoGravity == AVLayerVideoGravity.resizeAspect {
      handler.renderingView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    } else {
      handler.renderingView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    }
  }

  /// Notifies when pan was recognized
  ///
  /// - Parameters:
  ///     - translation: translation of pan in CGPoint representation
  ///     - at: initial point recognized
  open func didPan(with translation: CGPoint, initially at: CGPoint) {

  }
    
#if os(tvOS)
  /// Swipe was recognized
  ///
  /// - Parameters:
  ///     - direction: gestureDirection
  open func didSwipe(with direction: UISwipeGestureRecognizer.Direction) {

  }
#endif

  // MARK: - Memory Management & Deconstructions

  deinit {
  }

}
