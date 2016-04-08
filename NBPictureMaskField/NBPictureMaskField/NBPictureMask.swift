//==============================================================================
//  NBPictureMask.swift
//  NBPictureMaskField
//  GitHub: https://github.com/nkboland/NBPictureMaskField
//
//  Created by Nick Boland on 3/27/16.
//  Copyright © 2016 Nick Boland. All rights reserved.
//
//------------------------------------------------------------------------------
//
//  OVERVIEW
//  --------
//
//  Mask -  This defines what the field will accept. Groups can be created
//          inside { }. These letters indicate the following format:
//
//            d = digits 0..9
//            D = anything other than 0..9
//            a = a..z, A..Z
//            W = anything other than a..z, A..Z
//            . = anything (default)
//
//            Examples
//            {dddd}-{DDDD}-{WaWa}-{aaaa}   would allow 0123-AbCd-0a2b-XxYy
//
//  Template -  This is used to fill in the mask for displaying.
//
//  Grouping Algorithm
//  ------------------
//
//  Each group...
//
//  The first group to be ok is the one.
//
//  Optional Algorithm
//  ------------------
//
//  TO DO
//  -----
//
//  1. Mask parsing returns status.
//  2. Auto fill implementation.
//  3. Text checking error message.
//  4. Capitalization and text replacement.
//
//==============================================================================

import Foundation

class NBPictureMask {
//------------------------------------------------------------------------------

  //--------------------
  // MARK: - Constants

  private struct kMask {
    static let digit          : Character = "#"
    static let letter         : Character = "?"
    static let letterToUpper  : Character = "&"
    static let letterToLower  : Character = "~"
    static let anyChar        : Character = "@"
    static let anyCharToUpper : Character = "!"
    static let escape         : Character = ";"
    static let repetition     : Character = "*"
    static let optional       : Character = "["
    static let optionalEnd    : Character = "]"
    static let grouping       : Character = "{"
    static let groupingEnd    : Character = "}"
    static let group          : Character = ","
  }

  //--------------------
  // MARK: - Types

  private enum NodeType {
  //----------------------------------------------------------------------------
  // A node must be one of these types.

    case
      Root,                                   //     Root node
      Digit,                                  //  #  Any digit 0..9
      Letter,                                 //  ?  Any letter a..z or A..Z
      LetterToUpper,                          //  &  Any letter a..z or A..Z converted to uppercase
      LetterToLower,                          //  ~  Any letter a..z or A..Z converted to lowercase
      AnyChar,                                //  @  Any character
      AnyCharToUpper,                         //  !  Any character converted to uppercase
      Literal,                                //  ;  Literal character
      Repeat,                                 //  *  Repeat any number of times - Example: *& or *3#
      Optional,                               //  [  Optional sequence of characters - Example: [abc]
      OptionalEnd,                            //  ]  Optional end
      Grouping,                               //  {  Grouping - Example: {R,G,B} or {R[ed],G[reen],B[lue]}
      GroupingEnd,                            //  }  Grouping end
      Group                                   //  ,  Group - Example: {Group1,Group2}
  }

  private struct Node {
  //----------------------------------------------------------------------------

    var type    : NodeType = .Root            // Node type indicates how it should be handled
    var value   : Int = 0                     // Repeat (count)
    var literal : Character = " "             // Literal character
    var str     : String = ""                 // Mask represented by this node used for debugging
    var nodes   : [Node] = [Node]()           // Child nodes (branches)
   }

  enum OkStatus {
  //----------------------------------------------------------------------------

    case
      NotOk,                                  // The check has failed
      OkSoFar,                                // The check is ok so far
      Ok                                      // The check is ok
  }

  typealias MaskError = (index: Int, errMsg: String?)
  typealias CheckResult = (index: Int, status: OkStatus, errMsg: String?)

  //--------------------
  // MARK: - Variables

  private var mask = String()
  private var text = String()

  private var rootNode = Node()               // Primary node

  //--------------------
  // MARK: - Helper Methods

  class func isDigit( c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is 0..9 otherwise false.

    switch c {
    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" : return true
    default : return false
    }
  }

  class func isLetter( c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is A..Z, a..z otherwise false.

    switch c {
    case "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z": return true
    case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z": return true
    default : return false
    }
  }

  class func isLower( c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is a..z otherwise false.

    switch c {
    case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z": return true
    default : return false
    }
  }

  class func isUpper( c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is A..Z, a..z otherwise false.

    switch c {
    case "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z": return true
    default : return false
    }
  }

  class func lastDot( s : String ) -> String {
  //----------------------------------------------------------------------------
  // Returns last element of a string separated by dots (period).
    return s.componentsSeparatedByString(".").last ?? "unknown"
  }

  func getMask() -> String {
  //----------------------------------------------------------------------------
    return mask
  }

