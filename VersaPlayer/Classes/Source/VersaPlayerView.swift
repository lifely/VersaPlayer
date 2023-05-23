//
//  VersaPlayerView.swift
//  VersaPlayerView Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import AVKit
import AVFoundation

import CoreMedia

#if os(macOS)
  import Cocoa
  public typealias View = NSView
  public protocol PIPProtocol {}
#elseif os(iOS)
  import UIKit
  public typealias View = UIView
  public typealias PIPProtocol = AVPictureInPictureControllerDelegate
#endif

open class VersaPlayerView: View {

  // MARK: - Properties

  /// AVPlayer used in VersaPlayer implementation
  public var player: VersaPlayer!

  /// VersaPlayerControls instance being used to display controls
  public var controls: VersaPlayerControls? = nil

  /// VersaPlayerRenderingView instance
  public var renderingView: VersaPlayerRenderingView!

  /// VersaPlayerControlsCoordinator instance
  public var coordinator: VersaPlayerControlsCoordinator!

  /// VersaPlayer extension dictionary
  public var extensions: [String: VersaPlayerExtension] = [:]

#if os(iOS)
  /// AVPictureInPictureController instance
  public var pipController: AVPictureInPictureController? = nil

  /// AVPlayerViewController instance
  public var fullScreenController: AVPlayerViewController? = nil
#endif

  // MARK: - Conforming Protocols

  /// Logger Instance; Conforming to `VersaPlayerLogger`
  public weak var playerLogger: VersaPlayerLogger? = nil

  /// VersaPlayerPlaybackDelegate instance
  public weak var playbackDelegate: VersaPlayerPlaybackDelegate? = nil
    
  /// VersaPlayerDecryptionDelegate instance to be used only when a VPlayer item with isEncrypted = true is passed
  public weak var decryptionDelegate: VersaPlayerDecryptionDelegate? = nil


  // MARK: - Computed Properties -

  /// Whether player is prepared
  public var ready: Bool = false

  /// Whether it should autoplay when adding a VPlayerItem
  public var autoplay: Bool = true

  /// Whether Player is currently playing
  public var isPlaying: Bool = false

  /// Whether Player is seeking time
  public var isSeeking: Bool = false

  /// Whether PIP Mode is enabled via pipController
  public var isPipModeEnabled: Bool = false

  /// Whether Player is presented in Fullscreen
  public var isFullscreenModeEnabled: Bool = false

  // MARK: - Computed Properties -

  /// Whether Player is Fast Forwarding
  public var isForwarding: Bool {
    return player.rate > 1.0
  }

  /// Whether Player is Rewinding
  public var isRewinding: Bool {
    return player.rate < 0.0
  }

  #if os(macOS)
  open override var wantsLayer: Bool {
    get { return true } set { }
  }
  #endif

  // MARK: - Privates Properties -

  /// VersaPlayer initial container
  private weak var nonFullscreenContainer: View!

  // MARK: - Initializers -

  public override init(frame: CGRect) {
    super.init(frame: frame)
    prepare()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    prepare()
  }

  // MARK: - Configurations -

  /// VersaPlayerControls instance to display controls in player, using VersaPlayerGestureRecieverView instance
  /// to handle gestures
  ///
  /// - Parameters:
  ///     - controls: VersaPlayerControls instance used to display controls
  ///     - gestureReciever: Optional gesture reciever view to be used to receive gestures
  public func use(controls: VersaPlayerControls, with gestureReciever: VersaPlayerGestureRecieverView? = nil) {
    self.controls = controls
    self.coordinator = VersaPlayerControlsCoordinator(handler: self, controls: controls,
                                                      gestureReciever: gestureReciever)

#if os(macOS)
    let parent = self.superview
    parent?.addSubview(coordinator, positioned: NSWindow.OrderingMode.above, relativeTo: renderingView)
#else
    addSubview(coordinator)
    bringSubviewToFront(coordinator)
#endif
  }

  /// Prepares the player to play
  open func prepare() {
      ready = true
      player = VersaPlayer()
      player.handler = self
      player.preparePlayerPlaybackDelegate()
      renderingView = VersaPlayerRenderingView(with: self)
      layout(view: renderingView, into: self, constant: -1)
  }

  // MARK: - Extensions Configurations -

  /// Add a VersaPlayerExtension instance to the current player
  ///
  /// - Parameters:
  ///     - ext: The instance of the extension.
  ///     - name: The name of the extension.
  open func addExtension(extension ext: VersaPlayerExtension, with name: String) {
    ext.player = self
    ext.prepare()
    extensions[name] = ext
  }
    
