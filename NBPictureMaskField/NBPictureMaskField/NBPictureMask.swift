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
//  The first group to match is the one.
//
//  Optional Algorithm
//  ------------------
//
//==============================================================================

import Foundation

class NBPictureMask {
//------------------------------------------------------------------------------

  //--------------------
  // MARK: - Constants

  struct kMask {
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

  enum NodeType {
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

  struct Node {
  //----------------------------------------------------------------------------

    var type    : NodeType = .Root            // Node type indicates how it should be handled
    var value   : Int = 0                     // Repeat (count)
    var literal : Character = " "             // Literal character
    var str     : String = ""                 // Mask represented by this node used for debugging
    var nodes   : [Node] = [Node]()           // Child nodes (branches)
   }

  enum MatchStatus {
  //----------------------------------------------------------------------------

    case
      NotGood,                                // The check has failed
      OkSoFar,                                // The check is ok so far
      Match                                   // It matches
  }

  typealias CheckResult = (index: Int, status: MatchStatus, errMsg: String?)

  //--------------------
  // MARK: - Variables

  var localMask = String()
  var text = String()

  var rootNode = Node()                       // Primary node


  var mask: String {
  //----------------------------------------------------------------------------
    get { return localMask }
    set {
      localMask = newValue
      parseMask(localMask)
      printMaskTree()
    }
  }

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

  private func parseMask(mask: String) {
  //----------------------------------------------------------------------------
  // Parse the mask and create the tree root.

    rootNode = Node()
    parseMask( Array(mask.characters), node: &rootNode )
  }

  private func parseMask(mask: [Character], inout node: Node) {
  //----------------------------------------------------------------------------
  // Parse the mask and create the tree root.

    NSLog("PARSE MASK '\(String(mask))'")
    var i = 0
    while i < mask.count {
      let retVal = parseMask(mask, index: i, node: &node)
      i = retVal.index
      if let errMsg = retVal.errMsg {
        NSLog("PARSE MASK ERROR: Index(\(i)) Message: \(errMsg)")
      }
    }
    NSLog("PARSE MASK FINISHED")
  }

  private func parseMask(mask: [Character], index: Int, inout node: Node) -> (index: Int, errMsg: String?) {
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
        return ( i, "Escape character '\(kMask.escape)' does not have any characters following it." )
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
          return ( i, "Repetition property '\(kMask.repetition)\(numStr)' does not have any characters following it." )
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
      if retVal.errMsg != nil { return retVal }

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

          guard i < mask.count else {
            return ( i, "Grouping property '\(kMask.grouping)' does not have the closing '\(kMask.groupingEnd)' character." )
          }

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

          guard i < mask.count else {
            return ( i, "Optional property '\(kMask.optional)' does not have the closing '\(kMask.optionalEnd)' character." )
          }

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
    // Group with no body {#,}

    case .GroupingEnd :

      return (i, nil)       // Probably should be a warning

    //--------------------
    // Group with no body {,#} or [,#]

    case .Group :

      return (i, nil)       // Probably should be a warning

    //--------------------
    // Optional with no body [#,]

    case .OptionalEnd :

      return (i, nil)       // Probably should be a warning
    }

  }

  private func printMaskTree() {
  //----------------------------------------------------------------------------
  // Prints the mask tree structure for debugging purposes.

    NSLog("==============================")
    NSLog("MASK TREE '\(localMask)'")
    printMaskTree(0, node: rootNode)
    NSLog("MASK TREE FINISHED")
    NSLog("==============================")
  }

