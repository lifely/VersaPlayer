//
//  File.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 18/05/2023.
//

import Foundation

public protocol VersaPlayerLogger: class {

  func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString,
               fileName: StaticString, lineNumber: Int, userInfo: [String: Any])

  func verbose(_ functionName: StaticString, fileName: StaticString, lineNumber: Int,
               userInfo: [String: Any], closure: () -> Any?)
//  func debug(_ closure: @autoclosure () -> Any?)

  func info(_ closure: @autoclosure () -> Any?, functionName: StaticString,
               fileName: StaticString, lineNumber: Int, userInfo: [String: Any])

  func info(_ functionName: StaticString, fileName: StaticString, lineNumber: Int,
               userInfo: [String: Any], closure: () -> Any?)

//  func notice(_ closure: @autoclosure () -> Any?)
//  func warning(_ closure: @autoclosure () -> Any?)
//  func error(_ closure: @autoclosure () -> Any?)

  func error(_ closure: @autoclosure () -> Any?, functionName: StaticString,
               fileName: StaticString, lineNumber: Int, userInfo: [String: Any])

  func error(_ functionName: StaticString, fileName: StaticString, lineNumber: Int,
               userInfo: [String: Any], closure: () -> Any?)

//  func severe(_ closure: @autoclosure () -> Any?)
//  func alert(_ closure: @autoclosure () -> Any?)
//  func emergency(_ closure: @autoclosure () -> Any?)

}

// MARK: - Defaults Implementations

extension VersaPlayerLogger {

  // MARK: - Verbose

  public func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function,
                      fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    return verbose(functionName, fileName: fileName,
                   lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }

//  public func verbose(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line,
//                      userInfo: [String: Any] = [:], closure: () -> Any?) {
//    return verbose(functionName: functionName, fileName: fileName,
//                   lineNumber: lineNumber, userInfo: userInfo, closure: closure)
//  }

  // MARK: - Info

  public func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function,
                      fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    return info(functionName, fileName: fileName,
                   lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }

//  public func info(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line,
//                      userInfo: [String: Any] = [:], closure: () -> Any?) {
//    return info(functionName: functionName, fileName: fileName,
//                   lineNumber: lineNumber, userInfo: userInfo, closure: closure)
//  }

  // MARK: - Error

  public func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function,
                      fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
    return error(functionName, fileName: fileName,
                 lineNumber: lineNumber, userInfo: userInfo, closure: closure)
  }

//  public func error(functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line,
//                      userInfo: [String: Any] = [:], closure: () -> Any?) {
//    return error(functionName: functionName, fileName: fileName,
//                   lineNumber: lineNumber, userInfo: userInfo, closure: closure)
//  }

}
