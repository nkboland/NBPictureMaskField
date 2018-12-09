//==============================================================================
//  NBPictureMask.swift
//  NBPictureMaskField
//
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
//  This is allows a person to specify what may be entered in a text field.
//
//  The "mask" uses the following special characters:
//
//    #     Any digit 0..9
//    ?     Any letter a..z or A..Z
//    &     Any letter a..z or A..Z which is automatically converted to uppercase
//    ~     Any letter a..z or A..Z which is automatically converted to lowercase
//    @     Any character
//    !     Any character which is automatically converted to uppercase
//    ;     The next character is taken literally
//    *     Repeat the specified number of times
//    {a,b} Grouping operation
//    [a,b] Optional sequence of characters
//
//  Note - The mask is matched left to right. You must be careful to avoid
//         situations where one element is completely contained in another.
//
//  Grouping {a,b}
//  --------------
//
//  Each group is examined left to right. The first group that matches
//  will be used. Two or more groups are separated with a comma.
//
//  Optional [a,b]
//  --------------
//
//  This is similar to the grouping operation but the characters are not
//  required. Two or more optional items are separated with a comma.
//
//  Repeat *
//  --------
//
//  The symbol following the repeat character is optionally repeated
//  any number of times. If a numeric value is specified then it must
//  match that exact number of times.
//
//  Examples
//  --------
//
//  #                 One digit
//  ##                Two digits
//  *5#               Five digits
//  #*#               One digit followed by any number of other digits
//  #&                Single digit followed by single character converted to uppercase
//  #[#]              One or two digits
//  #*4[#]            One to five digits
//  {#,&}             Digit or character converted to uppercase
//  #####[-####]      Zipcode with optional plus four
//  [+,-]#*#[.*#]     1, +1, +1., -1.0, 123.456
//
//  Boolean           {Yes,No,True,False}
//  Integer           [-,+]#*#
//  Float             [-,+]#*#[.][#*#]
//  Scientific        {{[-,+]#[#][#][;,###*[;,###],*#][.*#]},.#*#}[E[+,-]#[#][#]]
//  Float/Scientific  {{{#[#][#][;,###*[;,###],*#][.*#]},.#*#}[E[[+,-]#[#][#]]],({{#[#][#][;,###*[;,###],*#][.*#]},.#*#}[E[[+,-]#[#][#]]]),[-]{{#[#][#][;,###*[;,###],*#][.*#]},.#*#}[E[[+,-]#[#][#]]]}
//  Date mm/dd/yyyy 1 {{0{4,6,9},1{1}}/{0{1,2,3,4,5,6,7,8,9},1#,2#,3{0}},{0{1,3,5,7,8},1{0,2}}/{0{1,2,3,4,5,6,7,8,9},1#,2#,3{0,1}},0{2}/{0{1,2,3,4,5,6,7,8,9},1#,2{0,1,2,3,4,5,6,7,8,9}}}/{1{9},2{0}}##
//  Date mm/dd/yyyy 2 {{{09,04,06,11}/{0{1,2,3,4,5,6,7,8,9},1#,2#,30}},{{01,03,05,07,08,10,12}/{0{1,2,3,4,5,6,7,8,9},1#,2#,30,31}},{02/{0{1,2,3,4,5,6,7,8,9},1#,20,21,22,23,24,25,26,27,28,29}}}/{19,20}##
//  Date yyyy-mm-dd   {1{9},2{0}}##-{{0{4,6,9},1{1}}-{0{1,2,3,4,5,6,7,8,9},1#,2#,3{0}},{0{1,3,5,7,8},1{0,2}}-{0{1,2,3,4,5,6,7,8,9},1#,2#,3{0,1}},0{2}-{0{1,2,3,4,5,6,7,8,9},1#,2{0,1,2,3,4,5,6,7,8,9}}}
//  Time hh:mm:ss     {0#,1#,2{0,1,2,3}}:{0,1,2,3,4,5}#[:{0,1,2,3,4,5}#]
//  Time AM/PM        {0#,1{0,1,2}}:{0,1,2,3,4,5}#[:{0,1,2,3,4,5}#] [AM,PM]
//  Colors RGB        {R[ed],G[reen],B[lue]}
//  Colors Some       {Red,Gr{ay,een},B{l{ack,ue},rown},White,Yellow}
//  Telephone 1       (###) ###-####
//  Telephone 2       ###-###-####
//  Telephone 3       {*3{#}-*4{#},{(*3{#}) ,*3{#}-}*3{#}-*4{#}}
//  US Zip+4 1        #####[-####]
//  US Zip+4 2        *5{#}[-*4#]
//  Capitalize 1      &*?
//  Capitalize 2      *[&[*?]*[ ]]
//  Capitalize 3      *[&[*?]*[{#, ,.,;,,;;,:,;!,;[,;],(,)}]]
//  Compass Heading   {0{[#][#]},1{[#][#]},2{[#][#]},3{{0,1,2,3,4,5}#}}
//  ICD 9 or 10       {X{X},Z{Z},{#,&}#{#,&}.[#,&][#,&][#,&][#,&]}
//
//  Other
//  -----
//
//  Literal letters are automatically case converted. For example:
//  {Red,Yellow}      If the Input is "RED" the output is "Red"
//
//  The space (' ') character is automatically matched to the next literal
//  character. For example:
//  (###) ###-####    Entered as <' '>123<' '><' '>456<' '>7890 gives "(123) 456-7890"
//
//==============================================================================

