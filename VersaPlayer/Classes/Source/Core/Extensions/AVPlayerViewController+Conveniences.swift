//
//  AVPlayerViewController+Conveniences.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 22/05/2023.
//

import AVKit

public extension AVPlayerViewController {

  convenience init(player: AVPlayer, delegate: AVPlayerViewControllerDelegate? = nil) {
    self.init()
    self.player = player
    self.delegate = delegate
  }

}
