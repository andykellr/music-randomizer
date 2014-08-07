//
//  PlaylistFiles.swift
//  MusicToGo
//
//  Created by Andy Keller on 8/2/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

class PlaylistFiles {
    
    let files: SimpleList
    let randoms: [Int]!
    let subfolderCount: Int
    let destinationPath: String
    
    init(files: SimpleList, destinationPath: String, subfolderCount: Int) {
        self.files = files
        self.destinationPath = destinationPath
        self.subfolderCount = subfolderCount
        self.randoms = generateRandoms(files.count)
    }
    
    var count: Int {
        return files.count
    }
    
    func digits(num: Int) -> Int {
        return Int(log10(Float(num))) + 1
    }
    
    func pad(num: Int) -> String {
        return pad(num, width: digits(count))
    }
    func pad(num: Int, width: Int) -> String {
        var str = String(num)
        while (countElements(str) < width) {
            str = "0" + str
        }
        return str
    }
    
    func randomIndex(ceiling: Int) -> Int {
        return Int(arc4random_uniform(UInt32(ceiling)))
    }
    
    func generateRandoms(count: Int) -> [Int] {
        // start with a sequence
        var ret: [Int] = [Int](0..<count)
        
        // random shuffle
        for (var i=0; i<count; i++) {
            let x = randomIndex(count)
            let temp = ret[i]
            ret[i] = ret[x]
            ret[x] = temp
        }
        
        return ret;
    }

    // returns (src,dest,name)
    func getPaths(index: Int, file: String) -> (String,String,String) {
        let random = randoms[index]
        let name = file.lastPathComponent
        
        // 1-based folder name with 0-padding
        let folderNumber = pad(random % subfolderCount + 1, width: digits(subfolderCount))
        
        // consecutive numbers in each folder
        let fileNumber = pad((random - random % subfolderCount) / subfolderCount + 1, width: digits(count / subfolderCount))
        
        // for the destination, we use a random folder, a random prefix, and the ascii filename.
        // this avoids files with UTF8 characters which don't currently work well with the Tesla.
        let asciiName = unicodeToAscii(name)
        let dest = "\(destinationPath)/Randomizer \(folderNumber)/[\(fileNumber)] \(asciiName)"

        NSLog("\(file) - \(name)")
        
        return (file, dest, name)
    }
    
    
    
}
