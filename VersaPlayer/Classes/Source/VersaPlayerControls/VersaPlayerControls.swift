//
//  VersaPlayerControls.swift
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
import AVFoundation
import AVKit

#if os(iOS)
import MediaPlayer
#endif

open class VersaPlayerControls: VersaControlsPassthroughView {

  // MARK: - Properties -

  /// VersaPlayer intance being controlled
  public weak var handler: VersaPlayerView!

  /// VersaPlayerControlsBehaviour being used to validate ui
  public var behaviour: VersaPlayerControlsBehaviour!

  /// VersaPlayerControlsCoordinator instance
  public weak var controlsCoordinator: VersaPlayerControlsCoordinator!

  /// Skip size in seconds to be used for skipping forward or backwards
  public var skipSize: Double = 30

  // MARK: - Interfaces Properties -

    #if os(iOS)
    public var airplayButton: MPVolumeView? = nil
    #endif

    /// VersaStatefulButton instance to represent the play/pause button
    @IBOutlet public weak var playPauseButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the fullscreen toggle button
    @IBOutlet public weak var fullscreenButton: VersaStatefulButton? = nil
    
    #if os(iOS)
    /// VersaStatefulButton instance to represent the PIP button
    @IBOutlet public weak var pipButton: VersaStatefulButton? = nil
    
    /// UIViewContainer to implement the airplay button
    @IBOutlet public weak var airplayContainer: UIView? = nil
    #endif
    
    /// VersaStatefulButton instance to represent the rewind button
    @IBOutlet public weak var rewindButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the forward button
    @IBOutlet public weak var forwardButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the skip forward button
    @IBOutlet public weak var skipForwardButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the skip backward button
    @IBOutlet public weak var skipBackwardButton: VersaStatefulButton? = nil
    
    /// VersaSeekbarSlider instance to represent the seekbar slider
    @IBOutlet public weak var seekbarSlider: VersaSeekbarSlider? = nil
    
    /// VersaTimeLabel instance to represent the current time label
    @IBOutlet public weak var currentTimeLabel: VersaTimeLabel? = nil
    
    /// VersaTimeLabel instance to represent the total time label
    @IBOutlet public weak var totalTimeLabel: VersaTimeLabel? = nil
    
    /// UIView to be shown when buffering
    @IBOutlet public weak var bufferingView: View? = nil

  // MARK: - Private Properties -

    private var wasPlayingBeforeRewinding: Bool = false
    private var wasPlayingBeforeForwarding: Bool = false
    private var wasPlayingBeforeSeeking: Bool = false

  //  MARK: - UIView (life-cycle) -
    
#if os(macOS)

  override open func viewDidMoveToSuperview() {
    super.viewDidMoveToSuperview()
    layoutInSuperview()
  }

#else

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    guard superview != nil else { return }
    layoutInSuperview()
  }

