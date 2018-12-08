//==============================================================================
//  NBPictureMaskField.swift
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
//  See NBPictureMask for description of the mask.
//
//  Storyboard Attributes:
//
//    pictureMask
//    autofill
//    enforceMask
//
//  Class Variables:
//
//    maskErrorMessage
//    maskTreeToString
//
//  Class Functions:
//
//    check()
//
//  Closures:
//
//    validate
//    changed
//
//==============================================================================

import UIKit
import Foundation

class NBPictureMaskField: UITextField {
//------------------------------------------------------------------------------

  // MARK: - Types

  typealias ValidateClosure = (_ sender: AnyObject, _ text: String, _ status: NBPictureMask.Status ) -> (Bool)
  typealias ChangedClosure = (_ sender: AnyObject, _ text: String, _ status: NBPictureMask.Status ) -> ()

  // MARK: - Variables

  var maskErrMsg: String?

  var validate: ValidateClosure?
  var changed: ChangedClosure?

  fileprivate var nbPictureMask : NBPictureMask!
  internal var isEditingText: Bool
  fileprivate var _enforceMask: Bool

  required init?(coder aDecoder: NSCoder) {
  //----------------------------------------------------------------------------
    nbPictureMask = NBPictureMask()
    _enforceMask = true
    isEditingText = false
    super.init(coder: aDecoder)
  }

  //--------------------
  // MARK: - Picture Mask

  @IBInspectable var pictureMask: String {
  //----------------------------------------------------------------------------
    get { return nbPictureMask.getMask() }
    set {
      let retVal = nbPictureMask.setMask(newValue)
      maskErrMsg = retVal.errMsg
    }
  }

  @IBInspectable var autoFill: Bool {
  //----------------------------------------------------------------------------
    get { return nbPictureMask.getAutoFill() }
    set { nbPictureMask.setAutoFill(newValue) }
  }

  @IBInspectable var enforceMask: Bool {
  //----------------------------------------------------------------------------
    get { return _enforceMask }
    set { _enforceMask = newValue }
  }

  var maskErrorMessage: String? {
  //----------------------------------------------------------------------------
  // Returns the error message for the current mask, otherwise nil.
    get { return maskErrMsg }
  }

  var maskTreeToString: String {
  //----------------------------------------------------------------------------
  // Returns the parsed mask tree as a string.
    get { return nbPictureMask.maskTreeToString() }
  }

  override var text: String? {
  //----------------------------------------------------------------------------
  // Property observer so closures can be called if user sets text property
  // directly (typically during initialization).

    didSet {
      guard !isEditingText else { return }

      let checkResult = nbPictureMask.check(text ?? "")

      // User does not have a choice at this point in time
      _ = validate?(self, checkResult.text, checkResult.status)
      changed?(self, checkResult.text, checkResult.status)
    }
  }

  func check(_ text: String) -> NBPictureMask.CheckResult {
  //----------------------------------------------------------------------------
    return nbPictureMask.check(text)
  }

  //--------------------
  // MARK: - Draw

  override func draw(_ rect: CGRect) {
  //----------------------------------------------------------------------------
  // This is used as a way to get an observer on "text".

    super.draw(rect)

    // This observer used on manual updating text property
    delegate = self
  }

}

//--------------------
// MARK: - UITextFieldDelegate

extension NBPictureMaskField: UITextFieldDelegate {
//------------------------------------------------------------------------------

  func textFieldDidBeginEditing(_ textField: UITextField) {
  //----------------------------------------------------------------------------
    isEditingText = true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
  //----------------------------------------------------------------------------

    // Save positions
    let beginning = textField.beginningOfDocument
    let start = textField.position(from: beginning, offset:range.location)
    var cursorOffset = textField.offset(from: beginning, to:start!) + string.count

    let checkResult = nbPictureMask.check(textField.text ?? "", shouldChangeCharactersInRange: range, replacementString: string)

    // User may disallow changes
    if let validate = validate {
      if !validate(self, checkResult.text, checkResult.status) { return false }
    }

    // Check if picture mask is enforced
    if enforceMask {
      if checkResult.status == .notOk { return false }
    }

    // Update text field
    textField.text = checkResult.text
    cursorOffset += checkResult.autoFillOffset
    let newCursorPosition = textField.position(from: textField.beginningOfDocument, offset:cursorOffset)
    let newSelectedRange = textField.textRange(from: newCursorPosition!, to:newCursorPosition!)
    textField.selectedTextRange = newSelectedRange

    changed?(self, checkResult.text, checkResult.status)
    return false
  }

  func textFieldShouldClear(_ textField: UITextField) -> Bool {
  //----------------------------------------------------------------------------
  // The clear button option on the text field does not trigger anthing
  // except this. Since it triggers before the clearing takes place it
  // is best to do it at this time.
    self.text = ""
    changed?(self, "", .ok)
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
  //----------------------------------------------------------------------------
    isEditingText = false
  }

}
