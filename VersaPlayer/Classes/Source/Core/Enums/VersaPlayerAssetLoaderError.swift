//
//  VersaPlayerAssetLoaderError.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 18/05/2023.
//

import Foundation

public enum VersaPlayerAssetLoaderError: Swift.Error, CustomNSError {
  case loadingRequestURLUnavailable
  case loadingContentKeyContextUnavailable

  case requiredContentKeyUnavailable
  case requiredAssetCertificateUnavailable

  case contextKeyContextUnavailable

  // MARK: - CustomNSError

  public static var errorDomain: String { return "quasar.studio.versaPlayer.AssetLoaderError" }

  public var errorCode: Int {
    switch self {
      case .loadingRequestURLUnavailable: return -1
      case .loadingContentKeyContextUnavailable: return -4

      case .requiredContentKeyUnavailable: return -3
      case .requiredAssetCertificateUnavailable: return -2

      case .contextKeyContextUnavailable: return -5
    }
  }

  public var errorUserInfo: [String : Any] {
    var userInfo: [String: Any] = [:]

    guard let error = (self as? LocalizedError) else { return userInfo }

    userInfo[NSLocalizedDescriptionKey] = error.errorDescription
    userInfo[NSLocalizedFailureReasonErrorKey] = error.failureReason
    userInfo[NSLocalizedRecoverySuggestionErrorKey] = error.recoverySuggestion

    return userInfo
  }

}
