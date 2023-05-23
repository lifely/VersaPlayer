//
//  UIView+Layout.swift
//  VersaPlayer
//
//  Created by Julien Di Marco on 18/05/2023.
//

import Foundation

//extension NSLayoutAnchor {
//
//  open func test<Test: AnyObject>(_ identifier: String? = nil,
//                                              equalTo anchor: NSLayoutAnchor<Test>,
//                                              constant c: CGFloat) -> NSLayoutConstraint {
//    let constraint = self.constraint(equalTo: anchor, constant: c)
//    constraint.identifier = identifier
//  }
//
//}

extension NSLayoutAnchor {

  @objc func constrainEqual(identifier: String? = nil,
                            anchor: NSLayoutAnchor<AnchorType>, constant: CGFloat = 0) -> NSLayoutConstraint {
    var constraint = self.constraint(equalTo: anchor, constant: constant)
    constraint.identifier = identifier
    constraint.isActive = true

    return constraint
  }

}

internal extension UIView {

  // MARK: - Definitions -

  public var topAnchorIdentifier: String { "\(hash)-top-anchor" }
  public var leftAnchorIdentifier: String { "\(hash)-left-anchor" }

  public var rightAnchorIdentifier: String { "\(hash)-right-anchor" }
  public var bottomAnchorIdentifier: String { "\(hash)-bottom-anchor" }

  // MARK: - Layouts -

  /// Layout a view within another view stretching to edges
  ///
  /// - Parameters:
  ///     - view: The view to layout.
  ///     - into: The container view.
  internal func layout(view: View, into: View? = nil, constant: CGFloat? = nil) {
    guard let into = into else { return }

    if view.superview != into { into.addSubview(view) }
    view.translatesAutoresizingMaskIntoConstraints = false

    let topConstraint = view.topAnchor.constrainEqual(identifier: view.topAnchorIdentifier,
                                                      anchor: into.topAnchor, constant: constant ?? 0.0)
//    var topConstraint = view.topAnchor.constraint(equalTo: into.topAnchor, constant: constant ?? 0.0)
    view.leftAnchor.constrainEqual(identifier: view.leftAnchorIdentifier,
                                   anchor: into.leftAnchor, constant: constant ?? 0.0).isActive = true

    into.rightAnchor.constrainEqual(identifier: into.rightAnchorIdentifier,
                                    anchor:view.rightAnchor, constant: constant ?? 0.0).isActive = true
    into.bottomAnchor.constrainEqual(identifier: into.bottomAnchorIdentifier,
                                     anchor: view.bottomAnchor, constant: constant ?? 0.0).isActive = true
  }

  internal func stretchToEdges() {
    guard let parent = superview else { return }
    layout(view: self, into: parent)
  }

}
