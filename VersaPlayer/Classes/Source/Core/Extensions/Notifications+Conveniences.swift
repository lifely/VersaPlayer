//
//  Notifications+Conveniences.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 18/05/2023.
//

import Foundation

// MARK: - Notification Name
// MARK: - ExpressibleByStringLiteral

extension NSNotification.Name: ExpressibleByStringLiteral {

  public init(stringLiteral value: StringLiteralType) { self = .init(value) }

}

// MARK: - Notification Center
// MARK: - RawRepresentable

extension NotificationCenter {

  // MARK: - Configure Observers

  open func addObserver<Name: RawRepresentable>(_ observer: Any,
                                                selector aSelector: Selector, name aName: Name?,
                                                object anObject: Any?) where Name.RawValue == NSNotification.Name {
    addObserver(observer, selector: aSelector, name: aName?.rawValue, object: anObject)
  }

  @available(iOS 4.0, *)
  open func addObserver<Name: RawRepresentable>(forName name: Name?, object obj: Any?,
                                                queue: OperationQueue? = nil,
                                                using block: @escaping @Sendable (Notification) -> Void)
  -> NSObjectProtocol where Name.RawValue == NSNotification.Name {
    return addObserver(forName: name?.rawValue, object: obj, queue: queue, using: block)
  }

  // MARK: - Post Notifications

  open func post<Name: RawRepresentable>(name aName: Name, object anObject: Any?)
  where Name.RawValue == NSNotification.Name {
    return post(name: aName.rawValue, object: anObject)
  }

  open func post<Name: RawRepresentable>(name aName: Name, object anObject: Any?,
                                         userInfo aUserInfo: [AnyHashable : Any]? = nil)
  where Name.RawValue == NSNotification.Name {
    return post(name: aName.rawValue, object: anObject, userInfo: aUserInfo)
  }

  // MARK: - Remove Observers

  open func removeObserver<Name: RawRepresentable>(_ observer: Any, name aName: Name?, object anObject: Any? = nil)
  where Name.RawValue == NSNotification.Name {
    return removeObserver(observer, name: aName?.rawValue, object: anObject)
  }

}
