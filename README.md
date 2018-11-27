# NBPictureMaskField

UITextField subclass that allows a person to specify what may be entered in a text field by use of a `pictureMask`.
This was inspired by the Picture field in Paradox Databases.
It allows managing the editing process and validating the text during input.

The `pictureMask` can specify what letters, digits, and special characters may be entered.
It also can create a template of how they should look and must match.
If the data entered does not match then it can be ignored with `enforceMask`.
An option to `autofill` constant characters is also available to speed data entry.

## Installation

The component may be added to your project a few different ways.

#### Source Code

The source can simply be copied into your project folder.
It is available here: https://github.com/nkboland/NBPictureMaskField

#### Swift Package Manager

It can also be installed by the Swift Package Manager.
Create a dependency in your Package:

    .package(url: https://github.com/nkboland/NBPictureMaskField.git", from: "1.0.0"),

#### Application Example

An example of how this might be used in an application can be found here:
https://github.com/nkboland/NBPictureMaskFieldApplication

## Usage

#### Declaration

    class NBPictureMaskField : UITextField

#### Interface Builder Attributes

    var pictureMask: String
    var autofill: Bool
    var enforceMask: Bool

#### Class Variables

    var maskErrorMessage: String?
    var maskTreeToString: String

#### Class Functions

    func check(text: String) -> NBPictureMask.CheckResult

#### Closures

    var validate: ValidateClosure?
    var changed: ChangedClosure?

    ValidateClosure(sender: AnyObject, text: String, status: NBPictureMask.Status)
    ChangedClosure(sender: AnyObject, text: String, status: NBPictureMask.Status)

## Picture Mask

The `pictureMask` uses the following characters to describe allowable input:


    #     Any digit 0..9
    ?     Any letter a..z or A..Z
    &     Any letter a..z or A..Z which is automatically converted to uppercase
    ~     Any letter a..z or A..Z which is automatically converted to lowercase
    @     Any character
    !     Any character which is automatically converted to uppercase
    ;     The next character is taken literally
    *     Repeat the specified number of times
    {a,b} Grouping operation
    [a,b] Optional sequence of characters

Note - The mask is matched left to right.
You must be careful to avoid situations where one element is completely contained in another.

#### Grouping {a,b}

Each group is examined left to right.
The first group that matches will be used.
Two or more groups are separated with a comma.

#### Optional [a,b]

This is similar to the grouping operation but the characters are not required.
Two or more optional items are separated with a comma.

#### Repeat *

The symbol following the repeat character is optionally repeated any number of times.
If a numeric value is specified then it must match that exact number of times.

#### Examples

    #                 One digit
    ##                Two digits
    *5#               Five digits
    #*#               One digit followed by any number of other digits
    #&                Single digit followed by single character converted to uppercase
    #[#]              One or two digits
    #*4[#]            One to five digits
    {#,&}             Digit or character converted to uppercase
    #####[-####]      Zipcode with optional plus four
    [+,-]#*#[.*#]     1, +1, +1., -1.0, 123.456

#### Literals

Literal letters are automatically case converted.
For example:

    {Red,Yellow}      If the Input is "RED" the output is "Red"

The space (' ') character is automatically matched to the next literal character.
For example:

    (###) ###-####    Entered as <' '>123<' '><' '>456<' '>7890 gives "(123) 456-7890"

#### Other Examples

    [(###)]###-####   Phone number with optional area code
    Yes, No           Has two possible values: "Yes", or "No"
    &*@               First letters is converted to uppercase as desired
    ;&##              An ampersand followed by two digits
    {+,-}*#[.]*#      Start with either + or -, followed by a number of digits, with optionally a dot somewhere

## License
NBPictureMaskField is available under the MIT license.
See the LICENSE.txt file for more info.
