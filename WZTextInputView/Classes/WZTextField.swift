//
//  WZTextField.swift
//  Created on 2022/1/11
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2022 WZLY. All rights reserved.
//  @author 邱啟祥(739140860@qq.com)   
//

import UIKit


/// MARK - WZTextFieldDelegate
@objc public protocol WZTextFieldDelegate: UITextFieldDelegate {
    
    /**
     *  配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。
     *  @warning 在 UIControlEventEditingChanged 里也会触发文字长度拦截，由于此时 textField 的文字已经改变完，所以无法得知发生改变的文本位置及改变的文本内容，所以此时 range 和 replacementString 这两个参数的值也会比较特殊，具体请看参数讲解。
     *
     *  @param textField 触发的 textField
     *  @param range 要变化的文字的位置，如果在 UIControlEventEditingChanged 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
     *  @param replacementString 要变化的文字，如果在 UIControlEventEditingChanged 里，这里永远传入 nil。
     */
    @objc optional func textField(_ textField: WZTextField,
                                  didPreventTextChangeInRange range: NSRange,
                                  replacementString: String?) -> Void
}


/// MARK - WZTextField
@objcMembers
open class WZTextField: UITextField {
    
    /// 修改 placeholder 的颜色，默认是 UIColorPlaceholder
    public var placeholderColor: UIColor = UIColor(red: 196.0/255.0, green: 200.0/255.0, blue: 208.0/255.0, alpha: 1.0) {
        didSet {
            updateAttributedPlaceholderIfNeeded()
        }
    }
    
    public var placeholderFont: UIFont? {
        didSet {
            updateAttributedPlaceholderIfNeeded()
        }
    }
    
    /// 显示允许输入的最大文字长度，默认为 UInt.max，也即不限制长度
    public var maximumTextLength: UInt = UInt.max
    
    /// 当通过 `setText:`、`setAttributedText:`等方式修改文字时，是否应该自动触发 UIControlEventEditingChanged 事件及 UITextFieldTextDidChangeNotification 通知 默认为YES（注意系统的 UITextField 对这种行为默认是 NO）
    public var shouldResponseToProgrammaticallyTextChanges: Bool = true
    
    /// 格式类型
    public var formatterType = WZTextInputFormatterType.default
    
    /// 文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
    @objc public dynamic var textInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 7)
    
    /// clearButton 在默认位置上的偏移
    @objc public dynamic var clearButtonPositionAdjustment: UIOffset = UIOffset.zero
    
    /// rightView 在默认位置上的便宜
    @objc public dynamic var rightViewPositionAdjustment: UIOffset = UIOffset.zero
    
    /// 占位符
    open override var placeholder: String? {
        didSet {
            updateAttributedPlaceholderIfNeeded()
        }
    }
    
    /// 文本重写
    open override var text: String? {
        didSet {
            
            guard oldValue != self.text,
                shouldResponseToProgrammaticallyTextChanges else {
                    return
            }
            
            fireTextDidChangeEventForTextField()
        }
    }
    
    /// 富文本
    open override var attributedText: NSAttributedString? {
        didSet {
            
            guard oldValue != self.attributedText,
                shouldResponseToProgrammaticallyTextChanges else {
                    return
            }
            
            fireTextDidChangeEventForTextField()
        }
    }
    
    /// 原始delegate
    private weak var originalDelegate: WZTextFieldDelegate?
    
    /// 当前文本
    private var currentString: String?
    
    convenience init() {
        self.init(frame: CGRect.zero)
        textAlignment = UIView.appearance().semanticContentAttribute == .forceRightToLeft ? .right:.left
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        addTarget(self, action: #selector(handleTextChangeEvent(_:)), for: .editingChanged)
    }
    
    /// 重写delegate
    override open var delegate: UITextFieldDelegate? {
        didSet {
            originalDelegate = delegate as? WZTextFieldDelegate
        }
    }
    
    /// 重写 textRect
    /// - Parameter bounds: bounds
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        var rect = bounds
        rect.origin.x += textInsets.left
        rect.origin.y += textInsets.top
        rect.size.width -= (textInsets.left + textInsets.right)
        rect.size.height -= (textInsets.top + textInsets.bottom)
        return super.textRect(forBounds: rect)
    }
    
    
    /// 重写 editingRect
    /// - Parameter bounds: bounds
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        var rect = bounds
        rect.origin.x += textInsets.left
        rect.origin.y += textInsets.top
        rect.size.width -= (textInsets.left + textInsets.right)
        rect.size.height -= (textInsets.top + textInsets.bottom)
        return super.editingRect(forBounds: rect)
    }
    
    
    /// 重写 clearButtonRect
    /// - Parameter bounds: bounds
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        
        var result = super.clearButtonRect(forBounds: bounds)
        result = result.offsetBy(dx: clearButtonPositionAdjustment.horizontal, dy: clearButtonPositionAdjustment.vertical)
        return result
    }
    
    
    /// 重写rightViewRect
    /// - Parameter bounds: bounds
    /// - Returns: CGRect
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        
        var result = super.rightViewRect(forBounds: bounds)
        result = result.offsetBy(dx: rightViewPositionAdjustment.horizontal, dy: rightViewPositionAdjustment.vertical)
        return result
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug
        if #available(iOS 10.0, *) {
            
            guard let scrollView = self.subviews.first as? UIScrollView,
                let _ = scrollView.delegate else {
                    return
            }
            
            scrollView.delegate = self
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// MARK - UITextFieldDelegate
extension WZTextField: UITextFieldDelegate {
    
    /// UITextFieldDelegate
    /// - Parameters:
    ///   - textField: UITextField
    ///   - range: NSRange
    ///   - string: String
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        guard let temTextField = textField as? WZTextField,
            temTextField.maximumTextLength < UInt.max  else {
                return true
        }
        
        // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
        if (textField.markedTextRange != nil) {
            return true
        }
        
        if NSMaxRange(range) > textField.text?.count ?? 0 {
            // 如果 range 越界了，继续返回 YES 会造成 crash
            // 这里的做法是本次返回 NO，并将越界的 range 缩减到没有越界的范围，再手动做该范围的替换。
            let temRange = NSMakeRange(range.location, range.length - (NSMaxRange(range) - (textField.text?.count ?? 0)))
            if temRange.length > 0 {
                if let textRang = textField.convertUITextRangeFromNSRange(temRange) {
                    textField.replace(textRang, withText: string)
                }
            }
            return false
        }
        
        
        let isDeleting = range.length > 0 && string.count <= 0
        if isDeleting {
            // 允许删除，这段必须放在上面的逻辑后面
            return originalDelegate?.textField?(temTextField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        }

        
        let rangeLength = range.length
        if (textField.text?.count ?? 0) - rangeLength + string.count > temTextField.maximumTextLength {
            
            // 将要插入的文字裁剪成这么长，就可以让它插入了
            let substringLength = Int(temTextField.maximumTextLength) - (textField.text?.count ?? 0) + rangeLength
            if substringLength > 0 && (textField.text?.count ?? 0) > substringLength {
                
                let characterSequencesRange = (string as NSString).rangeOfComposedCharacterSequences(for: NSMakeRange(0, substringLength))
                let allowedText = (string as NSString).substring(with: characterSequencesRange)
                if allowedText.count <= substringLength {
                    textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: allowedText)
                    // 通过代码 setText: 修改的文字，默认光标位置会在插入的文字开头，通常这不符合预期，因此这里将光标定位到插入的那段字符串的末尾
                    // 注意由于粘贴后系统也会在下一个 runloop 去修改光标位置，所以我们这里也要 dispatch 到下一个 runloop 才能生效，否则会被系统的覆盖
                    DispatchQueue.main.async {
                        if let temRang = textField.convertUITextRangeFromNSRange(NSMakeRange(range.location + allowedText.count, 0)) {
                            textField.selectedTextRange = temRang
                        }
                    }
                    textField.sendActions(for: UIControl.Event.editingChanged)
                    NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
                }
            }
            originalDelegate?.textField?(temTextField, didPreventTextChangeInRange: range, replacementString: string)
            return false
        }
        
        return true
    }
}

/// MARK - UIScrollViewDelegate
extension WZTextField: UIScrollViewDelegate {
    
    /// UIScrollViewDelegate
    /// - Parameter scrollView: scrollView
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug
        guard let subView = subviews.first as? UIScrollView else {
            return
        }
        
        if scrollView != subView {
            return
        }
        
        let paragraphStyle = defaultTextAttributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle
        let font = defaultTextAttributes[NSAttributedString.Key.font] as? UIFont
        let lineHeight = (paragraphStyle?.minimumLineHeight ?? 0) > 0 ? paragraphStyle?.minimumLineHeight : font?.lineHeight
        if scrollView.contentSize.height > ceil(lineHeight ?? 0) && scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
    }
}

/// MARK - private func
extension WZTextField {
    
    /// 更新占位符属性
    private func updateAttributedPlaceholderIfNeeded() {
        
        guard let temPlaceholder = placeholder else {
            return
        }
        
        var att: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor : placeholderColor]
        if let font = placeholderFont {
            att[NSAttributedString.Key.font] = font
        }
        
        attributedPlaceholder = NSAttributedString(string: temPlaceholder,
                                                   attributes: att)
    }
    
    
    /// 文本改变通知
    private func fireTextDidChangeEventForTextField() {
        sendActions(for: UIControl.Event.editingChanged)
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
    }
    
    /// 处理文本更改事件
    /// - Parameter textField: <#textField description#>
    @objc
    public func handleTextChangeEvent(_ textField: WZTextField) {
        // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textField:shouldChangeCharactersInRange:replacementString: 的，所以要在这里截断文字
        // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
        guard textField.markedTextRange == nil else {
            return
        }
        
        if (textField.text! as NSString).length > textField.maximumTextLength {
            textField.text = (textField.text! as NSString).substring(to: Int(textField.maximumTextLength))
        
            
            if let selectedTextRange = self.selectedTextRange {
                
                let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
                let length = offset(from: beginningOfDocument, to: selectedTextRange.start)
                
                originalDelegate?.textField?(textField, didPreventTextChangeInRange: NSMakeRange(location, length), replacementString: nil)
            }
        }
        
        guard let regexString = textField.formatterType.regexString,
            let text = textField.text  else {
                return
        }
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regexString)
        if !(predicate.evaluate(with: text) || text.count <= 0) {
            
            /// 因为底层会对Text 进行通知以及更新。所有会触发两次
            let shouldResponseToProgrammaticallyTextChanges = textField.shouldResponseToProgrammaticallyTextChanges
            textField.shouldResponseToProgrammaticallyTextChanges = false
            textField.text = currentString
            textField.shouldResponseToProgrammaticallyTextChanges = shouldResponseToProgrammaticallyTextChanges
        } else {
            currentString = textField.text
        }
    }
}


private extension UITextField {
    
    func convertUITextRangeFromNSRange(_ range: NSRange) -> UITextRange? {
        
        if range.location == NSNotFound || NSMaxRange(range) > self.text?.count ?? 0 {
            return nil
        }
        
        let beginning = beginningOfDocument
        
        guard let startPosition = position(from: beginning, offset: range.location),
                let endPosition = position(from: beginning, offset: NSMaxRange(range)) else {
            return nil
        }
        return textRange(from: startPosition, to: endPosition)
    }
}
