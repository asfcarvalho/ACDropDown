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
        
        //MARK: Icon
        icon.removeFromSuperview()
        self.addSubview(icon)
        icon.anchor(top: nil, leading: nil, bottom: nil, trailing: self.trailingAnchor, centerX: nil, centerY: self.centerYAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16), size: CGSize(width: 20, height: 20))
        
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
            }else if let selectedIndex = self.dropDownInfo?.dataSource.firstIndex(of: self.textField.text ?? "") {
                self.selected(selectedIndex, self.dropDownInfo?.dataSource[selectedIndex] ?? "")
            }else {
                self.delegate?.dropDownCanceled(self)
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
                    self.textField.placeholder = title
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
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupGestureRecognizer(onClick: AnyObject) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(setupDropDownActions))
        onClick.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    @objc fileprivate func setupDropDownActions(_ sender: AnyObject?) {
        dropDownInfo?.show()
        
    }
}

extension DropDownModel: UITextFieldCustomProtocol {
    public func setErrorDropDown(_ isError: Bool) {
        if isError {
            self.layer.borderColor = UIColor.red.cgColor
        }else {
            self.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    public func onTextDidChange(_ sender: UITextFieldCustom) {
        dropDownInfo?.show()
        if textField.text?.isEmpty == true {
            dropDownInfo?.dataSource = dropDownList ?? []
        }else {
            dropDownInfo?.dataSource = dropDownList?.filter({ (item) -> Bool in
                return item.lowercased().contains(textField.text?.lowercased() ?? "")
            }) ?? []
            
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
