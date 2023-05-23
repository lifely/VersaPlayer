//
//  VersaPlayer.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - Module Definitions -

public typealias VersaPlayerNotifications = VersaPlayer.PlayerNotificationName

// MARK: - Player Definitions -

open class VersaPlayer: AVPlayer {

  // MARK: - Definitions -

  /// Dispatch queue for resource loader
  private let queue = DispatchQueue(label: "quasar.studio.versaplayer")

  /// AvPlayerItem KeyPath to be observed
  public static let playerItemPaths: [PartialKeyPath<AVPlayerItem>] = [\.status, \.isPlaybackLikelyToKeepUp,
                                                                        \.isPlaybackBufferFull, \.isPlaybackBufferEmpty]

  /// Notification key to extract info
  public enum VPlayerNotificationInfoKey: String {
    case time = "VERSA_PLAYER_TIME"
  }

  /// Notification name to post
  public enum PlayerNotificationName: NSNotification.Name {
    case assetLoaded = "VERSA_ASSET_ADDED"
    case timeChanged = "VERSA_TIME_CHANGED"
    case willPlay = "VERSA_PLAYER_STATE_WILL_PLAY"
    case play = "VERSA_PLAYER_STATE_PLAY"
    case pause = "VERSA_PLAYER_STATE_PAUSE"
    case buffering = "VERSA_PLAYER_BUFFERING"
    case endBuffering = "VERSA_PLAYER_END_BUFFERING"
    case didEnd = "VERSA_PLAYER_END_PLAYING"

    /// Notification name representation
    public var identifier: Self.RawValue { return self.rawValue }
  }

  // MARK: - Properties -

  /// VersaPlayer instance
  public weak var handler: VersaPlayerView!

  /// Caption text style rules
  lazy public var captionStyling: VersaPlayerCaptionStyling = {
    return VersaPlayerCaptionStyling(with: self)
  }()

  /// Whether player is buffering
  public var isBuffering: Bool = false

  // MARK: - Content Controls -

  /// Play content
  override open func play() {
    NotificationCenter.default.post(name: VersaPlayerNotifications.willPlay, object: self)
    guard (handler.playbackDelegate?.playbackShouldBegin(player: self) ?? true) else { return }

    NotificationCenter.default.post(name: VersaPlayerNotifications.play, object: self)
    super.play()
    handler.playbackDelegate?.playbackDidBegin(player: self)
  }

  /// Pause content
  override open func pause() {
    handler.playbackDelegate?.playbackWillPause(player: self)
    NotificationCenter.default.post(name: VersaPlayerNotifications.pause, object: self)
    super.pause()
    handler.playbackDelegate?.playbackDidPause(player: self)
  }

  // MARK: - Items Conveniences -

  /// Replace current item with a new one
  ///
  /// - Parameters:
  ///     - item: AVPlayer item instance to be added
  override open func replaceCurrentItem(with item: AVPlayerItem?) {
    if let asset = item?.asset as? AVURLAsset, let vitem = item as? VersaPlayerItem, vitem.isEncrypted {
      asset.resourceLoader.setDelegate(self, queue: queue)
    }

    removeObservers(for: currentItem)

    super.replaceCurrentItem(with: item)
    NotificationCenter.default.post(name: VersaPlayerNotifications.assetLoaded, object: self)

    addObservers(for: currentItem ?? item)
  }

  internal func removeObservers(for item: AVPlayerItem?, paths: [PartialKeyPath<AVPlayerItem>] = playerItemPaths) {
    guard let item = item else { return }

    paths.forEach({
      guard let kvcKeyPath = $0._kvcKeyPathString else { return }
      item.removeObserver(self, forKeyPath: kvcKeyPath)
    })
  }

  internal func addObservers(for item: AVPlayerItem?, paths: [PartialKeyPath<AVPlayerItem>] = playerItemPaths) {
    guard let item = item else { return }

    paths.forEach({
      guard let kvcKeyPath = $0._kvcKeyPathString else { return }
      item.addObserver(self, forKeyPath: kvcKeyPath, options: [.new], context: nil)
    })
  }

