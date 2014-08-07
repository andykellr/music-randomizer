//
//  Music_RandomizerTests.swift
//  Music RandomizerTests
//
//  Created by Andy Keller on 8/7/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Cocoa
import XCTest
import Music_Randomizer

class Music_RandomizerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testEmptyList() {
        let list = SimpleList()
        XCTAssertEqual(list.count, 0, "List should have 0 entries")
        XCTAssertNil(list.head, "We should not have a head")
        XCTAssertNil(list.tail, "We should not have a tail")
    }
    
    func testAppend() {
        let list = SimpleList()
        list.append("1")
        XCTAssertEqual(list.count, 1, "List should have 1 entry")
        XCTAssertNotNil(list.head, "We should have a head")
        XCTAssertNotNil(list.tail, "We should have a tail")
    }
    
    func testIteration() {
        let list = SimpleList()
        list.append("1")
        list.append("2")
        XCTAssertEqual(list.count, 2, "List should have 2 entries")
        
        XCTAssertEqual("1", list.head!.value as String, "Head");
        XCTAssertEqual("2", list.tail!.value as String, "Tail");
        
        let iter = list.iterator()
        
        XCTAssertTrue(iter.hasNext(), "Should have next")
        let (oneValue: AnyObject, oneIndex) = iter.next()!
        XCTAssertEqual("1", oneValue as String, "One")
        XCTAssertEqual(0, oneIndex, "Index")
        
        XCTAssertTrue(iter.hasNext(), "Should have next")
        let (twoValue: AnyObject, twoIndex) = iter.next()!
        XCTAssertEqual("2", twoValue as String, "Two")
        XCTAssertEqual(1, twoIndex, "Index")
        
        XCTAssertFalse(iter.hasNext(), "Should not have next")
    }
    

    
}
