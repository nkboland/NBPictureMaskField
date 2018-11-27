//==============================================================================
//  NBPictureMaskTestAutoFill.swift
//  NBPictureMaskField
//
//  Created by Nick Boland on 4/10/16.
//  Copyright © 2016 Nick Boland. All rights reserved.
//
//  GitHub: https://github.com/nkboland/NBPictureMaskField
//
//  OVERVIEW
//  --------
//  Test the auto fill feature of text input.
//==============================================================================

import XCTest
@testable import NBPictureMaskField

class NBPictureMaskTestAutoFill: XCTestCase {
//------------------------------------------------------------------------------

  override func setUp() {
  //----------------------------------------------------------------------------
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
  //----------------------------------------------------------------------------
  // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func test_basic() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("(###) ###-####")
    XCTAssertNil(maskVal.errMsg)
    pictureMask.setAutoFill(true)
    retVal = pictureMask.check("");                 XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(")
    retVal = pictureMask.check(" ");                XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(")
    retVal = pictureMask.check("(12");              XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(12")
    retVal = pictureMask.check("(123");             XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) ")
    retVal = pictureMask.check("(123) 4");          XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 4")
    retVal = pictureMask.check("(123) 45");         XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 45")
    retVal = pictureMask.check("(123) 456");        XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-")
    retVal = pictureMask.check("(123) 456-7");      XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-7")
    retVal = pictureMask.check("(123) 456-78");     XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-78")
    retVal = pictureMask.check("(123) 456-789");    XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-789")
    retVal = pictureMask.check("(123) 456-7890");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "(123) 456-7890")

    maskVal = pictureMask.setMask("[(###) ]###-####")
    XCTAssertNil(maskVal.errMsg)
    pictureMask.setAutoFill(true)
    retVal = pictureMask.check("");                 XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "")
    retVal = pictureMask.check(" ");                XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(")
    retVal = pictureMask.check("(12");              XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(12")
    retVal = pictureMask.check("(123");             XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) ")
    retVal = pictureMask.check("(123) 4");          XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 4")
    retVal = pictureMask.check("(123) 45");         XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 45")
    retVal = pictureMask.check("(123) 456");        XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-")
    retVal = pictureMask.check("(123) 456-7");      XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-7")
    retVal = pictureMask.check("(123) 456-78");     XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-78")
    retVal = pictureMask.check("(123) 456-789");    XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-789")
    retVal = pictureMask.check("(123) 456-7890");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "(123) 456-7890")
    retVal = pictureMask.check("1");                XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("12");               XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "12")
    retVal = pictureMask.check("123");              XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "123-")
    retVal = pictureMask.check("123-");             XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "123-")
    retVal = pictureMask.check("123-4");            XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "123-4")
    retVal = pictureMask.check("123-45");           XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "123-45")
    retVal = pictureMask.check("123-456");          XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "123-456")
    retVal = pictureMask.check("123-4567");         XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123-4567")
  }

}