  private func printMaskTree(index: Int, node: Node) {
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
        NSLog("\(pad)\(NBPictureMask.lastDot(String(n.type))) '\(n.str)'")
      case .Root :
        break
      case .Repeat :
        NSLog("\(pad)\(NBPictureMask.lastDot(String(n.type))) '\(n.str)'")
        printMaskTree(index+1, node: n)
      case .Grouping,
           .GroupingEnd,
           .Optional,
           .OptionalEnd,
           .Group :
        NSLog("\(pad)\(NBPictureMask.lastDot(String(n.type))) '\(n.str)'")
        printMaskTree(index+1, node: n)
      }
    }
  }

  func check(text: String) -> CheckResult {
  //----------------------------------------------------------------------------
  // Check the text against the mask.

    let tc = text.characters
    NSLog("CHECK Mask: '\(mask)' Text: '\(String(tc))'")

    var retVal : CheckResult

    // Look at all possible combinations of optionals
    retVal = NBPictureMask.check(Array(tc), index: 0, node: rootNode)
    if retVal.status == .Match {
      NSLog("MATCH - Mask: '\(mask)' Text: '\(String(tc))'")
      return (index: retVal.index, status: .Match, errMsg: nil)
    }

    // Nothing matched
    NSLog("NOT GOOD -  Mask: '\(mask)' Text: '\(String(tc))'")
    return (index: 0, status: .NotGood, errMsg: "No match")
  }

  class func check(text: [Character], index: Int, node: Node) -> CheckResult {
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

    var i = index

    //--------------------

    switch node.type {

    //--------------------

    case .Digit :

      guard i < text.count else { return( i, .NotGood, "No more digits") }

      if isDigit( text[i] ) {
        return( i+1, .Match, nil)
      } else {
        return( i, .NotGood, "Not a digit")
      }

    //--------------------

    case .Letter :

      guard i < text.count else { return( i, .NotGood, "No more letters") }

      if isLetter( text[i] ) {
        return( i+1, .Match, nil)
      } else {
        return( i, .NotGood, "Not a letter")
      }

    //--------------------

    case .LetterToUpper :

      guard i < text.count else { return( i, .NotGood, "No more letters to upper") }

      if isLetter( text[i] ) {
        return( i+1, .Match, nil)
      } else {
        return( i, .NotGood, "Not a letter")
      }

    //--------------------

    case .LetterToLower :

      guard i < text.count else { return( i, .NotGood, "No more letters to lower") }

      if isLetter( text[i] ) {
        return( i+1, .Match, nil)
      } else {
        return( i, .NotGood, "Not a letter")
      }

    //--------------------

    case .AnyChar :

      guard i < text.count else { return( i, .NotGood, "No more any characters") }

      return( i+1, .Match, nil)

    //--------------------

    case .AnyCharToUpper :

      guard i < text.count else { return( i, .NotGood, "No more any characters to upper") }

      return( i+1, .Match, nil)

    //--------------------

    case .Literal :

      guard i < text.count else { return( i, .NotGood, "No more literal characters") }

      if text[i] == node.literal {
        return( i+1, .Match, nil)
      } else {
        return( i, .NotGood, "Not a match")
      }

    //--------------------
    // Root node

    case .Root :

      for n in 0 ..< node.nodes.count {

        let retVal = check(text, index: i, node: node.nodes[n])
        NSLog("Root - \(retVal.index) \(NBPictureMask.lastDot(String(retVal.status)))")

        if retVal.status == .NotGood {
          return( retVal.index, retVal.status, retVal.errMsg)
        }

        i = retVal.index
      }

      //--------------------
      // Final determination

      if i == text.count {
        return( i, .Match, nil)
      } else if i < text.count {
        return( i, .OkSoFar, nil)
      } else {
        return( i, .NotGood, "No match")
      }

    //--------------------

    case .Repeat :

      var retVal : CheckResult

      for n in 0 ..< node.nodes.count {

        var cnt = 0
        repeat {

          if i == text.count {
            if node.value == 0 {
              return(i, .Match, nil)    // Repeat matched to the end of the input
            } else {
              return(i, .NotGood, "Repeat is longer than the input")
            }
          }

          retVal = check(text, index: i, node: node.nodes[n])
          NSLog("Repeat - text[\(retVal.index)] \(NBPictureMask.lastDot(String(retVal.status)))")

          switch retVal.status {
          // If everything matched then go with that
          case .Match :
            i = retVal.index
          // If index advanced then something matched up to that point
          case .OkSoFar :
            // Not advancing so stop repeating
            if i == retVal.index {
              return( retVal.index, retVal.status, retVal.errMsg)
            }
            i = retVal.index
          case .NotGood :
            return( retVal.index, retVal.status, retVal.errMsg)
          }

          cnt += 1

        } while cnt < node.value || node.value == 0

        // If we make it to the end then result is most recent outcome
        if retVal.status == .NotGood {
          return( retVal.index, retVal.status, retVal.errMsg)
        }
      }

      //--------------------
      // Final determination

      if i == text.count {
        return( i, .Match, nil)
      } else if i < text.count {
        return( i, .OkSoFar, nil)
      } else {
        return( i, .NotGood, "No match")
      }

    //--------------------
    // Check all groupings from the same text positon.
    // The first match wins.

    case .Grouping :

      for n in 0 ..< node.nodes.count {

        let retVal = check(text, index: i, node: node.nodes[n])
        NSLog("Grouping - text[\(retVal.index)] \(NBPictureMask.lastDot(String(retVal.status)))")

        // Return on the first match

        switch retVal.status {
        case .Match,
             .OkSoFar :
          return( retVal.index, retVal.status, retVal.errMsg)
        default :
          break;
        }
      }

      return( i, .NotGood, "No match")

    //--------------------

    case .GroupingEnd :

      return( i, .NotGood, "Grouping End syntax error")

    //--------------------

    case .Group :

      for n in 0 ..< node.nodes.count {

        let retVal = check(text, index: i, node: node.nodes[n])
        NSLog("Group - text[\(retVal.index)] \(NBPictureMask.lastDot(String(retVal.status)))")

        if retVal.status == .NotGood {
          return( retVal.index, retVal.status, retVal.errMsg)
        }

        i = retVal.index
      }

      //--------------------
      // Final determination

      if i == text.count {
        return( i, .Match, nil)
      } else if i < text.count {
        return( i, .OkSoFar, nil)
      } else {
        return( i, .NotGood, "No match")
      }

    //--------------------

    case .Optional :

      for n in 0 ..< node.nodes.count {

        let retVal = check(text, index: i, node: node.nodes[n])
        NSLog("Optional - text[\(retVal.index)] \(NBPictureMask.lastDot(String(retVal.status)))")

        // Return on the first match

        switch retVal.status {
        case .Match,
             .OkSoFar :
          return( retVal.index, retVal.status, retVal.errMsg)
        default :
          break;
        }
      }

      //--------------------
      // Final determination

      if i == text.count {
        return( i, .Match, nil)
      } else if i < text.count {
        return( i, .OkSoFar, nil)
      } else {
        return( i, .NotGood, "No match")
      }

    //--------------------

    case .OptionalEnd :

      return( i, .NotGood, "Optional End syntax error")

    }

  }

}