  // MARK: - Memory Management && Deconstructions -

  deinit {
    removeObservers(for: currentItem)
    removeObserver(self, forKeyPath: "status")

    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemTimeJumped, object: nil)
    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self)
    NotificationCenter.default.removeObserver(self, name: AVPlayerItem.timeJumpedNotification, object: nil)
  }

}

// MARK: - Player Extensions Conveniences -
// MARK: - Player Times Extensions -

extension VersaPlayer {

  /// Start time
  ///
  /// - Returns: Player's current item start time as CMTime
  open func startTime() -> CMTime {
    guard let item = currentItem else { return .zero }
    return item.reversePlaybackEndTime.isValid ? item.reversePlaybackEndTime : .zero
  }

  /// End time
  ///
  /// - Returns: Player's current item end time as CMTime
  open func endTime() -> CMTime {
    guard let item = currentItem else { return .zero }

    let durationTime = item.duration.isValid && !item.duration.isIndefinite ? item.duration : item.currentTime()
    return item.forwardPlaybackEndTime.isValid ? item.forwardPlaybackEndTime : durationTime
  }

}

// MARK: - Notification Center Observations -

extension VersaPlayer {

  /// Prepare players playback delegate observers
  open func preparePlayerPlaybackDelegate() {
    NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEnd),
                                           name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
    NotificationCenter.default.addObserver(self, selector: #selector(playerItemTimeJumped),
                                           name: .AVPlayerItemTimeJumped, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(playerItemTimeJumped),
                                           name: AVPlayerItem.timeJumpedNotification, object: nil)

    addPeriodicTimeObserver(forInterval: .one, queue: DispatchQueue.main) { [weak self] (time) in
      guard let self = self else { return }
      NotificationCenter.default.post(name: VersaPlayerNotifications.timeChanged, object: self,
                                      userInfo: [VPlayerNotificationInfoKey.time.rawValue: time])
      self.handler?.playbackDelegate?.timeDidChange(player: self, to: time)
    }

    addObserver(self, forKeyPath: "status", options: [.new], context: nil)
  }

  // MARK: - Notifications Functions

  @objc private func playerItemDidPlayToEnd(_ notification: Notification) {
    guard let item = notification.object as? AVPlayerItem, item == self.currentItem else { return }

    NotificationCenter.default.post(name: VersaPlayerNotifications.didEnd, object: self)
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.handler?.playbackDelegate?.playbackDidEnd(player: self)
    }
  }

  @objc private func playerItemTimeJumped(_ notification: Notification) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.handler?.playbackDelegate?.playbackDidJump(player: self)
    }
  }

}

// MARK: - KVO Observations -

extension VersaPlayer {

  // MARK: - Generic Key Value Observings -

  /// Key . Value . Observer (KVO) - listener
  override open func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                  change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let handler = handler else {
      return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    if let player = object as? VersaPlayer, player == self {
      return observePlayerValue(forKeyPath: keyPath, of: player, change: change, context: context)
    }

    if let playerItem = object as? VersaPlayerItem {
      return observePlayerItemValue(forKeyPath: keyPath, of: playerItem, change: change, context: context)
    }

    return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
  }

  // MARK: - Specifics Key Value Observings -

