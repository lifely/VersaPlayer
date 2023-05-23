//
//  CMTime.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 18/05/2023.
//

import AVFoundation

extension CMTime {

  public static let one = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

  public static let zero = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

}