  /// Retrieves the instance of the VersaPlayerExtension with the name given
  ///
  /// - Parameters:
  ///     - name: The name of the extension.
  open func getExtension(with name: String) -> VersaPlayerExtension? {
    return extensions[name]
  }

  // MARK: - Players Actions -

  /// Sets the item to be played
  ///
  /// - Parameters:
  ///     - item: The VPlayerItem instance to add to player.
  open func set(item: VersaPlayerItem?) {
    if !ready {
      prepare()
    }

    player.replaceCurrentItem(with: item)
    if autoplay && item?.error == nil {
      play()
    }
  }

#if os(iOS)
  /// Enables or disables PIP when available (when device is supported)
  ///
  /// - Parameters:
  ///     - enabled: Whether or not to enable
  open func setNativePip(enabled: Bool) {
    if pipController == nil && renderingView != nil {
      pipController = AVPictureInPictureController(playerLayer: renderingView!.playerLayer, delegate: self)
    }

    if enabled {
      pipController?.startPictureInPicture()
    } else {
      pipController?.stopPictureInPicture()
    }
  }
#endif
    
  /// Enables or disables fullscreen
  ///
  /// - Parameters:
  ///     - enabled: Whether or not to enable
  open func setFullscreen(enabled: Bool) {
    guard isFullscreenModeEnabled != enabled else { return }
    defer { isFullscreenModeEnabled = enabled }

    guard enabled else {
      removeFromSuperview()
      layout(view: self, into: nonFullscreenContainer)
      return
    }

    /// TODO: Check windowns for multiple scenes applications
#if os(macOS)
    let _window = NSApplication.shared.keyWindow
#else
    let _window = UIApplication.shared.keyWindow
#endif

    guard let window = _window else { return }
    nonFullscreenContainer = superview
    removeFromSuperview()

#if os(macOS)
    layout(view: self, into: window.contentView)
#else
    layout(view: self, into: window)
#endif
  }

  open func nativeFullScreenPlayerController(enabled: Bool) {
    if fullScreenController == nil && player != nil {
      fullScreenController = AVPlayerViewController(player: player, delegate: self)
    }

    fullScreenController?.videoGravity = renderingView.playerLayer.videoGravity

    guard let fullScreenController = fullScreenController,
          let presentingWindow = window ?? UIApplication.shared.currentUIWindow() else { return }
    let rootViewController = presentingWindow.rootViewController

    if let presentedController = rootViewController?.presentedViewController {
      presentedController.present(fullScreenController, animated: true)
    } else {
      rootViewController?.present(fullScreenController, animated: true)
    }
  }

  /// Update controls to specified time
  ///
  /// - Parameters:
  ///     - time: Time to be updated to
  public func updateControls(toTime time: CMTime) {
      controls?.timeDidChange(toTime: time)
  }

  // MARK: - Actions && Events -

  /// Play
  @IBAction open func play(sender: Any? = nil) {
    guard playbackDelegate?.playbackShouldBegin(player: player) ?? true else { return }

    player.play()
    controls?.playPauseButton?.set(active: true)
    isPlaying = true
  }

  /// Pause
  @IBAction open func pause(sender: Any? = nil) {
    player.pause()
    controls?.playPauseButton?.set(active: false)
    isPlaying = false
  }

  /// Toggle Playback
  @IBAction open func togglePlayback(sender: Any? = nil) {
    isPlaying ? pause() : play()
  }

  // MARK: - Memory Management && Deconstructions

  deinit {
    coordinator = nil
    player.replaceCurrentItem(with: nil)
  }

}

// MARK: - Protocol && Extensions -

extension VersaPlayerView: PIPProtocol {
#if os(iOS)

  open func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    controls?.controlsCoordinator.isHidden = true
    isPipModeEnabled = true
  }

  open func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    playerLogger?.verbose("pictureInPictureControllerDidStartPictureInPicture;" +
                          " controller = \(pictureInPictureController)")
  }

  open func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    isPipModeEnabled = false
    controls?.controlsCoordinator.isHidden = false
  }

  open func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    playerLogger?.verbose("pictureInPictureControllerDidStopPictureInPicture;" +
                          " controller = \(pictureInPictureController)")
  }

  public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                         failedToStartPictureInPictureWithError error: Error) {
    playerLogger?.error("pictureInPictureController - failedToStartPictureInPictureWithError:" +
                        " \(error.localizedDescription)")
  }

  public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                         restoreUserInterfaceForPictureInPictureStopWithCompletionHandler
                                         completionHandler: @escaping (Bool) -> Void) {

  }

#endif
}

extension VersaPlayerView: AVPlayerViewControllerDelegate {



}