  func setMask(mask: String) -> MaskError {
  //----------------------------------------------------------------------------
    self.mask = mask
    return parseMask(mask)
  }

  func parseMask(mask: String) -> MaskError {
  //----------------------------------------------------------------------------
  // Parse the mask and create the tree root.

    rootNode = Node()
    return parseMask( Array(mask.characters), node: &rootNode )
  }

  private func parseMask(mask: [Character], inout node: Node) -> MaskError {
  //----------------------------------------------------------------------------
  // Parse the mask and create the tree root.

    var i = 0
    while i < mask.count {
      let retVal = parseMask(mask, index: i, node: &node)
      i = retVal.index
      if retVal.errMsg != nil { return retVal }
    }
    if node.nodes.count == 0 { return(0, "No mask") }
    return (0, nil)
  }

  private func parseMask(mask: [Character], index: Int, inout node: Node) -> MaskError {
  //----------------------------------------------------------------------------
  // This parses a picture mask. It takes the following inputs:
  //
  //    mask    Mask being parsed
  //    index   Index into the mask currently being examined
  //    tree    Array of nodes to be built upon
  //
  // It returns the following:
  //
  //    index   Next index into the mask that should be examined
  //    errMsg  nil if everything is ok otherwise an isOk    True

    var i = index

    // Nothing to parse
    guard i < mask.count else {
      return ( i, nil )
    }

    // Create a node that will be added to the tree

    var n = Node()

    // Look at the current character to see what type it is

    var t : NodeType

    var c = mask[i]
    n.str.append(c)

    // Escape takes the next character as a literal

    if c == kMask.escape {

      i += 1
      guard i < mask.count else {
        return ( i, "Escape is last character." )
      }
      c = mask[i]
      n.str.append(c)
      t = .Literal

    } else {

      switch c {
      case kMask.digit          : t = .Digit
      case kMask.letter         : t = .Letter
      case kMask.letterToUpper  : t = .LetterToUpper
      case kMask.letterToLower  : t = .LetterToLower
      case kMask.anyChar        : t = .AnyChar
      case kMask.anyCharToUpper : t = .AnyCharToUpper
      case kMask.repetition     : t = .Repeat
      case kMask.optional       : t = .Optional
      case kMask.optionalEnd    : t = .OptionalEnd
      case kMask.grouping       : t = .Grouping
      case kMask.groupingEnd    : t = .GroupingEnd
      case kMask.group          : t = .Group
      default                   : t = .Literal
      }

    }

    //--------------------

    switch t {

    //--------------------

    case .Digit,
         .Letter,
         .LetterToUpper,
         .LetterToLower,
         .AnyChar,
         .AnyCharToUpper :

      n.type = t
      n.literal = c
      node.nodes.append(n)
      return (i+1, nil)

    //--------------------

    case .Literal :

      n.type = .Literal
      n.literal = c
      node.nodes.append(n)
      return (i+1, nil)

    //--------------------

    case .Root :

      return (i+1, nil)       // Should never happen

    //--------------------
    // Repeat *# or *2# or *2[#]

    case .Repeat :

      var numStr = ""

      repeat {

        i += 1
        guard i < mask.count else {
          return ( i, "Repetition is last character." )
        }

        c = mask[i]
        n.str.append(c)

        if NBPictureMask.isDigit(c) {
          numStr += String(c)
        }

      } while NBPictureMask.isDigit(c)

      n.str = String(n.str.characters.dropLast())

      let retVal = parseMask(mask, index: i, node: &n)
      i = retVal.index

      guard retVal.errMsg == nil else { return(retVal) }

      n.type = .Repeat
      n.literal = "*"
      n.value = Int( numStr ) ?? 0
      node.nodes.append(n)
      return (i, nil)

    //--------------------
    // Grouping {} or {#} or {#,?} or {R,G,B}

    case .Grouping :

      n.type = .Grouping
      n.literal = kMask.grouping

      let i1 = i

      repeat {

        i += 1

        var g = Node()

        let i2 = i

        repeat {

          g.type = .Group
          g.literal = kMask.group

          let retVal = parseMask(mask, index: i, node: &g)
          i = retVal.index

          guard i < mask.count else { return(i, "Grouping is missing '\(kMask.groupingEnd)'.") }
          guard g.nodes.count > 0 else { return(i, "Group missing elements") }
          guard retVal.errMsg == nil else { return(retVal) }

        } while mask[i] != kMask.group && mask[i] != kMask.groupingEnd

        for x in i2 ..< i {
          g.str.append(mask[x])
        }

        n.nodes.append(g)

      } while mask[i] == kMask.group

      for x in i1+1 ... i {
        n.str.append(mask[x])
      }

      node.nodes.append(n)
      return (i+1, nil)

    //--------------------
    // Optional [] or [#] or [#,?] or [R,G,B]

    case .Optional :

      n.type = .Optional
      n.literal = kMask.optional

      let i1 = i

      repeat {

        i += 1

        let i2 = i

        var g = Node()

        repeat {

          g.type = .Group
          g.literal = kMask.group

          let retVal = parseMask(mask, index: i, node: &g)
          i = retVal.index

          guard i < mask.count else { return(i, "Optional is missing '\(kMask.optionalEnd)'.") }
          guard g.nodes.count > 0 else { return(i, "Optional missing elements") }
          guard retVal.errMsg == nil else { return(retVal) }

        } while mask[i] != kMask.group && mask[i] != kMask.optionalEnd
        
        for x in i2 ..< i {
          g.str.append(mask[x])
        }

        n.nodes.append(g)

      } while mask[i] == kMask.group

      for x in i1+1 ... i {
        n.str.append(mask[x])
      }

      node.nodes.append(n)
      return (i+1, nil)

    //--------------------
    // Group with no body {} or {#,}

    case .GroupingEnd :

      return (i, "Grouping is missing '\(kMask.grouping)'.")

    //--------------------
    // Group with no body {,#} or [,#]

    case .Group :

      return (i, "Group '\(kMask.group)' is incomplete.")

    //--------------------
    // Optional with no body [] or [#,]

    case .OptionalEnd :

      return (i, "Optional is missing '\(kMask.optional)'.")
    }

  }

