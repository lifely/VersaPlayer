//
//  AVPictureInPictureController+Conveniences.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 18/05/2023.
//

import AVKit

public extension AVPictureInPictureController {

  convenience init?(playerLayer: AVPlayerLayer, delegate: AVPictureInPictureControllerDelegate?) {
    self.init(playerLayer: playerLayer)
    self.delegate = delegate
  }

}
