//
//  NSAttributedString+TextAttributes.swift
//  BFWControls
//
//  Created by Tom Brodhurst-Hill on 1/5/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//  Free to use and modify, without warranty.
//

import Foundation

public extension NSAttributedString {
    
    func keepingTraitsAndColorButAdding(attributes: TextAttributes) -> NSAttributedString {
        return addingAttributes(attributes, isKeepingTraits: true, isKeepingColor: true)
    }
    
    func keepingTraitsButAdding(attributes: TextAttributes) -> NSAttributedString {
        return addingAttributes(attributes, isKeepingTraits: true, isKeepingColor: false)
    }

    func addingAttributes(
        _ attributes: TextAttributes,
        isKeepingTraits: Bool = false,
        isKeepingColor: Bool = false
        ) -> NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        enumerateAttributes(in: NSRange(location: 0, length: length), options: [])
        { (attributes, range, stop) in
            if isKeepingColor,
                let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor,
                ![UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1), .black].contains(color)
            {
                attributedString.addAttributes([NSAttributedString.Key.foregroundColor : color], range: range)
            }
            if isKeepingTraits,
                let font = attributes[NSAttributedString.Key.font] as? UIFont,
                !font.fontDescriptor.symbolicTraits.isEmpty,
                let oldFont = attributedString.attribute(NSAttributedString.Key.font,
                                                         at: range.location,
                                                         longestEffectiveRange: nil,
                                                         in: range) as? UIFont
            {
                let newFont = oldFont.addingSymbolicTraits(font.fontDescriptor.symbolicTraits)
                attributedString.addAttributes([NSAttributedString.Key.font : newFont], range: range)
            }
        }
        return NSAttributedString(attributedString: attributedString)
    }
    
}