import Foundation

class NBPictureMask {
//------------------------------------------------------------------------------

  //--------------------
  // MARK: - Public

  typealias MaskResult = (index: Int, errMsg: String?)
  //--------------------
  // This is returned when setting the mask.

  enum Status {
  //--------------------
  // These are the different outcomes that may result when checking text.
    case
      notOk,                                  // The check has failed
      okSoFar,                                // The check is ok so far
      ok                                      // The check is ok
  }

  typealias CheckResult = (status: Status, text: String, errMsg: String?, autoFillOffset: Int)
  //--------------------
  // This is returned when checking the text.
  // autoFillOffset - number of characters added with autofill

  //--------------------
  // MARK: - Constants

  fileprivate struct kMask {
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

  fileprivate enum NodeType {
  //--------------------
  // A node must be one of these types.

    case
      root,                                   //     Root node
      digit,                                  //  #  Any digit 0..9
      letter,                                 //  ?  Any letter a..z or A..Z
      letterToUpper,                          //  &  Any letter a..z or A..Z converted to uppercase
      letterToLower,                          //  ~  Any letter a..z or A..Z converted to lowercase
      anyChar,                                //  @  Any character
      anyCharToUpper,                         //  !  Any character converted to uppercase
      literal,                                //  ;  Literal character
      repetition,                             //  *  Repeat any number of times - Example: *& or *3#
      optional,                               //  [  Optional sequence of characters - Example: [abc]
      optionalEnd,                            //  ]  Optional end
      grouping,                               //  {  Grouping - Example: {R,G,B} or {R[ed],G[reen],B[lue]}
      groupingEnd,                            //  }  Grouping end
      group                                   //  ,  Group - Example: {Group1,Group2}
  }

  fileprivate struct Node {
  //--------------------

    var type    : NodeType = .root            // Node type indicates how it should be handled
    var value   : Int = 0                     // Repeat (count)
    var literal : Character = " "             // Literal character
    var str     : String = ""                 // Mask represented by this node used for debugging
    var nodes   : [Node] = [Node]()           // Child nodes (branches)
   }

  fileprivate typealias ChkRslt = (index: Int, status: Status, errMsg: String?)

  //--------------------
  // MARK: - Variables

  fileprivate var mask = [Character]()        // Input mask
  fileprivate var text = [Character]()        // Input text

  fileprivate var rootNode = Node()           // Mask root node
  fileprivate var newtext = [Character]()     // Text with mask changes applied

  fileprivate var autoFill = false            // Text is automatically filled with literals

  //--------------------
  // MARK: - Helper Methods

  class func isDigit( _ c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is 0..9 otherwise false.

    switch c {
    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" : return true
    default : return false
    }
  }

  class func isLetter( _ c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is A..Z, a..z otherwise false.

    switch c {
    case "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z": return true
    case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z": return true
    default : return false
    }
  }

  class func isUpper( _ c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is A..Z, a..z otherwise false.

    switch c {
    case "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z": return true
    default : return false
    }
  }

  class func toUpper( _ c : Character ) -> Character {
  //----------------------------------------------------------------------------
  // Returns true if characer is a..z otherwise false.

    switch c {
    case "a" : return "A"
    case "b" : return "B"
    case "c" : return "C"
    case "d" : return "D"
    case "e" : return "E"
    case "f" : return "F"
    case "g" : return "G"
    case "h" : return "H"
    case "i" : return "I"
    case "j" : return "J"
    case "k" : return "K"
    case "l" : return "L"
    case "m" : return "M"
    case "n" : return "N"
    case "o" : return "O"
    case "p" : return "P"
    case "q" : return "Q"
    case "r" : return "R"
    case "s" : return "S"
    case "t" : return "T"
    case "u" : return "U"
    case "v" : return "V"
    case "w" : return "W"
    case "x" : return "X"
    case "y" : return "Y"
    case "z" : return "Z"
    default  : return c
    }
  }

  class func toLower( _ c : Character ) -> Character {
  //----------------------------------------------------------------------------
  // Returns true if characer is a..z otherwise false.

    switch c {
    case "A" : return "a"
    case "B" : return "b"
    case "C" : return "c"
    case "D" : return "e"
    case "E" : return "e"
    case "F" : return "f"
    case "G" : return "g"
    case "H" : return "h"
    case "I" : return "i"
    case "J" : return "j"
    case "K" : return "k"
    case "L" : return "l"
    case "M" : return "m"
    case "N" : return "n"
    case "O" : return "o"
    case "P" : return "p"
    case "Q" : return "q"
    case "R" : return "r"
    case "S" : return "s"
    case "T" : return "t"
    case "U" : return "u"
    case "V" : return "v"
    case "W" : return "w"
    case "X" : return "x"
    case "Y" : return "y"
    case "Z" : return "z"
    default  : return c
    }
  }

  class func isLower( _ c : Character ) -> Bool {
  //----------------------------------------------------------------------------
  // Returns true if characer is a..z otherwise false.

    switch c {
    case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z": return true
    default : return false
    }
  }

  class func lastDot( _ s : String ) -> String {
  //----------------------------------------------------------------------------
  // Returns last element of a string separated by dots (period).
    return s.components(separatedBy: ".").last ?? "unknown"
  }

  func getMask() -> String {
  //----------------------------------------------------------------------------
    return String(mask)
  }

  func setMask(_ mask: String) -> MaskResult {
  //----------------------------------------------------------------------------
    rootNode = Node()
    self.mask = Array(mask)
    return parseMask(&rootNode )
  }

  func getAutoFill() -> Bool {
  //----------------------------------------------------------------------------
    return self.autoFill
  }

  func setAutoFill(_ autoFill: Bool) {
  //----------------------------------------------------------------------------
    self.autoFill = autoFill
  }

  fileprivate func parseMask(_ node: inout Node) -> MaskResult {
  //----------------------------------------------------------------------------
  // Parse the mask and create the tree root.

    var i = 0
    while i < mask.count {
      let retVal = parseMask(i, node: &node)
      i = retVal.index
      if retVal.errMsg != nil { return retVal }
    }
    if node.nodes.count == 0 { return(0, "No mask") }
    return (0, nil)
  }

  fileprivate func parseMask(_ index: Int, node: inout Node) -> MaskResult {
  //----------------------------------------------------------------------------
  // This parses the current picture mask.
  //
  //  Gobal Inputs:
  //    mask    Mask being parsed
  //
  //  Parameter Inputs:
  //    index   Index into the mask currently being examined
  //    node    Array of nodes to be built upon
  //
  // Returns:
  //    index   Next index into the mask that should be examined
  //    errMsg  nil if everything is ok otherwise an isOk    True

    var i = index

    // Nothing to parse
    guard i < mask.count else {
      return (i, nil )
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
        return (i, "Escape is last character")
      }
      c = mask[i]
      n.str.append(c)
      t = .literal

    } else {

      switch c {
      case kMask.digit          : t = .digit
      case kMask.letter         : t = .letter
      case kMask.letterToUpper  : t = .letterToUpper
      case kMask.letterToLower  : t = .letterToLower
      case kMask.anyChar        : t = .anyChar
      case kMask.anyCharToUpper : t = .anyCharToUpper
      case kMask.repetition     : t = .repetition
      case kMask.optional       : t = .optional
      case kMask.optionalEnd    : t = .optionalEnd
      case kMask.grouping       : t = .grouping
      case kMask.groupingEnd    : t = .groupingEnd
      case kMask.group          : t = .group
      default                   : t = .literal
      }

    }

    //--------------------

    switch t {

    //--------------------

    case .digit,
         .letter,
         .letterToUpper,
         .letterToLower,
         .anyChar,
         .anyCharToUpper :

      n.type = t
      n.literal = c
      node.nodes.append(n)
      return (i+1, nil)

    //--------------------

    case .literal :

      n.type = .literal
      n.literal = c
      node.nodes.append(n)
      return (i+1, nil)

    //--------------------

    case .root :

      return (i+1, nil)       // Should never happen

    //--------------------
    // Repeat *# or *2# or *2[#]

    case .repetition :

      var numStr = ""

      repeat {

        i += 1
        guard i < mask.count else {
          return (i, "Repetition is last character")
        }

        c = mask[i]
        n.str.append(c)

        if NBPictureMask.isDigit(c) {
          numStr += String(c)
        }

      } while NBPictureMask.isDigit(c)

      n.str = String(n.str.dropLast())

      let retVal = parseMask(i, node: &n)
      i = retVal.index

      guard retVal.errMsg == nil else { return(retVal) }

      n.type = .repetition
      n.literal = "*"
      n.value = Int( numStr ) ?? 0
      node.nodes.append(n)
      return (i, nil)

    //--------------------
    // Grouping {} or {#} or {#,?} or {R,G,B}

    case .grouping :

      n.type = .grouping
      n.literal = kMask.grouping

      let i1 = i

      repeat {

        i += 1

        var g = Node()

        let i2 = i

        repeat {

          g.type = .group
          g.literal = kMask.group

          let retVal = parseMask(i, node: &g)
          i = retVal.index

          guard i < mask.count else { return(i, "Grouping is missing '\(kMask.groupingEnd)'") }
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

    case .optional :

      n.type = .optional
      n.literal = kMask.optional

      let i1 = i

      repeat {

        i += 1

        let i2 = i

        var g = Node()

        repeat {

          g.type = .group
          g.literal = kMask.group

          let retVal = parseMask(i, node: &g)
          i = retVal.index

          guard i < mask.count else { return(i, "Optional is missing '\(kMask.optionalEnd)'") }
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

    case .groupingEnd :

      return (i, "Grouping is missing '\(kMask.grouping)'")

    //--------------------
    // Group with no body {,#} or [,#]

    case .group :

      return (i, "Group '\(kMask.group)' is incomplete")

    //--------------------
    // Optional with no body [] or [#,]

    case .optionalEnd :

      return (i, "Optional is missing '\(kMask.optional)'")
    }

  }

  func maskTreeToString() -> String {
  //----------------------------------------------------------------------------
  // Prints the mask tree structure for debugging purposes.

    var lines = [String]()

    lines.append("-- MASK --")
    lines.append("\(mask)")
    lines.append("-- START --")
    NBPictureMask.printMaskTree(&lines, index: 0, node: rootNode)
    lines.append("-- END --")

    return lines.joined(separator: "\n")
  }

  fileprivate class func printMaskTree(_ lines: inout [String], index: Int, node: Node) {
  //----------------------------------------------------------------------------
  // Prints the mask tree structure for debugging purposes.

    var pad = ""
    for _ in 0..<index { pad += "  " }

    for n in node.nodes {
      switch n.type {
      case .digit,
           .letter,
           .letterToUpper,
           .letterToLower,
           .anyChar,
           .anyCharToUpper,
           .literal :
        lines.append("\(pad)\(NBPictureMask.lastDot(String(describing: n.type))) '\(n.str)'")
      case .root :
        break
      case .repetition :
        lines.append("\(pad)\(NBPictureMask.lastDot(String(describing: n.type))) '\(n.str)'")
        printMaskTree(&lines, index: index+1, node: n)
      case .grouping,
           .groupingEnd,
           .optional,
           .optionalEnd,
           .group :
        lines.append("\(pad)\(NBPictureMask.lastDot(String(describing: n.type))) '\(n.str)'")
        printMaskTree(&lines, index: index+1, node: n)
      }
    }
  }

  fileprivate func check(_ index: Int, node: Node, fillFlag: inout Bool) -> ChkRslt {
  //----------------------------------------------------------------------------
  // This checks the current text against the current mask (tree).
  //
  //  Gobal Inputs:
  //    mask      Mask being parsed
  //    text      Text being analyzed
  //
  //  Parameter Inputs:
  //    index     Index into the text currently being examined
  //    node      Node in mask to be used for checking the text at index
  //    fillFlag  Auto fillFlag is enabled until special character encountered
  //
  //  Global Outputs:
  //    newtext   Text with mask changes applied
  //
  // Returns:
  //    index     Next index into the text that should be examined
  //    status    Ok, OkSoFar, or NotOk
  //    errMsg    nil if everything is ok otherwise an isOk    True

    var i = index

    //--------------------

    switch node.type {

    //--------------------

    case .digit :

      // No more input
      if i == text.count {
        fillFlag = false
        return(i, .okSoFar, nil)
      }

      if NBPictureMask.isDigit( text[i] ) {
        return(i+1, .ok, nil)
      } else {
        return(i, .notOk, "Not a digit")
      }

    //--------------------

    case .letter :

      // No more input
      if i == text.count {
        fillFlag = false
        return(i, .okSoFar, nil)
      }

      if NBPictureMask.isLetter( text[i] ) {
        return(i+1, .ok, nil)
      } else {
        return(i, .notOk, "Not a letter")
      }

    //--------------------

    case .letterToUpper :

      // No more input
      if i == text.count {
        fillFlag = false
        return(i, .okSoFar, nil)
      }

      if NBPictureMask.isLetter( text[i] ) {
        newtext[i] = NBPictureMask.toUpper(text[i])
        return(i+1, .ok, nil)
      } else {
        return(i, .notOk, "Not a letter")
      }

    //--------------------

    case .letterToLower :

      // No more input
      if i == text.count {
        fillFlag = false
        return(i, .okSoFar, nil)
      }

      if NBPictureMask.isLetter( text[i] ) {
        newtext[i] = NBPictureMask.toLower(text[i])
        return(i+1, .ok, nil)
      } else {
        return(i, .notOk, "Not a letter")
      }

    //--------------------

    case .anyChar :

      // No more input
      if i == text.count {
        fillFlag = false
        return(i, .okSoFar, nil)
      }

      return(i+1, .ok, nil)

    //--------------------

    case .anyCharToUpper :

      // No more input
      if i == text.count {
        fillFlag = false
        return(i, .okSoFar, nil)
      }

      newtext[i] = NBPictureMask.toUpper(text[i])
      return(i+1, .ok, nil)

    //--------------------

    case .literal :

      // No more input
      if i == text.count {
        if fillFlag {
          text.append(node.literal)
          newtext.append(node.literal)
        }
      }

      // No more input (for real this time)
      if i == text.count {
        return(i, .okSoFar, nil)
      }

      // Space matches all literal characters
      if text[i] == " " {
        newtext[i] = node.literal
        return(i+1, .ok, nil)
      // Ignore case during the comparison
      } else if NBPictureMask.toUpper(text[i]) == NBPictureMask.toUpper(node.literal) {
        // Literal letters are automatically converted to the case presented in the mask
        if NBPictureMask.isLetter(text[i]) { newtext[i] = node.literal }
        return(i+1, .ok, nil)
      } else {
        return(i, .notOk, "Not ok")
      }

    //--------------------
    // Root node
    // Example: # or ## or #[#] or {#,&}

    case .root :

      for n in 0 ..< node.nodes.count {
        let retVal = check(i, node: node.nodes[n], fillFlag: &fillFlag)
        i = retVal.index
        switch retVal.status {
        case .ok :          break;            // Continue while everything is ok
        case .okSoFar :     return retVal     // No more text
        case .notOk :       return retVal     // Problem
        }
      }

      // No more mask
      if i == text.count  { return(i, .ok, nil) }           // Mask and text match
      else                { return(i, .notOk, "Not ok") }   // More text than mask

    //--------------------
    // Repeat *# or *2# or *2[#]

    case .repetition :

      var loopCount = node.value

      let loopOptional = ( loopCount == 0 )

      while loopCount >= 0 {

        let startIndex = i

        // No more input
        if i == text.count {
          fillFlag = false
          if loopOptional { return(i, .ok, nil) }   // Repeat Oked to the end of the input OR no count specified
          else            { return(i, .okSoFar, nil) }
        }

        for n in 0 ..< node.nodes.count {
          let retVal = check(i, node: node.nodes[n], fillFlag: &fillFlag)
          i = retVal.index
          switch retVal.status {
          case .ok :        break;                  // Continue while everything is ok
          case .okSoFar :   return retVal           // No more text
          case .notOk :     if loopOptional {       // No count specified so it doesn't have to match
                              break
                            }
                            return retVal           // Otherwise problem
          }
        }

        // No more mask and ok so far

        // Repeat did not advance and this can only happen if everything was optional
        if i == startIndex {
          return(i, .ok, nil)
        }

        if loopOptional { continue }                // Special case repeats until end of text
        loopCount -= 1
        if loopCount == 0 { break }
      }

      // No more loops

      return(i, .ok, nil)                           // Mask and text up to this point match

    //--------------------
    // Grouping {} or {#} or {#,?} or {R,G,B}
    // Check all groupings from the same text positon.
    // The first Ok wins.

    case .grouping :

      // No more input
      if i == text.count {
          fillFlag = false
      }

      for n in 0 ..< node.nodes.count {
        let retVal = check(i, node: node.nodes[n], fillFlag: &fillFlag)
        switch retVal.status {
        case .ok :          return retVal           // Match first ok group
        case .okSoFar :     return retVal           // Match first ok so far group
        case .notOk :       break                   // Try next group
        }
      }

      // No more mask
      return(i, .notOk, "Not ok")                   // More text than mask

    //--------------------

    case .groupingEnd :

      return( i, .notOk, "Should never occur")

    //--------------------
    // Group inside grouping or optional
    // Example: # or ## or A#

    case .group :

      for n in 0 ..< node.nodes.count {
        let retVal = check(i, node: node.nodes[n], fillFlag: &fillFlag)
        i = retVal.index
        switch retVal.status {
        case .ok :          break;            // Continue while everything is ok
        case .okSoFar :     return retVal     // No more text
        case .notOk :       return retVal     // Problem
        }
      }

      // No more mask
      return(i, .ok, nil)                     // Mask and text up to this point match

    //--------------------
    // Optional [] or [#] or [#,?] or [R,G,B]
    // Return on the first ok

    case .optional :

      // No more input
      if i == text.count {
        fillFlag = false
        return(i, .ok, nil)                   // Optional not needed if no text
      }

      for n in 0 ..< node.nodes.count {
        let retVal = check(i, node: node.nodes[n], fillFlag: &fillFlag)
        switch retVal.status {
        case .ok :          return retVal           // Match first ok group
        case .okSoFar :     return retVal           // Match first ok so far group
        case .notOk :       break                   // Try next group
        }
      }

      // No more mask
      return(i, .ok, nil)                           // Does not have to match

    //--------------------

    case .optionalEnd :

      return(i, .notOk, "Should never occur")

    }

  }

  func check(_ text: String) -> CheckResult {
  //----------------------------------------------------------------------------
  // Check the text against the mask.
  //
  // NOTE - autoFill cannot be done here because it is not known whether
  //        the new text was being inserted, deleted, or appended.

    self.text = Array(text)
    self.newtext = Array(text)

    var fillFlag = self.autoFill
    let rslt = check(0, node: rootNode, fillFlag: &fillFlag)

    return (rslt.status, String(self.newtext), rslt.errMsg, 0)
  }

  func check(_ text: String, mask: String) -> CheckResult {
  //----------------------------------------------------------------------------
  // Check the text against the mask.

    _ = self.setMask(mask)
    return check(text)
  }

  func check(_ text: String, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> CheckResult {
  //----------------------------------------------------------------------------
  // Check the text against the mask.

    let prospectiveText = (text as NSString).replacingCharacters(in: range, with: string)

    let isAppending: Bool

    // Appending
    if range.location >= text.count {
      isAppending = true
    // Inserting
    } else if range.length == 0 {
      isAppending = false
    // Replacing
    } else if range.length == string.count {
      isAppending = false
    // Replace and reduce
    } else if range.length > string.count {
      isAppending = false
    // Replace and increase
    } else if range.length < string.count {
      isAppending = false
    // Somthing else
    } else {
      isAppending = false
    }

    // Only autofill when appending
    // NOTE - need to know how many characters were added!

    let prevAutoFill = autoFill
    if !isAppending { autoFill = false }

    var checkResult = check(prospectiveText)

    // Autofill needs to figure out how many characters were added to the end

    if isAppending {
      let autoFillOffset = (checkResult.text.count - text.count) - string.count
      checkResult.autoFillOffset = autoFillOffset
    }

    autoFill = prevAutoFill

    return checkResult
  }

}