#endif
    
  public func layoutInSuperview() {
    guard let coordinator = superview as? VersaPlayerControlsCoordinator else { return }

    handler = coordinator.handler
    behaviour = behaviour ?? VersaPlayerControlsBehaviour(with: self)

    prepare()
  }
    
    /// Notifies when time changes
    ///
    /// - Parameters:
    ///     - time: CMTime representation of the current playback time
    open func timeDidChange(toTime time: CMTime) {
        currentTimeLabel?.update(toTime: time.seconds)
        totalTimeLabel?.update(toTime: handler.player.endTime().seconds)
        setSeekbarSlider(start: handler.player.startTime().seconds, end: handler.player.endTime().seconds, at: time.seconds)
        
        if !(handler.isSeeking || handler.isRewinding || handler.isForwarding) {
            behaviour.update(with: time.seconds)
        }
    }
    
    public func setSeekbarSlider(start startValue: Double, end endValue: Double, at time: Double) {
        let time = time.isNaN ? 0 : time
        let startValue = startValue.isNaN ? 0 : startValue
        let endValue = endValue.isNaN ? 0 : endValue
        
        #if os(macOS)
        seekbarSlider?.minValue = startValue
        seekbarSlider?.maxValue = endValue
        seekbarSlider?.doubleValue = time
        #elseif os(iOS)
        seekbarSlider?.minimumValue = Float(startValue)
        seekbarSlider?.maximumValue = Float(endValue)
        seekbarSlider?.value = Float(time)
        #else
        seekbarSlider?.progress = Float(time) / Float(endValue)
        #endif
    }
    
    /// Remove coordinator from player
    open func removeFromPlayer() {
        controlsCoordinator.removeFromSuperview()
    }
    
    /// Prepare controls targets and notification listeners
    open func prepare() {
        stretchToEdges()
        
        #if os(macOS)
        
        playPauseButton?.target = self
        playPauseButton?.action = #selector(togglePlayback(sender:))
        
        fullscreenButton?.target = self
        fullscreenButton?.action = #selector(toggleFullscreen(sender:))
        
        rewindButton?.target = self
        rewindButton?.action = #selector(rewindToggle(sender:))
        
        forwardButton?.target = self
        forwardButton?.action = #selector(forwardToggle(sender:))
        
        skipForwardButton?.target = self
        skipForwardButton?.action = #selector(skipForward(sender:))
        
        skipBackwardButton?.target = self
        skipBackwardButton?.action = #selector(skipBackward(sender:))
        
        prepareSeekbar()
        seekbarSlider?.target = self
        seekbarSlider?.action = #selector(playheadChanged(with:))
        preparePlaybackButton()
        #else
        
        playPauseButton?.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        
        fullscreenButton?.addTarget(self, action: #selector(toggleFullscreen), for: .touchUpInside)
        
        rewindButton?.addTarget(self, action: #selector(rewindToggle), for: .touchUpInside)
        
        forwardButton?.addTarget(self, action: #selector(forwardToggle), for: .touchUpInside)
        
        skipForwardButton?.addTarget(self, action: #selector(skipForward), for: .touchUpInside)
        skipBackwardButton?.addTarget(self, action: #selector(skipBackward), for: .touchUpInside)
        
        prepareSeekbar()
        
        #if os(iOS)

      pipButton?.inactiveImage = AVPictureInPictureController.pictureInPictureButtonStartImage
      pipButton?.activeImage = AVPictureInPictureController.pictureInPictureButtonStartImage

        if !AVPictureInPictureController.isPictureInPictureSupported() {
            pipButton?.alpha = 0.3
            pipButton?.isUserInteractionEnabled = false
        } else {
            pipButton?.addTarget(self, action: #selector(togglePip), for: .touchUpInside)
        }
        
        airplayButton = MPVolumeView()
        airplayButton?.showsVolumeSlider = false
        airplayContainer?.addSubview(airplayButton!)
        airplayContainer?.clipsToBounds = false
        airplayButton?.frame = airplayContainer?.bounds ?? CGRect.zero
        
        seekbarSlider?.addTarget(self, action: #selector(playheadChanged(with:)), for: .valueChanged)
        seekbarSlider?.addTarget(self, action: #selector(seekingEnd), for: .touchUpInside)
        seekbarSlider?.addTarget(self, action: #selector(seekingEnd), for: .touchUpOutside)
        seekbarSlider?.addTarget(self, action: #selector(seekingStart), for: .touchDown)
        
        #endif
        
        #endif
        
        prepareNotificationListener()
    }
    
    #if os(macOS)
    
    /// Layout in parent view
    open override func layout() {
        super.layout()
        stretchToEdges()
    }
    
    #else
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        stretchToEdges()
    }
    
    #endif


    /// Detect the notfication listener
    private func checkOwnershipOf(object: Any?, completion: @autoclosure ()->()?) {
      guard let ownerPlayer = object as? VersaPlayer else { return }
      if ownerPlayer.isEqual(handler?.player) {
        completion()
      }
    }

  /// Prepares the notification observers/listeners
  open func prepareNotificationListener() {
    NotificationCenter.default.addObserver(forName: VersaPlayerNotifications.assetLoaded,
                                           object: nil, queue: OperationQueue.main) {
      @MainActor [weak self] (notification) in
      guard let self = self else { return }
      self.checkOwnershipOf(object: notification.object, completion: self.prepareSeekbar())
    }

    NotificationCenter.default.addObserver(forName: VersaPlayerNotifications.timeChanged,
                                           object: nil, queue: OperationQueue.main) {
      @MainActor [weak self] (notification) in
      guard let self = self else { return }
      if let time = notification.userInfo?[VersaPlayer.VPlayerNotificationInfoKey.time.rawValue] as? CMTime {
        self.checkOwnershipOf(object: notification.object, completion: self.timeDidChange(toTime: time))
      }
    }

    NotificationCenter.default.addObserver(forName: VersaPlayerNotifications.didEnd,
                                           object: nil, queue: OperationQueue.main) {
      @MainActor [weak self] (notification) in
      guard let self = self else { return }
      self.checkOwnershipOf(object: notification.object, completion: self.playPauseButton?.set(active: false))
    }

    NotificationCenter.default.addObserver(forName: VersaPlayerNotifications.play,
                                           object: nil, queue: OperationQueue.main) {
      @MainActor [weak self]  (notification) in
      guard let self = self else { return }
      self.checkOwnershipOf(object: notification.object, completion: self.playPauseButton?.set(active: true))
    }

    NotificationCenter.default.addObserver(forName: VersaPlayerNotifications.pause,
                                           object: nil, queue: OperationQueue.main) {
      @MainActor [weak self] (notification) in
      guard let self = self else { return }
      self.checkOwnershipOf(object: notification.object, completion: self.playPauseButton?.set(active: false))
    }

    NotificationCenter.default.addObserver(forName: VersaPlayerNotifications.endBuffering,
                                           object: nil, queue: OperationQueue.main) {
      @MainActor [weak self] (notification) in
      guard let self = self else { return }
      self.checkOwnershipOf(object: notification.object, completion: self.hideBuffering())
    }

    NotificationCenter.default.addObserver(forName: VersaPlayerNotifications.buffering,
                                           object: nil, queue: OperationQueue.main) {
      @MainActor [weak self] (notification) in
      guard let self = self else { return }
      self.checkOwnershipOf(object: notification.object, completion: self.showBuffering())
    }
  }
    
  /// Prepare the seekbar values
  open func prepareSeekbar() {
    guard let player = handler.player, player.currentItem != nil else { return }

    setSeekbarSlider(start: player.startTime().seconds, end: player.endTime().seconds,
                     at: player.currentTime().seconds)
  }
    
    /// Show buffering view
    open func showBuffering() {
        bufferingView?.isHidden = false
    }
    
    /// Hide buffering view
    open func hideBuffering() {
        bufferingView?.isHidden = true
    }
    
    /// Skip forward (n) seconds in time
    @IBAction open func skipForward(sender: Any? = nil) {
        let time = handler.player.currentTime() + CMTime(seconds: skipSize, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        handler.player.seek(to: time)
    }
    
    /// Skip backward (n) seconds in time
    @IBAction open func skipBackward(sender: Any? = nil) {
        let time = handler.player.currentTime() - CMTime(seconds: skipSize, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        handler.player.seek(to: time)
    }
    
    /// End seeking
    @IBAction open func seekingEnd(sender: Any? = nil) {
        handler.isSeeking = false
        if wasPlayingBeforeSeeking {
            handler.play()
        }
    }
    
    /// Start Seeking
    @IBAction open func seekingStart(sender: Any? = nil) {
        wasPlayingBeforeSeeking = handler.isPlaying
        handler.isSeeking = true
        handler.pause()
    }
    
    
    #if os(macOS)
    
    /// Playhead changed in NSSlider
    ///
    /// - Parameters:
    ///     - sender: NSSlider that updated
    @IBAction open func playheadChanged(with sender: NSSlider) {
        handler.pause()
        handler.isSeeking = true
        let value = sender.doubleValue
        let time = CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        handler.player.seek(to: time)
        behaviour.update(with: time.seconds)
    }
    
    #elseif os(iOS)
    
    /// Playhead changed in UISlider
    ///
    /// - Parameters:
    ///     - sender: UISlider that updated
    @IBAction open func playheadChanged(with sender: UISlider) {
        handler.isSeeking = true
        let value = Double(sender.value)
        let time = CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        handler.player.seek(to: time)
        behaviour.update(with: time.seconds)
    }
    
    /// Toggle PIP mode
    @IBAction open func togglePip() {
        handler.setNativePip(enabled: !handler.isPipModeEnabled)
    }
    
    #endif
    
    /// Toggle fullscreen mode
    @IBAction open func toggleFullscreen(sender: Any? = nil) {
        fullscreenButton?.set(active: !handler.isFullscreenModeEnabled)
        handler.setFullscreen(enabled: !handler.isFullscreenModeEnabled)
    }
    
    /// Toggle playback
    @IBAction open func togglePlayback(sender: Any? = nil) {
        if handler.isRewinding || handler.isForwarding {
            handler.player.rate = 1
            playPauseButton?.set(active: true)
            return;
        }
        if handler.isPlaying {
            playPauseButton?.set(active: false)
            handler.pause()
        } else {
            if handler.playbackDelegate?.playbackShouldBegin(player: handler.player) ?? true {
                playPauseButton?.set(active: true)
                handler.play()
            }
        }
    }
    
    private func preparePlaybackButton(){
        if handler.isPlaying {
            playPauseButton?.set(active: true )
        } else {
            playPauseButton?.set(active: false)
        }
    }
    
    /// Toggle rewind
    @IBAction open func rewindToggle(sender: Any? = nil) {
        if handler.player.currentItem?.canPlayFastReverse ?? false {
            if handler.isRewinding {
                rewindButton?.set(active: false)
                handler.player.rate = 1
                if wasPlayingBeforeRewinding {
                    handler.play()
                } else {
                    handler.pause()
                }
            } else {
                playPauseButton?.set(active: false)
                rewindButton?.set(active: true)
                wasPlayingBeforeRewinding = handler.isPlaying
                if !handler.isPlaying {
                    handler.play()
                }
                handler.player.rate = -1
            }
        }
    }
    
    /// Forward toggle
    @IBAction open func forwardToggle(sender: Any? = nil) {
        if handler.player.currentItem?.canPlayFastForward ?? false {
            if handler.isForwarding {
                forwardButton?.set(active: false)
                handler.player.rate = 1
                if wasPlayingBeforeForwarding {
                    handler.play()
                } else {
                    handler.pause()
                }
            } else {
                playPauseButton?.set(active: false)
                forwardButton?.set(active: true)
                wasPlayingBeforeForwarding = handler.isPlaying
                if !handler.isPlaying {
                    handler.play()
                }
                handler.player.rate = 2
            }
        }
    }

  // MARK: - Memory Management && Deconstructions

  deinit {
    NotificationCenter.default.removeObserver(self, name: VersaPlayerNotifications.play)
    NotificationCenter.default.removeObserver(self, name: VersaPlayerNotifications.pause)

    NotificationCenter.default.removeObserver(self, name: VersaPlayerNotifications.timeChanged)

    NotificationCenter.default.removeObserver(self, name: VersaPlayerNotifications.buffering)
    NotificationCenter.default.removeObserver(self, name: VersaPlayerNotifications.endBuffering)
  }

}
