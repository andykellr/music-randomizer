//
//  Extensions.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/22/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

extension String {
    //
    // Simple regex replace added to String, beacuse you can
    //
    // Note that it fails silently, skipping the replace if there is an error
    //
    func stringByReplacingRegularExpression(#pattern: String, withString string: String) -> String {
        var error: NSError?
        let regex = NSRegularExpression(pattern: pattern, options: nil, error: &error)
        if error == nil {
            let mutable = self.mutableCopy() as NSMutableString
            regex!.replaceMatchesInString(mutable, options: nil, range: NSMakeRange(0, mutable.length), withTemplate: string)
            return mutable
        }
        else {
            return self
        }
    }
}

extension NSURL {
    //
    // Simpler version of getResourceValue
    //
    func getResourceValue(forKey: String) -> AnyObject? {
        var value: AnyObject?
        var error: NSError?
        self.getResourceValue(&value, forKey: forKey, error: &error)
        if error == nil {
            return value
        }
        return nil
    }
    
    func getResourceBool(forKey: String, hasValue: Bool) -> Bool {
        if let b = getResourceValue(forKey) as? Bool {
            return b == hasValue
        }
        else {
            return false
        }
    }
    
}
