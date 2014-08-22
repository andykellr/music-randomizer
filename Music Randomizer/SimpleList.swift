//
//  List.swift
//  MusicToGo
//
//  Created by Andy Keller on 8/3/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

//
// An extremely simple linked list. Only supports append, count, and iteration.
//
// Originally I was using [String] with append and for-in loops, but for 5,000 files,
// assembling the array took a long time (minutes)
//
public class SimpleList {
    
    public class Node {
        var next: Node?
        public var value: AnyObject
        
        init(value: AnyObject) {
            self.value = value
        }
    }
    
    public class Iterator {

        private var index: Int = 0
        private var current: Node?
        
        init(first: Node?) {
            self.current = first
        }
        
        public func hasNext() -> Bool {
            return current != nil
        }
        
        public func next() -> (value: AnyObject, index: Int)? {
            if let c = current {
                // get the value
                let value: AnyObject = c.value
                
                // advance the next pointer
                current = c.next
                
                return (value,index++)
            }
            else {
                return nil
            }
        }
        
    }

    public var head: Node?
    public var tail: Node?
    public var count: Int = 0

    public init() {}
    
    public func append(value: AnyObject) {
        let newNode = Node(value: value)
        if let t = tail {
            t.next = newNode
        }
        else {
            head = newNode
        }
        tail = newNode
        count++
    }
    
    public func iterator() -> Iterator {
        return Iterator(first: head)
    }
    
    public func clear() {
        head = nil
        tail = nil
        count = 0
    }
    
}