  open func observePlayerValue(forKeyPath keyPath: String?, of object: VersaPlayer?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let object = object, keyPath == "status" else {
      return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    let _status = (change?[.newKey] as? AVPlayer.Status) ?? object.status ?? status
    switch _status {
      case AVPlayer.Status.readyToPlay:
        NotificationCenter.default.post(name: VersaPlayerNotifications.timeChanged, object: self,
                                        userInfo: [VPlayerNotificationInfoKey.time.rawValue: CMTime.zero])
        handler.playbackDelegate?.playbackReady(player: self)

      case AVPlayer.Status.failed:
        handler.playbackDelegate?.playbackDidFailed(with: VersaPlayerPlaybackError.unknown)

      default:  break;
    }
  }

  open func observePlayerItemValue(forKeyPath keyPath: String?, of object: VersaPlayerItem?,
                                   change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let playerItem = object else {
      return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    switch keyPath {
      case .some("status"):
        guard let value = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: value) else {
          return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }

        if status == .failed, let error = playerItem.error as NSError?,
           let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
          let playbackError = VersaPlayerPlaybackError(underlyingError)
          handler.playbackDelegate?.playbackDidFailed(with: playbackError)
        }

        if status == .readyToPlay, let currentItem = self.currentItem as? VersaPlayerItem {
          handler.playbackDelegate?.playbackItemReady(player: self, item: currentItem)
        }

      case .some("playbackBufferEmpty"):
        isBuffering = true

        NotificationCenter.default.post(name: VersaPlayerNotifications.buffering, object: self)
        handler.playbackDelegate?.startBuffering(player: self)

      case .some("playbackBufferFull"):
        isBuffering = false

        NotificationCenter.default.post(name: VersaPlayerNotifications.endBuffering, object: self)
        handler.playbackDelegate?.endBuffering(player: self)

      case .some("playbackLikelyToKeepUp"):
        isBuffering = false

        NotificationCenter.default.post(name: VersaPlayerNotifications.endBuffering, object: self)
        handler.playbackDelegate?.endBuffering(player: self)

        guard  let item = self.currentItem as? VersaPlayerItem else { return  }
        NotificationCenter.default.post(name: VersaPlayerNotifications.timeChanged, object: self,
                                        userInfo: [VPlayerNotificationInfoKey.time.rawValue: item.currentTime()])

      default: break;
    }

  }

}

// MARK: - AVAssetResourceLoaderDelegate

extension VersaPlayer: AVAssetResourceLoaderDelegate {

  // MARK: - Errors Definitions -

  public typealias AssetLoaderError = VersaPlayerAssetLoaderError

  // MARK: - AVAssetResourceLoaderDelegate

  public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                             shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest)
  -> Bool {
    guard let url = loadingRequest.request.url else {
      handler?.playerLogger?.error("VersaPlayerResourceLoadingError :\(#function): Unable to read the url/host data.")
      loadingRequest.finishLoading(with: AssetLoaderError.loadingRequestURLUnavailable)
      return false
    }

    handler?.playerLogger?.info("VersaPlayerResourceLoading: \(url)")

    guard let certificateURL = handler.decryptionDelegate?.urlFor(player: self),
          let certificateData = try? Data(contentsOf: certificateURL) else {
      handler?.playerLogger?.error("VersaPlayerResourceLoadingError :\(#function):Unable to read the certificate data.")
      loadingRequest.finishLoading(with: AssetLoaderError.requiredAssetCertificateUnavailable)
      return false
    }

    let contentId = handler.decryptionDelegate?.contentIdFor(player: self) ?? ""
    guard let contentIdData = contentId.data(using: String.Encoding.utf8),
          let spcData = try? loadingRequest.streamingContentKeyRequestData(forApp: certificateData,
                                                                           contentIdentifier: contentIdData, options: nil),
          let dataRequest = loadingRequest.dataRequest else {
      loadingRequest.finishLoading(with: AssetLoaderError.requiredContentKeyUnavailable)
      handler?.playerLogger?.error("VersaPlayerResourceLoadingError :\(#function): Unable to read the SPC data.")
      return false
    }

    guard let ckcURL = handler.decryptionDelegate?.contentKeyContextURLFor(player: self) else {
      loadingRequest.finishLoading(with: AssetLoaderError.loadingContentKeyContextUnavailable)
      handler?.playerLogger?.error("VersaPlayerResourceLoadingError :\(#function): Unable to read the ckcURL.")
      return false
    }

    var request = URLRequest(url: ckcURL)
    request.httpMethod = "POST"
    request.httpBody = spcData

    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task = session.dataTask(with: request) { [weak self] data, response, error in
      guard let data = data else {
        self?.handler?.playerLogger?.error("VersaPlayerResourceLoadingError :\(#function): Unable to fetch the CKC.")
        loadingRequest.finishLoading(with: AssetLoaderError.contextKeyContextUnavailable)
        return
      }

      dataRequest.respond(with: data)
      loadingRequest.finishLoading()
    }
    task.resume()

    return true
  }

}