  func maskTreeToString() -> String {
  //----------------------------------------------------------------------------
  // Prints the mask tree structure for debugging purposes.

    var lines = [String]()

    lines.append("MASK TREE '\(mask)'")
    NBPictureMask.printMaskTree(&lines, index: 0, node: rootNode)
    lines.append("MASK TREE FINISHED")

    return lines.joinWithSeparator("\n")
  }

  private class func printMaskTree(inout lines: [String], index: Int, node: Node) {
  //----------------------------------------------------------------------------
  // Prints the mask tree structure for debugging purposes.

    var pad = ""
    for _ in 0..<index { pad += "  " }

    for n in node.nodes {
      switch n.type {
      case .Digit,
           .Letter,
           .LetterToUpper,
           .LetterToLower,
           .AnyChar,
           .AnyCharToUpper,
           .Literal :
        lines.append("\(pad)\(NBPictureMask.lastDot(String(n.type))) '\(n.str)'")
      case .Root :
        break
      case .Repeat :
        lines.append("\(pad)\(NBPictureMask.lastDot(String(n.type))) '\(n.str)'")
        printMaskTree(&lines, index: index+1, node: n)
      case .Grouping,
           .GroupingEnd,
           .Optional,
           .OptionalEnd,
           .Group :
        lines.append("\(pad)\(NBPictureMask.lastDot(String(n.type))) '\(n.str)'")
        printMaskTree(&lines, index: index+1, node: n)
      }
    }
  }

  func check(text: String) -> CheckResult {
  //----------------------------------------------------------------------------
  // Check the text against the mask.

    return NBPictureMask.check(Array(text.characters), index: 0, node: rootNode)
  }

  private class func check(text: [Character], index: Int, node: Node) -> CheckResult {
  //----------------------------------------------------------------------------
  // This checks the text against the picture mask (tree). It takes the following inputs:
  //
  //    text    Text being checked
  //    index   Index into the mask currently being examined
  //    node    Node in mask to be used for checking the text at index
  //
  // It returns the following:
  //
  //    index   Next index into the text that should be examined
  //    isOk    If check is currently ok otherwise false
  //    errMsg  nil if everything is ok otherwise an isOk    True

    NSLog("CHECK \(NBPictureMask.lastDot(String(node.type))) - \(index) \(node.str)")

    var i = index

    //--------------------

