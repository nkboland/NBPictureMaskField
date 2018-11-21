//
//  MainTableViewController.swift
//  NBPictureMaskField
//
//  Created by Nick Boland on 4/12/16.
//  Copyright © 2016 Nick Boland. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
//------------------------------------------------------------------------------

  @IBOutlet weak var booleanTextField: NBPictureMaskField!
  @IBOutlet weak var integerTextField: NBPictureMaskField!
  @IBOutlet weak var floatTextField: NBPictureMaskField!
  @IBOutlet weak var scientificTextField: NBPictureMaskField!
  @IBOutlet weak var dateUSTextField: NBPictureMaskField!
  @IBOutlet weak var dateISOTextField: NBPictureMaskField!
  @IBOutlet weak var timeTextField: NBPictureMaskField!
  @IBOutlet weak var timeAMPMTextField: NBPictureMaskField!
  @IBOutlet weak var colorTextField: NBPictureMaskField!
  @IBOutlet weak var telephoneTextField: NBPictureMaskField!
  @IBOutlet weak var zipTextField: NBPictureMaskField!
  @IBOutlet weak var capitalizeTextField: NBPictureMaskField!

  override func viewDidLoad() {
  //----------------------------------------------------------------------------
    super.viewDidLoad()

    // Dismiss keyboard when tapping outside text field
    let tap = UITapGestureRecognizer(target: self, action: #selector(MainTableViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)

    booleanTextField.changed = inputTextFieldChanged
    integerTextField.changed = inputTextFieldChanged
    floatTextField.changed = inputTextFieldChanged
    scientificTextField.changed = inputTextFieldChanged
    dateUSTextField.changed = inputTextFieldChanged
    dateISOTextField.changed = inputTextFieldChanged
    timeTextField.changed = inputTextFieldChanged
    timeAMPMTextField.changed = inputTextFieldChanged
    colorTextField.changed = inputTextFieldChanged
    telephoneTextField.changed = inputTextFieldChanged
    zipTextField.changed = inputTextFieldChanged
    capitalizeTextField.changed = inputTextFieldChanged

    dateUSTextField.validate = dateUSTextFieldValidate
    dateISOTextField.validate = dateISOTextFieldValidate
  }

  override func didReceiveMemoryWarning() {
  //----------------------------------------------------------------------------
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @objc func dismissKeyboard() {
  //----------------------------------------------------------------------------
    view.endEditing(true)
  }

  func inputTextFieldChanged(_ sender: AnyObject, text: String, status: NBPictureMask.Status) {
  //----------------------------------------------------------------------------
  // Highlight the edit field background color

    if let textField = sender as? UITextField {
      switch (text, status) {
      case ("",    _):    textField.backgroundColor = UIColor.clear
      case (_, .ok):      textField.backgroundColor = UIColor.clear
      case (_, .okSoFar): textField.backgroundColor = UIColor.yellow
      case (_, .notOk):   textField.backgroundColor = UIColor.red
      }
    }
  }

  func dateUSTextFieldValidate(_ sender: AnyObject, text: String, status: NBPictureMask.Status) -> Bool {
  //----------------------------------------------------------------------------
  // Validate date string in "mm/dd/yyyy" format.

    guard status == .ok else { return true }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let date = dateFormatter.date(from: text)

    return date != nil
  }

  func dateISOTextFieldValidate(_ sender: AnyObject, text: String, status: NBPictureMask.Status) -> Bool {
  //----------------------------------------------------------------------------
  // Validate date string in "yyyy-mm-dd" format.

    guard status == .ok else { return true }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.date(from: text)

    return date != nil
  }

}
