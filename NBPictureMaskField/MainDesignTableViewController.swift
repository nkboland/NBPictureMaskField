//
//  MainDesignTableViewController.swift
//  NBPictureMaskField
//
//  Created by Nick Boland on 4/12/16.
//  Copyright © 2016 Nick Boland. All rights reserved.
//

import UIKit

class MainDesignTableViewController: UITableViewController, UITextFieldDelegate {
//------------------------------------------------------------------------------

  @IBOutlet weak var maskStatusLabel: UILabel!
  @IBOutlet weak var maskTextField: UITextField!
  @IBOutlet weak var inputStatusLabel: UILabel!
  @IBOutlet weak var inputTextField: NBPictureMaskField!
  @IBOutlet weak var autoFillSwitch: UISwitch!
  @IBOutlet weak var enforceMaskSwitch: UISwitch!
  @IBOutlet weak var maskTreeLabel: UILabel!

  override func viewDidLoad() {
  //----------------------------------------------------------------------------
    super.viewDidLoad()

    // Configure table to automatically resize its rows in conjunction with tableView(_:heightForRowAtIndexPath:indexPath)
    tableView.estimatedRowHeight = 68.0
    tableView.rowHeight = UITableView.automaticDimension

    // Dismiss keyboard when tapping outside text field
    let tap = UITapGestureRecognizer(target: self, action: #selector(MainDesignTableViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)

    // We need to update things when field is edited
    maskTextField.delegate = self

    inputTextField.changed = inputTextFieldChanged

    // Load defaults
    loadDefaults(self)

    // Update any changes
    maskFieldEditingChanged(maskTextField)
  }

  override func didReceiveMemoryWarning() {
  //----------------------------------------------------------------------------
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  //----------------------------------------------------------------------------
    return UITableView.automaticDimension
  }

  func loadDefaults(_ sender: AnyObject) {
  //----------------------------------------------------------------------------
    let defaults = UserDefaults.standard
    maskTextField.text = defaults.string(forKey: "maskTextField")
    autoFillSwitch.isOn = defaults.bool(forKey: "autoFillSwitch")
    enforceMaskSwitch.isOn = defaults.bool(forKey: "enforceMaskSwitch")

    inputTextField.pictureMask = maskTextField.text ?? ""
    inputTextField.autoFill = autoFillSwitch.isOn
    inputTextField.enforceMask = enforceMaskSwitch.isOn

    inputTextField.text = defaults.string(forKey: "inputTextField")
  }

  func saveDefaults(_ sender: AnyObject) {
  //----------------------------------------------------------------------------
    let defaults = UserDefaults.standard
    defaults.set(maskTextField.text, forKey: "maskTextField")
    defaults.set(autoFillSwitch.isOn, forKey: "autoFillSwitch")
    defaults.set(enforceMaskSwitch.isOn, forKey: "enforceMaskSwitch")
    defaults.set(inputTextField.text, forKey: "inputTextField")
  }

  @IBAction func switchValueChanged(_ sender: AnyObject) {
  //----------------------------------------------------------------------------
    inputTextField.autoFill = autoFillSwitch.isOn
    inputTextField.enforceMask = enforceMaskSwitch.isOn
    saveDefaults(sender)
  }

  @IBAction func maskButtonAction(_ sender: AnyObject) {
  //----------------------------------------------------------------------------
    let button = sender as! UIButton
    inputTextField.text = ""
    maskTextField.text = button.titleLabel?.text
    maskFieldEditingChanged(maskTextField)
  }


  @IBAction func maskFieldEditingChanged(_ sender: AnyObject) {
  //----------------------------------------------------------------------------
  // Update things when the mask changes.

    let textField = sender as! UITextField
    let mask = textField.text ?? ""

    inputTextField.pictureMask = mask
    let errMsg = inputTextField.maskErrMsg

    maskStatusLabel.text = errMsg ?? "Mask ok"
    maskTreeLabel.text = inputTextField.maskTreeToString

    tableView.reloadData()

    saveDefaults(sender)
  }

  func inputTextFieldChanged(_ sender: AnyObject, text: String, status: NBPictureMask.Status) {
  //----------------------------------------------------------------------------
  // Update things when the text changes.

    // Highlight the edit field background color
    if let textField = sender as? UITextField {
      switch (text, status) {
      case ("",    _):    textField.backgroundColor = UIColor.clear
      case (_, .ok):      textField.backgroundColor = UIColor.clear
      case (_, .okSoFar): textField.backgroundColor = UIColor.yellow
      case (_, .notOk):   textField.backgroundColor = UIColor.red
      }
    }

    // Update the input status label
    if let pictureMaskField = sender as? NBPictureMaskField {
      let checkVal = pictureMaskField.check(text)
      switch (text, status) {
      case ("",    _):    inputStatusLabel.text = "No input"
      case (_, .ok):      inputStatusLabel.text = "Ok"
      case (_, .okSoFar): inputStatusLabel.text = "Ok so far"
      case (_, .notOk):   inputStatusLabel.text = "Error: \(checkVal.errMsg ?? "")"
      }
    }

    saveDefaults(sender)
  }

  @objc func dismissKeyboard() {
  //----------------------------------------------------------------------------
    view.endEditing(true)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
  //----------------------------------------------------------------------------
    dismissKeyboard()
    return false
  }

}
