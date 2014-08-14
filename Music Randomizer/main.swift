//
//  main.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/7/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Cocoa

NSApplicationMain(C_ARGC, C_ARGV)

//
// converts a unicode string to ascii
//
// implemeneted as a global function because you can
//
func unicodeToAscii(str: String) -> String {
    
    // this technique doesn't change unicode [AE] => AE
    //    let ns = str as NSString
    //    let nsm = str.mutableCopy() as NSMutableString
    //    let cf = nsm as CFMutableString
    //    CFStringTransform(cf, nil, kCFStringTransformStripCombiningMarks, 0)
    
    // this works well for that wonderful Tool album we all love
    let data = str.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
    return NSString(data: data, encoding: NSASCIIStringEncoding)
    
}


//
// runs a block in the background asynchronously
//
func background(block: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        block()
    })
}


//
// runs a block in the foreground (ui thread) synchronously
//
func foreground(block: () -> Void) {
    // only use dispatch_sync if we're not on the main thread already
    if (NSThread.isMainThread()) {
        block()
    }
    else {
        dispatch_sync(dispatch_get_main_queue()) {
            block()
        }
    }
}

func formattedByteSize(size: Int) -> String {
    return NSByteCountFormatter.stringFromByteCount(Int64(size), countStyle: NSByteCountFormatterCountStyle.File)
}


extension String {
    //
    // Simple regex replace added to String, beacuse you can
    //
    // Note that it fails silently, skipping the replace if there is an error
    //
    func stringByReplacingRegularExpression(#pattern: String, withString string: String) -> String {
        var error: NSError?
        let regex = NSRegularExpression(pattern: "^\\[(\\d+)\\] ", options: nil, error: &error)
        if error == nil {
            let mutable = self.mutableCopy() as NSMutableString
            regex.replaceMatchesInString(mutable, options: nil, range: NSMakeRange(0, mutable.length), withTemplate: string)
            return mutable
        }
        else {
            return self
        }
    }
}
