//==============================================================================
//  NBPictureMaskTestText.swift
//  NBPictureMaskField
//
//  Created by Nick Boland on 4/8/16.
//  Copyright © 2016 Nick Boland. All rights reserved.
//
//  GitHub: https://github.com/nkboland/NBPictureMaskField
//
//  OVERVIEW
//  --------
//  Test the text returned when setting the text.
//==============================================================================

import XCTest
@testable import NBPictureMaskField

import XCTest

class NBPictureMaskTestText: XCTestCase {
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

    maskVal = pictureMask.setMask("#")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("0");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "0")
    retVal = pictureMask.check("9");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "9")

    maskVal = pictureMask.setMask("?")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "a")
    retVal = pictureMask.check("z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "z")
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("Z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Z")

    maskVal = pictureMask.setMask("&")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Z")
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("Z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Z")

    maskVal = pictureMask.setMask("~")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "a")
    retVal = pictureMask.check("z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "z")
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "a")
    retVal = pictureMask.check("Z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "z")

    maskVal = pictureMask.setMask("@")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("0");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "0")
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "a")
    retVal = pictureMask.check("z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "z")
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("Z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Z")
    retVal = pictureMask.check("%");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "%")
    retVal = pictureMask.check("^");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "^")
    retVal = pictureMask.check("-");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "-")
    retVal = pictureMask.check("+");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "+")
    retVal = pictureMask.check(":");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == ":")

    maskVal = pictureMask.setMask("!")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("0");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "0")
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Z")
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("Z");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Z")
    retVal = pictureMask.check("%");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "%")
    retVal = pictureMask.check("^");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "^")
    retVal = pictureMask.check("-");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "-")
    retVal = pictureMask.check("+");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "+")
    retVal = pictureMask.check(":");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == ":")
  }

  func test_literal() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask(";#");    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("#");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "#")

    maskVal = pictureMask.setMask(";;");    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check(";");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == ";")

    maskVal = pictureMask.setMask(";,");    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check(",");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == ",")

    maskVal = pictureMask.setMask(";#;&");  XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("#&");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "#&")

    maskVal = pictureMask.setMask(";[;]");  XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("[]");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "[]")

    maskVal = pictureMask.setMask(";{;}");  XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("{}");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "{}")
  }


  func test_simple() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("Red");   XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("R");        XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "R")
    retVal = pictureMask.check("Re");       XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "Re")
    retVal = pictureMask.check("RE");       XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "Re")
    retVal = pictureMask.check("Red");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Red")
    retVal = pictureMask.check("RED");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Red")
  }

  func test_repetition() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("&*&")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("AB");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("ab");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")

    maskVal = pictureMask.setMask("&*~")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("AB");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Ab")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("ab");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Ab")

    maskVal = pictureMask.setMask("!*!")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("12");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "12")
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("AB");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("ab");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")
    retVal = pictureMask.check("Abc123");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "ABC123")
  }

  func test_grouping() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("&*{&}")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("AB");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")
    retVal = pictureMask.check("ABc");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "ABC")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("ab");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")
    retVal = pictureMask.check("abC");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "ABC")

    maskVal = pictureMask.setMask("{#,&}*#")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("12");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "12")
    retVal = pictureMask.check("123");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("a1");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1")
    retVal = pictureMask.check("a12");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A12")

    maskVal = pictureMask.setMask("{#,&}*{#,&}")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("12");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "12")
    retVal = pictureMask.check("123");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("a1");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1")
    retVal = pictureMask.check("a12");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A12")
    retVal = pictureMask.check("a1b");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1B")
    retVal = pictureMask.check("a1b2");     XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1B2")
    retVal = pictureMask.check("a1b2c3");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1B2C3")
    retVal = pictureMask.check("1a2b3c");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1A2B3C")

    maskVal = pictureMask.setMask("[+,-]#*#[.*#]")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("+1");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "+1")
    retVal = pictureMask.check("+1.");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "+1.")
    retVal = pictureMask.check("-1.0");     XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "-1.0")
    retVal = pictureMask.check("123.456");  XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123.456")
  }

  func test_grouping_group() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("&*{&}")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("A");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("AB");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")
    retVal = pictureMask.check("ABc");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "ABC")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("ab");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "AB")
    retVal = pictureMask.check("abC");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "ABC")

    maskVal = pictureMask.setMask("{#,&}*#")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("12");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "12")
    retVal = pictureMask.check("123");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("a1");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1")
    retVal = pictureMask.check("a12");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A12")

    maskVal = pictureMask.setMask("{#,&}*{#,&}")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("1");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1")
    retVal = pictureMask.check("12");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "12")
    retVal = pictureMask.check("123");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123")
    retVal = pictureMask.check("a");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A")
    retVal = pictureMask.check("a1");       XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1")
    retVal = pictureMask.check("a12");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A12")
    retVal = pictureMask.check("a1b");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1B")
    retVal = pictureMask.check("a1b2");     XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1B2")
    retVal = pictureMask.check("a1b2c3");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A1B2C3")
    retVal = pictureMask.check("1a2b3c");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1A2B3C")
  }

  func test_grouping_optional() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("{R[ed],G[reen],B[lue]}")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("R");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "R")
    retVal = pictureMask.check("Re");       XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "Re")
    retVal = pictureMask.check("Red");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Red")
    retVal = pictureMask.check("G");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "G")
    retVal = pictureMask.check("Gr");       XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "Gr")
    retVal = pictureMask.check("Green");    XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Green")
    retVal = pictureMask.check("B");        XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "B")
    retVal = pictureMask.check("Bl");       XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "Bl")
    retVal = pictureMask.check("Blu");      XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "Blu")
    retVal = pictureMask.check("Blue");     XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "Blue")
  }

  func test_optional_nested() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("[[#]&-]###[&]")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("123");      XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123")
    retVal = pictureMask.check("123a");     XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "123A")
    retVal = pictureMask.check("a-123");    XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A-123")
    retVal = pictureMask.check("a-123a");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "A-123A")
    retVal = pictureMask.check("1a-123");   XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1A-123")
    retVal = pictureMask.check("1a-123a");  XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "1A-123A")
  }

  func test_space_fill() {
  //----------------------------------------------------------------------------

    let pictureMask = NBPictureMask()
    var maskVal: NBPictureMask.MaskResult
    var retVal: NBPictureMask.CheckResult

    maskVal = pictureMask.setMask("(###) ###-####")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("");               XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "")
    retVal = pictureMask.check("(");              XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(")
    retVal = pictureMask.check(" ");              XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(")
    retVal = pictureMask.check("(123");           XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123")
    retVal = pictureMask.check(" 123");           XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123")
    retVal = pictureMask.check(" 123  456 ");     XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-")
    retVal = pictureMask.check(" 123  456 7890"); XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "(123) 456-7890")

    maskVal = pictureMask.setMask("[(###) ]###-####")
    XCTAssertNil(maskVal.errMsg)
    retVal = pictureMask.check("");               XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "")
    retVal = pictureMask.check("(");              XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(")
    retVal = pictureMask.check(" ");              XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(")
    retVal = pictureMask.check("(123");           XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123")
    retVal = pictureMask.check(" 123");           XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123")
    retVal = pictureMask.check(" 123  456 ");     XCTAssert(retVal.status == .okSoFar); XCTAssert(retVal.text == "(123) 456-")
    retVal = pictureMask.check(" 123  456 7890"); XCTAssert(retVal.status == .ok);      XCTAssert(retVal.text == "(123) 456-7890")
  }

}