    switch node.type {

    //--------------------

    case .Digit :

      guard i < text.count else { return( i, .OkSoFar, nil) }

      if isDigit( text[i] ) {
        return( i+1, .Ok, nil)
      } else {
        return( i, .NotOk, "Not a digit")
      }

    //--------------------

    case .Letter :

      guard i < text.count else { return( i, .OkSoFar, nil) }

      if isLetter( text[i] ) {
        return( i+1, .Ok, nil)
      } else {
        return( i, .NotOk, "Not a letter")
      }

    //--------------------

    case .LetterToUpper :

      guard i < text.count else { return( i, .OkSoFar, nil) }

      if isLetter( text[i] ) {
        return( i+1, .Ok, nil)
      } else {
        return( i, .NotOk, "Not a letter")
      }

    //--------------------

    case .LetterToLower :

      guard i < text.count else { return( i, .OkSoFar, nil) }

      if isLetter( text[i] ) {
        return( i+1, .Ok, nil)
      } else {
        return( i, .NotOk, "Not a letter")
      }

    //--------------------

    case .AnyChar :

      guard i < text.count else { return( i, .OkSoFar, nil) }

      return( i+1, .Ok, nil)

    //--------------------

    case .AnyCharToUpper :

      guard i < text.count else { return( i, .OkSoFar, nil) }

      return( i+1, .Ok, nil)

    //--------------------

    case .Literal :

      guard i < text.count else { return( i, .OkSoFar, nil) }

      if text[i] == node.literal {
        return( i+1, .Ok, nil)
      } else {
        return( i, .NotOk, "Not ok")
      }

    //--------------------
    // Root node
    // Example: # or ## or #[#] or {#,&}

    case .Root :

      for n in 0 ..< node.nodes.count {
        let retVal = check(text, index: i, node: node.nodes[n])
        i = retVal.index
        switch retVal.status {
        case .Ok :          break;            // Continue while everything is ok
        case .OkSoFar :     return retVal     // No more text
        case .NotOk :       return retVal     // Problem
        }
      }

      // No more mask
      if i == text.count  { return(i, .Ok, nil) }           // Mask and text match
      else                { return(i, .NotOk, "Not ok") }   // More text than mask

    //--------------------
    // Repeat *# or *2# or *2[#]

    case .Repeat :

      var loopCount = node.value

      while loopCount >= 0 {

        let startIndex = i

        // No more input
        if i == text.count {
          if loopCount == 0 { return(i, .Ok, nil) }    // Repeat Oked to the end of the input OR no count specified
          else              { return(i, .NotOk, "Repeat is longer than the input") }
        }

        for n in 0 ..< node.nodes.count {
          let retVal = check(text, index: i, node: node.nodes[n])
          NSLog("  repeat \(NBPictureMask.lastDot(String(retVal.status))) - \(i) \(node.str)")
          i = retVal.index
          switch retVal.status {
          case .Ok :          break;            // Continue while everything is ok
          case .OkSoFar :     return retVal     // No more text
          case .NotOk :       return retVal     // Problem
          }
        }

        // No more mask

        // Repeat did not advance and this can only happen if everything was optional
        if i == startIndex { return(i, .Ok, nil) }

        if loopCount == 0 { continue }          // Special case repeats until end of text
        loopCount -= 1
        if loopCount == 0 { break }
      }

      // No more loops

      return(i, .Ok, nil)                     // Mask and text up to this point match

    //--------------------
    // Grouping {} or {#} or {#,?} or {R,G,B}
    // Check all groupings from the same text positon.
    // The first Ok wins.

    case .Grouping :

      for n in 0 ..< node.nodes.count {
        let retVal = check(text, index: i, node: node.nodes[n])
        NSLog("  grouping \(NBPictureMask.lastDot(String(retVal.status))) - \(i) \(node.str)")
        switch retVal.status {
        case .Ok :          return retVal     // Match first ok group
        case .OkSoFar :     return retVal     // Match first ok so far group    // NOTE - might consider continuing search
        case .NotOk :       break             // Try next group
        }
      }

      // No more mask
      return(i, .NotOk, "Not ok")             // More text than mask
      // return(i, .OkSoFar, nil)             // NOTE - might consider returning first "OkSoFar"

    //--------------------

    case .GroupingEnd :

      return( i, .NotOk, "Grouping End syntax error")

    //--------------------
    // Group inside grouping or optional
    // Example: # or ## or A#

    case .Group :

      for n in 0 ..< node.nodes.count {
        let retVal = check(text, index: i, node: node.nodes[n])
        NSLog("  group \(NBPictureMask.lastDot(String(retVal.status))) - \(i) \(node.str)")
        i = retVal.index
        switch retVal.status {
        case .Ok :          break;            // Continue while everything is ok
        case .OkSoFar :     return retVal     // No more text
        case .NotOk :       return retVal     // Problem
        }
      }

      // No more mask
      return(i, .Ok, nil)                     // Mask and text up to this point match

    //--------------------
    // Optional [] or [#] or [#,?] or [R,G,B]
    // Return on the first ok

    case .Optional :

      guard i < text.count else { return( i, .Ok, nil) }    // Optional not needed if no text

      for n in 0 ..< node.nodes.count {
        let retVal = check(text, index: i, node: node.nodes[n])
        NSLog("  optional \(NBPictureMask.lastDot(String(retVal.status))) - \(i) \(node.str)")
        switch retVal.status {
        case .Ok :          return retVal     // Match first ok group
        case .OkSoFar :     return retVal     // Match first ok so far group    // NOTE - might consider continuing search
        case .NotOk :       break             // Try next group
        }
      }

      // No more mask
      return(i, .Ok, nil)                     // Does not have to match
      // return(i, .OkSoFar, nil)             // NOTE - might consider returning first "OkSoFar"

    //--------------------

    case .OptionalEnd :

      return( i, .NotOk, "Optional End syntax error")

    }

  }

}