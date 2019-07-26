//
//  UITextField+custom.swift
//  GenBit
//
//  Created by Proaire on 01/07/19.
//  Copyright © 2019 Treepart. All rights reserved.
//

import UIKit

@objc public protocol UITextFieldCustomProtocol {
    func onTextDidChange(_ sender: UITextFieldCustom)
    @objc optional func onTextDidEndEditing(_ sender: UITextFieldCustom)
    func setErrorDropDown(_ isError: Bool)
}

public class UITextFieldCustom: UITextField {
    
    public let iconPassword: UIImageView? = {
       let image = UIImageView()
        image.image = UIImage(named: "iconEyeOpen")
        image.highlightedImage = UIImage(named: "iconEyeHided")
        return image
    }()
    
    fileprivate var isShowPassword = false
    
    public var textFieldCustomDelegate: UITextFieldCustomProtocol?
    
    fileprivate var padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    /// To set the max number of text characters
    ///
    /// Set **0** to disable
    ///
    /// By default, the function is disabled
    var maxCharacter = 0
    
    /// To set the mask pattern
    ///
    /// sample `(**) *****-****`
    var formattingMaskPattern = ""
    var replacementChar: Character = "*"
    var isCPFOrCNPJ: Bool = false
    var isJustCPF: Bool = false
    var isDropDown: Bool = false
    
    var isPassword: Bool = false {
        didSet {
            setupIconPassword()
        }
    }
    
    /// To set string of message to show on error
    /// by default `Error`
    var errorMessage: String = "Error"
    
    fileprivate lazy var _errorMessage: UILabel = { [weak self] in
        let label = UILabel()
        label.text = self?.errorMessage //by default
        label.numberOfLines = 0
        return label
    }()
    
    /// To set the error message color
    ///
    /// by default *Red*
    var errorColor: UIColor = UIColor.red
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
    
    init(_ isDropDown: Bool = false) {
        super.init(frame: CGRect.zero)
        self.isDropDown = isDropDown
        setupTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupTextField() {
        
        self.font = UIFont.systemFont(ofSize: 17)
        if !isDropDown {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = UIColor.black.cgColor
        }
        self.returnKeyType = .next
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: NSNotification.Name(rawValue: "UITextFieldTextDidEndEditingNotification"), object: self)
    }
    
    //MARK: Setup password
    fileprivate func setupIconPassword() {
        
        iconPassword?.removeFromSuperview()
        
        self.addSubview(iconPassword ?? UIImageView())
        
        iconPassword?.anchor(top: nil, leading: nil, bottom: nil, trailing: self.trailingAnchor, centerX: nil, centerY: self.centerYAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8), size: CGSize(width: 15, height: 15))
        
        let tapIconPassword = UITapGestureRecognizer(target: self, action: #selector(showPasswordAction))
        iconPassword?.addGestureRecognizer(tapIconPassword)
        iconPassword?.isUserInteractionEnabled = true
        padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 25)
        
        showPasswordAction()
    }
    
    @objc fileprivate func showPasswordAction() {
        iconPassword?.isHighlighted = !isShowPassword
        self.isSecureTextEntry = !isShowPassword
        isShowPassword.toggle()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func textDidEndEditing() {
        textFieldCustomDelegate?.onTextDidEndEditing?(self)
    }
    
    // MARK: used to put the mask in textfield
    @objc fileprivate func textDidChange() {
        
        // just to verify if is CPF or CNPJ
        if isCPFOrCNPJ || isJustCPF {
            let tempString = makeOnlyDigitsString(text ?? "")
            verifyCPFOrCNPJ(tempString)
        }
        
        if let text = text, text.count > 0 && formattingMaskPattern.count > 0 {
            let tempString = makeOnlyDigitsString(text)
            
            
            
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
        
        if isEnabled {
            textFieldCustomDelegate?.onTextDidChange(self)
        }
        
    }
    
    // return the string without special characters
    fileprivate func makeOnlyDigitsString(_ string: String) -> String {
        
        let result = string.filter { (value) -> Bool in
            return String(value).range(of: "([A-Za-z0-9])", options: String.CompareOptions.regularExpression, range: nil, locale: nil) != nil
        }
        
        return result
    }
    
    // just for cpf or cnpj
    fileprivate func verifyCPFOrCNPJ(_ textTemp: String) {
        
        if textTemp.count <= 11 {
            formattingMaskPattern = "***.***.***-**"
        }else if !isJustCPF {
            formattingMaskPattern = "**.***.***/****-**"
        }
    }
    
    fileprivate func setupErrorMessage() {
        DispatchQueue.main.async {
            self._errorMessage.text = self.errorMessage
            self._errorMessage.font = UIFont.systemFont(ofSize: self.errorFontSize)
            self._errorMessage.textColor = self.errorColor
            if !self.isDropDown {
                self.layer.borderColor = self.errorColor.cgColor
            }else {
                self.textFieldCustomDelegate?.setErrorDropDown(true)
            }
        }        
    }
    
    fileprivate func messageAnchor() {
        let messageSize = _errorMessage.textRect(forBounds: self.frame, limitedToNumberOfLines: 0)
        let topMessage: CGFloat = -4
        _errorMessage.anchor(top: self.bottomAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: UIEdgeInsets(top: topMessage, left: 4, bottom: 0, right: 4), size: CGSize(width: 0, height: messageSize.height))
    }
    
    /// use to set error in the textfield
    /// - Parameters:
    ///     - isError: **True** to show error message or **False** to hide
    /// - Paramters configuration:
    ///     - *errorFontSize* to set the error message font size
    ///     - *errorColor* to set the error message color
    public func setError(_ isError: Bool, _ message: String? = nil) {
        
        if let message = message {
            self.errorMessage = message
        }
        
        if !isError {
            
            setupErrorMessage()
            
            _errorMessage.removeFromSuperview()
            
            self.addSubview(_errorMessage)
            messageAnchor()
            
        }else {
            _errorMessage.removeFromSuperview()
            if !self.isDropDown {
                self.layer.borderColor = UIColor.black.cgColor
            }else {
                self.textFieldCustomDelegate?.setErrorDropDown(false)
            }
        }
    }
    
    
    
}

class RangeCustom {
    
    static func stringIndex(_ string: String, _ offsetBy: Int) -> String.Index {
        
        return string.index(string.startIndex, offsetBy: offsetBy)
        
    }
    
}
