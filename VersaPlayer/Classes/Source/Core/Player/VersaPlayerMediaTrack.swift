//
//  VersaPlayerMediaTrack.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/30/18.
//

import Foundation
import AVFoundation

public struct VersaPlayerMediaTrack {

  // MARK: - Properties -

  public var name: String
  public var language: String

  public var option: AVMediaSelectionOption
  public var group: AVMediaSelectionGroup

  // MARK: - Conveniences

  public func select(for player: VersaPlayer) {
    player.currentItem?.select(option, in: group)
  }

}
