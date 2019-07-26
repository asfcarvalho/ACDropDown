//
//  DropDownModel.swift
//  Oncoclinicas
//
//  Created by Anderson Carvalho on 08/11/17.
//  Copyright © 2017 asfcarvalho. All rights reserved.
//

import Foundation
import UIKit
import DropDown

open class DropDownModel: UIView {
    
    fileprivate var anchorView: UIView!
    fileprivate var dropDownInfo: DropDown?
    fileprivate var dropDownList: [String]?
    
    public var lineViewHeight: CGFloat = 0.5 {
        didSet {
            configView()
        }
    }
    
    @objc fileprivate dynamic var _lineViewColor = UIColor.black {
        willSet {
            lineView.backgroundColor = newValue
        }
    }
    
    public var lineViewColor: UIColor? {
        get {
            return _lineViewColor
        }
        
        set {
            _lineViewColor = newValue ?? UIColor.black
        }
    }
    
    fileprivate lazy var textFieldTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.clipsToBounds = false
        return label
    }()
    
    fileprivate lazy var lineView: UIView = { [weak self] in
       let view = UIView()
        view.backgroundColor = self?.lineViewColor
        return view
    }()
    
    public var delegate: DropDownDelegate?
    public var dataSource: DropDownDataSource?
    
    public let textField = UITextFieldCustom(true)
    public var isEditable: Bool = false {
        didSet {
            configView()
        }
    }
    
    public let icon: UIImageView = {
       let imageView = UIImageView()
        let bundle = Bundle(for: DropDownModel.self)
        guard let image = UIImage(named: "ic_dropDown", in: bundle, compatibleWith: nil) else {
            fatalError("Missing ic_dropDown...")
        }
        
        imageView.image = image
        return imageView
    }()
    
    public init(anchorView: UIView? = nil) {
        super.init(frame: CGRect.zero)
        
        configView()
        configDropDown(anchorView)
        
    }
    
    fileprivate func configView() {
        
        self.setupGestureRecognizer(onClick: self)
        
        //MARK: TextField
        textField.textFieldCustomDelegate = self
        
        textField.removeFromSuperview()
        
        self.addSubview(textField)
        textField.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40))
        textField.isUserInteractionEnabled = isEditable
        
        //MARK: Line
        lineView.removeFromSuperview()
        self.addSubview(lineView)
        lineView.anchor(top: textField.bottomAnchor, leading: textField.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: UIEdgeInsets(top: -8, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: lineViewHeight))
        
        //MARK: Icon
        icon.removeFromSuperview()
        self.addSubview(icon)
        icon.anchor(top: nil, leading: nil, bottom: nil, trailing: self.trailingAnchor, centerX: nil, centerY: self.centerYAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16), size: CGSize(width: 20, height: 20))
        
    }
    
    fileprivate func setupTextFieldtitle(_ title: String) {
        self.textField.placeholder = title
        textFieldTitle.removeFromSuperview()
        textFieldTitle.text = title
        self.addSubview(textFieldTitle)
        textFieldTitle.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 13))
        textFieldTitle.alpha = 0.0
    }
    
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
            if self.textField.text?.isEmpty == true {
                self.delegate?.dropDownCanceled(self)
                self.fadeInOut(false)
            }else if let selectedIndex = self.dropDownInfo?.dataSource.firstIndex(of: self.textField.text ?? "") {
                self.selected(selectedIndex, self.dropDownInfo?.dataSource[selectedIndex] ?? "")
                self.fadeInOut(true)
            }else {
                self.delegate?.dropDownCanceled(self)
                self.fadeInOut(true)
            }
            self.dropDownInfo?.hide()
        }
    }
    
    public func reloadData() {
        
        if let numberOfRows = dataSource?.numberOfRows(self) {
            
            var list = [String]()
            
            for i in 0..<numberOfRows {
                list.append(dataSource?.dropDown(self, itemByRow: i) ?? "")
            }
            
            dropDownInfo?.dataSource = list
            dropDownList = list
            
            
            if let title = dataSource?.dropDownTitle?(self) {
                DispatchQueue.main.async {
                    self.setupTextFieldtitle(title)
                }
            }else {
                DispatchQueue.main.async {
                    self.textField.text = list.first
                    self.delegate?.dropDownAction(self, 0, list.first ?? "")
                }
            }
        }
    }
    
    fileprivate func selected(_ index: Int, _ value: String) {
        DispatchQueue.main.async {
            self.textField.text = value
        }
        delegate?.dropDownAction(self, index, value)
        fadeInOut(true)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupGestureRecognizer(onClick: AnyObject) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(setupDropDownActions))
        onClick.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    fileprivate func fadeInOut(_ isIn: Bool) {
        if isIn {
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.transitionCurlUp, animations: {
                self.textFieldTitle.alpha = 1.0
            }, completion: nil)
            
        }else {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.transitionCurlDown, animations: {
                self.textFieldTitle.alpha = 0.0
            }, completion: nil)
        }
    }
    
    @objc fileprivate func setupDropDownActions(_ sender: AnyObject?) {
        dropDownInfo?.show()
        
    }
}

extension DropDownModel: UITextFieldCustomProtocol {
    public func setErrorDropDown(_ isError: Bool) {
        if isError {
            self.layer.borderColor = UIColor.red.cgColor
            self.textFieldTitle.textColor = UIColor.red
        }else {
            self.layer.borderColor = UIColor.black.cgColor
            self.textFieldTitle.textColor = UIColor.black
        }
    }
    
    public func onTextDidChange(_ sender: UITextFieldCustom) {
        dropDownInfo?.show()
        if textField.text?.isEmpty == true {
            dropDownInfo?.dataSource = dropDownList ?? []
            fadeInOut(false)
        }else {
            dropDownInfo?.dataSource = dropDownList?.filter({ (item) -> Bool in
                return item.lowercased().contains(textField.text?.lowercased() ?? "")
            }) ?? []
            fadeInOut(true)
        }
    }
    
    public func onTextDidEndEditing(_ sender: UITextFieldCustom) {
        dropDownInfo?.hide()
        if textField.text?.isEmpty == true {
            self.delegate?.dropDownCanceled(self)
        }else {
            if let selectedIndex = self.dropDownInfo?.dataSource.firstIndex(of: self.textField.text ?? "") {
                self.selected(selectedIndex, self.dropDownInfo?.dataSource[selectedIndex] ?? "")
            }else {
                self.delegate?.dropDownCanceled(self)
            }
        }
    }
}

extension DropDownModel: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    @available(iOS 9.0, *)
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

public protocol DropDownDelegate {
    func dropDownAction(_ dropDown: DropDownModel, _ index: Int, _ value: String)
    func dropDownCanceled(_ dropDown: DropDownModel)
}

@objc public protocol DropDownDataSource {
    func numberOfRows(_ dropDown: DropDownModel) -> Int
    func dropDown(_ dropDown: DropDownModel, itemByRow: Int) -> String
    @objc optional func dropDownTitle(_ dropDown: DropDownModel) -> String?
}
