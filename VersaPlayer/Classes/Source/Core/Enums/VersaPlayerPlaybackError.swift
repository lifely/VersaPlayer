//
//  VersaPlayerPlaybackError.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/23/18.
//

import Foundation

public enum VersaPlayerPlaybackError: Swift.Error {
  case unknown
  case notFound
  case unauthorized
  case authenticationError
  case forbidden
  case unavailable
  case mediaFileError
  case bandwidthExceeded
  case playlistUnchanged
  case decoderMalfunction
  case decoderTemporarilyUnavailable
  case wrongHostIP
  case wrongHostDNS
  case badURL
  case invalidRequest
}

// MARK: - Initializers -

public extension VersaPlayerPlaybackError {

  init(_ error: NSError) {
    switch error.code {
      case -12937:
        self = .authenticationError
      case -16840:
        self = .unauthorized
      case -12660:
        self = .forbidden
      case -12938:
        self = .notFound
      case -12661:
        self = .unavailable
      case -12645, -12889:
        self = .mediaFileError
      case -12318:
        self = .bandwidthExceeded
      case -12642:
        self = .playlistUnchanged
      case -12911:
        self = .decoderMalfunction
      case -12913:
        self = .decoderTemporarilyUnavailable
      case -1004:
        self = .wrongHostIP
      case -1003:
        self = .wrongHostDNS
      case -1000:
        self = .badURL
      case -1202:
        self = .invalidRequest

      default: self = .unknown
    }
  }

}
