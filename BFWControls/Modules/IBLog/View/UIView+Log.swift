//
//  UIView+Log.swift
//  BFWControls
//
//  Created by Tom Brodhurst-Hill on 14/10/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

public extension Optional where Wrapped: UIView {
    
    public var shortDescription: String {
        guard let self = self
            else { return "nil" }
        return self.shortDescription
    }
    
}

public extension UIView {
    
    @objc public var shortDescription: String {
        return "\(type(of: self)) \(Unmanaged.passUnretained(self).toOpaque()); frame = \(self.frame)"
    }
    
    public func recursiveDescription(indent: Int = 0) -> String {
        return String(repeating: "  ", count: indent)
            + "\(shortDescription)\n"
            + subviews
                .map { $0.recursiveDescription(indent: indent + 1) }
                .joined()
    }
    
}

public extension UILabel {
    
    public override var shortDescription: String {
        return super.shortDescription + "; text = \(self.text ?? "nil")"
    }
    
}