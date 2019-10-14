//
//  DropDownModel.swift
//  Oncoclinicas
//
//  Created by Anderson Carvalho on 08/11/17.
//  Copyright © 2017 asfcarvalho. All rights reserved.
//

import UIKit
import DropDown

enum TextFieldBorderTypeEnum {
    case Solid,
    Bottom
}

public class UITextFieldCustom: UITextField {
    
    fileprivate let maxDigits = 12
    
    fileprivate var defaultValue: Double = 0.00
    
    fileprivate let currencyFormattor = NumberFormatter()
    
    fileprivate var previousValue : String = ""
    
    var textTemp = ""
    
    fileprivate var anchorView: UIView!
    fileprivate var dropDownInfo: DropDown?
    fileprivate var dropDownList: [String]?
    
    public var dropDownDelegate: DropDownDelegate?
    public var dropDownDataSource: DropDownDataSource?
    
    static fileprivate let titleColorDefault = UIColor(white: 0.0, alpha: 0.92)
    
    fileprivate var iconDefault: UIImageView?
    
    fileprivate let viewDropDown: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    public var iconImage: UIImageView? = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView
    }()
    
    public let iconPassword: UIImageView? = {
       let imageView = UIImageView()
        
        let bundle = Bundle(for: UITextFieldCustom.self)
        guard let image = UIImage(named: "iconEyeOpen", in: bundle, compatibleWith: nil) else {
            fatalError("Missing iconEyeOpen...")
        }
        guard let highlightImage = UIImage(named: "iconEyeHided", in: bundle, compatibleWith: nil) else {
            fatalError("Missing iconEyeHided...")
        }
        
        imageView.image = image
        imageView.highlightedImage = highlightImage
        return imageView
    }()
    
    public let iconDropDown: UIImageView = {
        let imageView = UIImageView()
        let bundle = Bundle(for: UITextFieldCustom.self)
        guard let image = UIImage(named: "ic_dropDown", in: bundle, compatibleWith: nil) else {
            fatalError("Missing ic_dropDown...")
        }
        
        imageView.image = image
        return imageView
    }()
    
    fileprivate var isShowPassword = false
    
    weak var textFieldCustomDelegate: UITextFieldCustomProtocol?
    
    fileprivate var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    
    /// To set the max number of text characters
    ///
    /// Set **0** to disable
    ///
    /// By default, the function is disabled
    var maxCharacter = 0
    
    /// To set the mask pattern
    ///
    /// sample `(**) *****-****`
    var countryCode = ""
    var formattingMaskPattern = ""
    var replacementChar: Character = "9"
    var isCPFOrCNPJ: Bool = false
    var isJustCPF: Bool = false
    var fontColor = UIColor.black
    
    //MARK: PreTextLabel
    fileprivate let textLabel = UILabel()
    
    public var textFont: UIFont? {
        didSet {
            setupTextField()
        }
    }
    
    public var heigthText: CGFloat?
    public var preTextFont: UIFont?
    public var preTextLabel: String? {
        didSet {
            setupPreText()
        }
    }
    
    
    var borderType: TextFieldBorderTypeEnum = TextFieldBorderTypeEnum.Bottom {
        didSet {
            setupTextField()
        }
    }
    
    var isCurrencyNumber: Bool = false {
        didSet {
            if isCurrencyNumber {
                initTextField()
            }
        }
    }
    
    var isRightToLeft: Bool = false
    var isFloatFormat: Bool = false
    var formatType = ""
    var isNewFormat: Bool = false
    var isMutant: Bool = false
    var minCharMutant = 9
    
    var showIcon: Bool = false {
        didSet {
            if iconImage != nil {
                setupIcon()
            }
        }
    }
    
    var isPassword: Bool = false {
        didSet {
            setupIcon()
        }
    }
    
    var isDropDown: Bool = false {
        didSet {
            setupIcon()
        }
    }
    
    var isDropDownEditable: Bool = false {
        didSet {
            setupIcon()
        }
    }
    
    @objc public dynamic var lineViewColor = UIColor(red: 230/255, green: 231/255, blue: 236/255, alpha: 1.0) {
        willSet {
            lineView.backgroundColor = newValue
        }
    }
    
    public var lineViewSelectedColor: UIColor = UIColor(red: 149/255, green: 193/255, blue: 15/255, alpha: 1.0)
    public var lineViewSize: CGFloat = 2.0
    
    fileprivate lazy var lineView: UIView = { [weak self] in
       let line = UIView()
        line.backgroundColor = self?.lineViewColor
        return line
    }()
    
    /// To set string of message to show on error
    /// by default `Error`
    var errorMessage: String = "Error"
    
    fileprivate lazy var _errorMessage: UILabel = { [weak self] in
        let label = UILabel()
        label.text = self?.errorMessage //by default
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    @objc fileprivate dynamic var _title: String?
    @objc fileprivate dynamic var _titleSize: CGFloat = 16
    @objc fileprivate dynamic var _titleColor: UIColor = titleColorDefault
    
    public var titleSize: CGFloat? {
        didSet {
            self._titleSize = titleSize ?? 2
            setupTextField()
        }
    }
    
    public var titleColor: UIColor? {
        didSet {
            self._titleColor = titleColor ?? UITextFieldCustom.titleColorDefault
            setupTextField()
        }
    }
    
    public var title: String? {
        didSet {
            self._title = title
            setupTextFieldtitle()
        }
    }
    
    @objc fileprivate dynamic var _placeHolder: String?
    
    public override var placeholder: String? {
        didSet {
            self._placeHolder = placeholder
            self.attributedPlaceholder = NSAttributedString(string: _placeHolder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.brownGrey])
            setupTextField()
        }
    }
    
    fileprivate lazy var textFieldTitle: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "SofiaPro-Regular", size: 16)
        label.clipsToBounds = false
        return label
    }()
    
    /// To set the error message color
    ///
    /// by default *Red*
    var errorColor: UIColor = UIColor(red: 255/255, green: 74/255, blue: 61/255, alpha: 1.0)
    /// To set the error message font size
    ///
    /// by default *12.0*
    var errorFontSize: CGFloat = 12.0
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        setupTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public func setupTitle(_ title: String?, _ size: CGFloat? = nil, _ color: UIColor? = nil) {
        self._title = title
        self._titleSize = size ?? 16
        self._titleColor = color ?? UITextFieldCustom.titleColorDefault
        setupTextField()
    }
    
    fileprivate func setupTextField() {
        
        self.font = textFont
        self.textColor = fontColor
        self.backgroundColor = UIColor.clear
        
        self.addTarget(self, action: #selector(textDidChange), for: UIControl.Event.editingChanged)
        self.addTarget(self, action: #selector(textDidBeginEditing), for: UIControl.Event.editingDidBegin)
        self.addTarget(self, action: #selector(textDidEndEditing), for: UIControl.Event.editingDidEnd)
        
        
        //MARK: Border type
        if borderType == TextFieldBorderTypeEnum.Solid {
            lineView.removeFromSuperview()
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.black.cgColor
        }else {
            setupLineBottom(lineViewSize)
        }
        
        self.returnKeyType = .next
        
        //MARK: Title
        setupTextFieldtitle()
  
        self.returnKeyType = .next
    }
    
    fileprivate func setupPreText() {
        //MARK: PreText
        if let text = preTextLabel {
            getConstraint()
            textLabel.removeFromSuperview()
            textLabel.font = preTextFont
            textLabel.text = text
            textLabel.textColor = fontColor
            textLabel.minimumScaleFactor = 0.5
            textLabel.adjustsFontSizeToFitWidth = true
            self.addSubview(textLabel)
            let textSizeTemp = textSize(text, self.frame.width)
            textLabel.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: nil, centerX: nil, centerY: nil, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: textSizeTemp.width + 8, height: textSizeTemp.height))
            padding = UIEdgeInsets(top: padding.top, left: textSizeTemp.width + 8, bottom: padding.bottom, right: padding.right)
        }
    }
    
    fileprivate func textSize(_ text: String, _ width: CGFloat) -> CGRect {
        let constraintRect = CGSize(width: width, height: heigthText ?? .greatestFiniteMagnitude)
        let font = preTextFont ?? UIFont.systemFont(ofSize: 16)
        let boundingBox = text.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox
    }
    
    fileprivate func getConstraint() {
        for constraint in self.constraints {
            print(constraint)
        }
    }
    
    fileprivate func setupLineBottom(_ height: CGFloat = 0.5) {
        lineView.removeFromSuperview()
        self.addSubview(lineView)
        lineView.anchor(top: self.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: height))
    }
    
    fileprivate func setupTextFieldtitle() {
        self.backgroundColor = .clear
        textFieldTitle.removeFromSuperview()
        textFieldTitle.font = UIFont(name: "SofiaPro-Regular", size: _titleSize)
        textFieldTitle.textColor = self._titleColor
        textFieldTitle.text = self._title ?? self._placeHolder
        self.addSubview(textFieldTitle)
        self.bringSubviewToFront(textFieldTitle)
        textFieldTitle.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: UIEdgeInsets(top: -8, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: _titleSize + 2))
        if self._title == nil {
            textFieldTitle.alpha = 0.0
        }else {
            textFieldTitle.alpha = 1.0
        }
    }
    
    //MARK: setup currency number
    func initTextField(){
        self.keyboardType = UIKeyboardType.decimalPad
        currencyFormattor.numberStyle = .currency
        currencyFormattor.minimumFractionDigits = 2
        currencyFormattor.maximumFractionDigits = 2
        currencyFormattor.currencySymbol = ""
        setAmount(defaultValue)
    }
    
    //MARK: Dropdown configuration
    fileprivate func configDropDown(_ anchorView: UIView? = nil) {
        dropDownInfo = DropDown()
        
        if let anchorView = anchorView {
            dropDownInfo?.anchorView = anchorView
        }else {
            let anchorView = UIView()
            self.addSubview(anchorView)
            anchorView.anchor(top: self.bottomAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
            dropDownInfo?.anchorView = anchorView
        }
        
        dropDownInfo?.direction = .bottom
        dropDownInfo?.dismissMode = .onTap
        dropDownInfo?.bottomOffset = CGPoint(x: 0, y:(dropDownInfo?.anchorView?.plainView.bounds.height)!)
        dropDownInfo?.topOffset = CGPoint(x: 0, y:-(dropDownInfo?.anchorView?.plainView.bounds.height)!)
        
        dropDownInfo?.selectionAction = selected(_:_:)
        
        DropDown.appearance().selectionBackgroundColor = UIColor(red: 206, green: 206, blue: 206, alpha: 1)
        
        dropDownInfo?.cancelAction = {() in
            self.hideAction()
        }
    }
    
    fileprivate func hideAction() {
        if self.isDropDownEditable {
            if let selectedIndex = self.dropDownInfo?.dataSource.firstIndex(of: self.text ?? "") {
                self.selected(selectedIndex, self.dropDownInfo?.dataSource[selectedIndex] ?? "")
                //                self.fadeInOut(true)
            }else {
                self.dropDownDelegate?.dropDownCanceled(self)
                //                self.fadeInOut(true)
            }
        }else if self.text?.isEmpty == true {
            self.dropDownDelegate?.dropDownCanceled(self)
        }
        self.dropDownInfo?.hide()
    }
    
    //MARK: Dropdown
    public func reloadData() {
        
        if let numberOfRows = dropDownDataSource?.numberOfRows(self) {
            
            var list = [String]()
            
            for i in 0..<numberOfRows {
                list.append(dropDownDataSource?.dropDown(self, itemByRow: i) ?? "")
            }
            
            dropDownInfo?.dataSource = list
            dropDownList = list
            
            
            if self._placeHolder == nil {
                DispatchQueue.main.async {
                    self.text = list.first
                    self.dropDownDelegate?.dropDownAction(self, 0, list.first ?? "")
                }
            }
        }
    }
    
    fileprivate func selected(_ index: Int, _ value: String) {
        DispatchQueue.main.async {
            self.text = value
        }
        let indexFilter = dropDownList?.firstIndex(of: value) ?? 0
        dropDownDelegate?.dropDownAction(self, indexFilter, value)
//        fadeInOut(true)
    }
    
    //MARK: Setup password or DropDown icon
    fileprivate func setupIcon() {
        
        iconDefault?.removeFromSuperview()
        viewDropDown.removeFromSuperview()
        
        padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        var iconSize = CGSize(width: 15, height: 15)
        
        if showIcon && iconImage != nil {
            
            iconDefault = iconImage
            
            let tapIcon = UITapGestureRecognizer(target: self, action: #selector(iconAction))
            iconDefault?.addGestureRecognizer(tapIcon)
            iconDefault?.isUserInteractionEnabled = true
            padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 33)
            iconSize = CGSize(width: 25, height: 25)
        }
        
        if isPassword {
            
            iconDefault = iconPassword
            
            let tapIconPassword = UITapGestureRecognizer(target: self, action: #selector(showPasswordAction))
            iconDefault?.addGestureRecognizer(tapIconPassword)
            iconDefault?.isUserInteractionEnabled = true
            padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
            
            showPasswordAction()
        }
        
        if isDropDown || isDropDownEditable {
            iconDefault = iconDropDown
            
            let tapTextField = UITapGestureRecognizer(target: self, action: #selector(showDropDown))
            
            padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
            
            viewDropDown.addGestureRecognizer(tapTextField)
            viewDropDown.isUserInteractionEnabled = true
            
            self.addSubview(viewDropDown)
            
            viewDropDown.fillSuperview()
            configDropDown()
        }
        
        self.addSubview(iconDefault ?? UIImageView())
        
        iconDefault?.anchor(top: nil, leading: nil, bottom: nil, trailing: self.trailingAnchor, centerX: nil, centerY: self.centerYAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8), size: iconSize)
    }
    
    @objc func showDropDown() {
        
        
        if isDropDownEditable {
            self.becomeFirstResponder()
        }
        
        dropDownInfo?.show()
    }
    //MARK: Icon Action
    @objc fileprivate func iconAction() {
        textFieldCustomDelegate?.onIconTapUp?(self)
    }
    
    @objc fileprivate func showPasswordAction() {
        iconDefault?.isHighlighted = !isShowPassword
        self.isSecureTextEntry = !isShowPassword
        isShowPassword.toggle()
    }
    
//    deinit {
//        notificationCenter.removeObserver(self)
//    }
    
    @objc fileprivate func textDidBeginEditing() {
        setupErrorMessage(nil, true)
        textFieldCustomDelegate?.onTextDidBeginEditing?(self)
//        lineView.backgroundColor = lineViewSelectedColor
    }
    
    @objc fileprivate func textDidEndEditing() {

        if isDropDown || isDropDownEditable {
            hideAction()
        }else {
            textFieldCustomDelegate?.onTextDidChange(self)
        }
        
    }
    
    fileprivate func fadeInOut(_ isIn: Bool) {
        if isIn {
            if self.borderType != TextFieldBorderTypeEnum.Solid {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.transitionCurlUp, animations: {
                    self.textFieldTitle.alpha = 1.0
                }, completion: nil)
            }
            
        }else {
            if self.borderType != TextFieldBorderTypeEnum.Solid {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.transitionCurlDown, animations: {
                    self.textFieldTitle.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
    // MARK: used to put the mask in textfield
    @objc fileprivate func textDidChange() {
        
        if _title == nil {
            if (self.text?.count ?? 0) == 1 {
                fadeInOut(true)
                
            }else if (self.text?.count ?? 0) < 1 {
                fadeInOut(false)
            }
        }
        
        // just to verify if is CPF or CNPJ
        if isCPFOrCNPJ || isJustCPF {
            let tempString = UITextFieldCustom.makeOnlyDigitsString(text ?? "")
            verifyCPFOrCNPJ(tempString)
        }
        
        if isCurrencyNumber {
            
            
        }else {
            if isRightToLeft {
                var finalText = ""
                if let text = text, text.count > 0 {
                    
                    if formattingMaskPattern.count <= String(Int(UITextFieldCustom.makeOnlyDigitsNumber(text)) ?? 0).count && isMutant {
                        if let range = formatType.range(of: String(formattingMaskPattern.count - 1)) {
                            formatType.replaceSubrange(range, with: String(formattingMaskPattern.count))
                            formattingMaskPattern.insert("9", at: formattingMaskPattern.startIndex)
                        }
                    }else if String(Int(UITextFieldCustom.makeOnlyDigitsNumber(text)) ?? 0).count >= minCharMutant && formattingMaskPattern.count > (minCharMutant + 1) && isMutant {
                        if let range = formatType.range(of: String(formattingMaskPattern.count - 1)) {
                            formatType.replaceSubrange(range, with: String(String(Int(UITextFieldCustom.makeOnlyDigitsNumber(text)) ?? 0).count))
                            formattingMaskPattern.removeFirst()
                        }
                    }
                    
                    if isFloatFormat {
                        finalText = String(format: formatType, Double(text) ?? 0)
                    }else {
                        finalText = String(format: formatType, Int(UITextFieldCustom.makeOnlyDigitsNumber(text)) ?? 0)
                    }
                    if isNewFormat {
                        
                        finalText = finalText.format(with: formattingMaskPattern)
                    }
                }
                
                self.text = finalText
            }
            if let text = text, text.count > 0 && formattingMaskPattern.count > 0, !isNewFormat {
                let tempString = UITextFieldCustom.makeOnlyDigitsString(text)
                
                var finalText = ""
                var stop = false
                
                var formatterIndex = formattingMaskPattern.startIndex
                var tempIndex = tempString.startIndex
                
                var offsetFormat = 1
                var offsetTemp = 1
                
                while !stop {
                    let formattingPatternRange = formatterIndex..<RangeCustom.stringIndex(formattingMaskPattern, offsetFormat)
                    
                    if formattingMaskPattern[formattingPatternRange] != String(replacementChar) {
                        
                        finalText = finalText.appendingFormat(formattingMaskPattern[formattingPatternRange])
                        
                    }else if tempString.count > 0 {
                        let pureStringRange = tempIndex..<RangeCustom.stringIndex(tempString, offsetTemp)
                        finalText = finalText.appending(tempString[pureStringRange])
                        tempIndex = RangeCustom.stringIndex(tempString, offsetTemp)
                        offsetTemp += 1
                    }
                    
                    formatterIndex = RangeCustom.stringIndex(formattingMaskPattern, offsetFormat)
                    offsetFormat += 1
                    
                    if offsetFormat > formattingMaskPattern.count || offsetTemp > tempString.count {
                        stop = true
                    }
                }
                
                self.text = finalText
            }
        }
        
        if isDropDownEditable {
            
            setupErrorMessage(nil, true)
            
            dropDownInfo?.show()
            if text?.isEmpty == true {
                dropDownInfo?.dataSource = dropDownList ?? []
//                fadeInOut(false)
            }else {
                dropDownInfo?.dataSource = dropDownList?.filter({ (item) -> Bool in
                    return item.lowercased().contains(text?.lowercased() ?? "")
                }) ?? []
//                fadeInOut(true)
            }
            
            
//            textFieldCustomDelegate?.onTextDidChange(self)
        }
        
    }
    
    // return the string without special characters
    static func makeOnlyDigitsNumber(_ string: String) -> String {
        
        let result = string.filter { (value) -> Bool in
            return String(value).range(of: "([0-9])", options: String.CompareOptions.regularExpression, range: nil, locale: nil) != nil
        }
        
        return result
    }
    
    // return the string without special characters
    static func makeOnlyDigitsString(_ string: String) -> String {
        
        let result = string.filter { (value) -> Bool in
            return String(value).range(of: "([A-Za-z0-9])", options: String.CompareOptions.regularExpression, range: nil, locale: nil) != nil
        }
        
        return result
    }
    
    // just for cpf or cnpj
    fileprivate func verifyCPFOrCNPJ(_ textTemp: String) {
        
        if textTemp.count <= 11 {
            formattingMaskPattern = "999.999.999-99"
        }else if !isJustCPF {
            formattingMaskPattern = "99.999.999/9999-99"
        }
    }
    //MARK: Error message
    fileprivate func setupErrorMessage(_ isError: Bool? = nil, _ isSelected: Bool = false) {
        DispatchQueue.main.async {
            self._errorMessage.removeFromSuperview()
            if isError == true {
                self._errorMessage.text = self.errorMessage
                self._errorMessage.font = UIFont(name: "SofiaPro-Regular", size: self.errorFontSize)
                self._errorMessage.textColor = self.errorColor
                if self.borderType == TextFieldBorderTypeEnum.Solid {
                    self.layer.borderColor = self.errorColor.cgColor
                }else {
                    self.lineView.backgroundColor = self.errorColor
                }
                self.addSubview(self._errorMessage)
                self.messageAnchor()
            }else if isError == false {
                if self.borderType == TextFieldBorderTypeEnum.Solid {
                    self.layer.borderColor = self.lineViewColor.cgColor
                }else {
                    self.lineView.backgroundColor = self.lineViewSelectedColor
                }
            }else {
                if self.borderType == TextFieldBorderTypeEnum.Solid {
                    self.layer.borderColor = self.lineViewColor.cgColor
                }else {
                    self.lineView.backgroundColor = self.lineViewColor
                }
            }
        }        
    }
    
    fileprivate func messageAnchor() {
        let messageSize = _errorMessage.textRect(forBounds: self.frame, limitedToNumberOfLines: 0)
        var top: CGFloat = 2
        if self.borderType != TextFieldBorderTypeEnum.Solid {
            top = 2
        }
            
        _errorMessage.anchor(top: self.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: UIEdgeInsets(top: top, left: 4, bottom: 0, right: 4), size: CGSize(width: 0, height: messageSize.height))
    }
    
    /// use to set error in the textfield
    /// - Parameters:
    ///     - isError: **True** to show error message or **False** to hide
    /// - Paramters configuration:
    ///     - *errorFontSize* to set the error message font size
    ///     - *errorColor* to set the error message color
    func setError(_ isError: Bool, _ message: String? = nil) {
        
        if let message = message {
            self.errorMessage = message
        }
        
        setupErrorMessage(!isError)
        
    }
    
    //MARK: - Custom text field functions
    
    func setAmount (_ amount : Double){
        let textFieldStringValue = currencyFormattor.string(from: NSNumber(value: amount))
        self.text = textFieldStringValue
        if let textFieldStringValue = textFieldStringValue{
            previousValue = textFieldStringValue
        }
    }
    
    //MARK - helper functions
    
    fileprivate func getCleanNumberString() -> String {
        var cleanNumericString: String = ""
        let textFieldString = self.text
        if let textFieldString = textFieldString{
            
            //Remove $ sign
            var toArray = textFieldString.components(separatedBy: "$")
            cleanNumericString = toArray.joined(separator: "")
            
            //Remove periods, commas
            toArray = cleanNumericString.components(separatedBy: CharacterSet.punctuationCharacters)
            cleanNumericString = toArray.joined(separator: "")
        }
        
        return cleanNumericString
    }
    
    fileprivate func getOriginalCursorPosition() -> Int{
        
        var cursorOffset : Int = 0
        let startPosition : UITextPosition = self.beginningOfDocument
        if let selectedTextRange = self.selectedTextRange{
            cursorOffset = self.offset(from: startPosition, to: selectedTextRange.start)
        }
        return cursorOffset
    }
    
    fileprivate func setCursorOriginalPosition(_ cursorOffset: Int, oldTextFieldLength : Int?){
        
        let newLength = self.text?.count
        let startPosition : UITextPosition = self.beginningOfDocument
        if let oldTextFieldLength = oldTextFieldLength, let newLength = newLength, oldTextFieldLength > cursorOffset{
            let newOffset = newLength - oldTextFieldLength + cursorOffset
            let newCursorPosition = self.position(from: startPosition, offset: newOffset)
            if let newCursorPosition = newCursorPosition{
                let newSelectedRange = self.textRange(from: newCursorPosition, to: newCursorPosition)
                self.selectedTextRange = newSelectedRange
            }
            
        }
    }
    
}

@objc protocol UITextFieldCustomProtocol: NSObjectProtocol {
    func onTextDidChange(_ sender: UITextFieldCustom)
    @objc optional func onTextDidBeginEditing(_ sender: UITextFieldCustom)
    @objc optional func onIconTapUp(_ sender: UITextFieldCustom)
}

//MARK: DropDown Protocol
public protocol DropDownDelegate {
    func dropDownAction(_ dropDown: UITextFieldCustom, _ index: Int, _ value: String)
    func dropDownCanceled(_ dropDown: UITextFieldCustom)
}

@objc public protocol DropDownDataSource {
    func numberOfRows(_ dropDown: UITextFieldCustom) -> Int
    func dropDown(_ dropDown: UITextFieldCustom, itemByRow: Int) -> String
    @objc optional func dropDownTitle(_ dropDown: UITextFieldCustom) -> String?
}

