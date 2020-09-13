//
//  MyTVAppTests.swift
//  MyTVAppTests
//
//  Created by Grecia Escárcega on 11/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import XCTest
@testable import MyTVApp

var sub: TVShowService!

class MyTVAppTests: XCTestCase {

    override func setUpWithError() throws {
        sub = TVShowService()
    }

    override func tearDownWithError() throws {
        sub = nil
        super.tearDown()
    }

    func testGetServiceWithConnection() throws {
        let expectation = self.expectation(description: "Scaling")
        var list: [TVShow]?
        TVShowService.get(page: 0) { (response) in
            list = response
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(list)
    }
    
    func testGetServiceNoConnection() throws {
        let expectation = self.expectation(description: "Scaling")
        var list: [TVShow]?
        TVShowService.get(page: 0) { (response) in
            list = response
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(list)
    }

}
