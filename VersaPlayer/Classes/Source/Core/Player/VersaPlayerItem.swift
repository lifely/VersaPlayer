//
//  VPlayerItem.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import AVFoundation

open class VersaPlayerItem: AVPlayerItem {

  // MARK: - Properties

    /// whether content passed through the asset is encrypted and should be decrypted
    public var isEncrypted: Bool = false

  // MARK: - Computed Properties -

    public var audioTracks: [VersaPlayerMediaTrack] {
        return tracks(for: .audible)
    }
    
    public var videoTracks: [VersaPlayerMediaTrack] {
        return tracks(for: .visual)
    }
    
    public var captionTracks: [VersaPlayerMediaTrack] {
        return tracks(for: .legible)
    }

  // MARK: - Private Computations
    
  private func convert(with mediaSelectionOption: AVMediaSelectionOption,
                       group: AVMediaSelectionGroup) -> VersaPlayerMediaTrack {
    let title = mediaSelectionOption.displayName
    let language = mediaSelectionOption.extendedLanguageTag ?? "none"
    return VersaPlayerMediaTrack(name: title, language: language, option: mediaSelectionOption, group: group)
  }

  private func tracks(for characteristic: AVMediaCharacteristic) -> [VersaPlayerMediaTrack] {
    guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: characteristic) else {
      return []
    }

    let options = group.options
    let tracks = options.map { (option) -> VersaPlayerMediaTrack in
      return convert(with: option, group: group)
    }

    return tracks
  }
    
  public func currentMediaTrack(for characteristic: AVMediaCharacteristic) -> VersaPlayerMediaTrack? {
    guard let tracks = asset.mediaSelectionGroup(forMediaCharacteristic: characteristic),
          let currentTrack = currentMediaSelection.selectedMediaOption(in: tracks) else { return nil }

    return convert(with: currentTrack, group: tracks)
  }

  // MARK: - Memory Management & Deconstructions -

  deinit {
  }
    
}
