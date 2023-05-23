//
//  VersaPlayerControlsBehaviour.swift
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
import Foundation

open class VersaPlayerControlsBehaviour {

  // MARK: - Definitions -

  public typealias ActivationClosure = ((VersaPlayerControls) -> Void)

  // MARK: - Properties

  /// VersaPlayerControls instance being controlled
  public weak var controls: VersaPlayerControls!
    
  /// Whether controls are bieng displayed
  public var showingControls: Bool = true

  /// Whether controls should hide automatically
  public var shouldAutohide: Bool = true

  /// Whether controls should be hidden when showingControls is true
  public var shouldHideControls: Bool = true

  /// Whether controls should be shown when showingControls is false
  public var shouldShowControls: Bool = true

  /// Elapsed time between controls being shown and current time
  public var elapsedTime: TimeInterval = 0

  /// Last time when controls were shown
  public var activationTime: TimeInterval = 0

  /// At which TimeInterval controls hide automatically
  public var deactivationTimeInterval: TimeInterval = 3
    
  /// Custom deactivation block
  public var deactivationBlock: ActivationClosure? = nil

  /// Custom activation block
  public var activationBlock: ActivationClosure? = nil

  // MARK: - Initializers -
    
    /// Constructor
    ///
    /// - Parameters:
    ///     - controls: VersaPlayerControls to be controlled.
    public init(with controls: VersaPlayerControls) {
        self.controls = controls
    }

  // MARK: - Controls Behavior -

  /// Update ui based on time
  ///
  /// - Parameters:
  ///     - time: TimeInterval to check whether to update controls.
  open func update(with time: TimeInterval) {
    elapsedTime = time

    guard showingControls && shouldHideControls &&
            controls.handler.isPlaying &&
            controls.handler.isSeeking == false &&
            controls.handler.player.isBuffering == false else { return }

    let timediff = elapsedTime - activationTime
    guard timediff >= deactivationTimeInterval else { return }

    hide()
  }
    
  /// Hide the controls
  open func hide() {
    guard shouldAutohide == true else { return }

    let deactivtion: ActivationClosure = deactivationBlock ?? defaultDeactivationBlock
    deactivtion(controls)

    showingControls = false
  }

  /// Show the controls
  open func show() {
    guard shouldAutohide == true else { return }
    if shouldShowControls == false { return }

    activationTime = elapsedTime
    let activation: ActivationClosure = activationBlock ?? defaultActivationBlock
    activation(controls)

    showingControls = true
  }

  // MARK: - Memory Management && Deconstructions -

  deinit {
  }

}

// MARK: - Activation & DeActivation Defaults -

extension VersaPlayerControlsBehaviour {

  /// Default activation block
  open func defaultActivationBlock(_ controls: VersaPlayerControls) {
    controls.isHidden = false
#if os(macOS)
    controls.alphaValue = 1
#else
    UIView.animate(withDuration: 0.3) {
      self.controls.alpha = 1
    }
#endif
  }

  /// Default deactivation block
  open func defaultDeactivationBlock(_ controls: VersaPlayerControls) {
#if os(macOS)
    controls.alphaValue = 0
#else
    UIView.animate(withDuration: 0.3, animations: { self.controls.alpha = 0 },
                   completion: {
      guard $0 else { return }
      self.controls.isHidden = true
    })
#endif
  }


}
