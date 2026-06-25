//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-24
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - Private helper

/// 取出 UITextField 已有的 attributedPlaceholder；
/// 若为空但有 plain placeholder，则用 plain 字符串构造一个新的。
private func _tfAttrPlaceholder(_ tf: UITextField) -> NSMutableAttributedString {
    if let attr = tf.attributedPlaceholder, !attr.string.isEmpty {
        return NSMutableAttributedString(attributedString: attr)
    }
    return NSMutableAttributedString(string: tf.placeholder ?? "")
}

private func _textFieldViewMode(from value: Any) -> UITextField.ViewMode? {
    switch value {
    case let n as NSNumber: return UITextField.ViewMode(rawValue: n.intValue)
    case let s as String:   return UITextField.ViewMode(rawValue: Int(s) ?? 0)
    default: return nil
    }
}

// MARK: - UITextField

public extension Haomissyou {

    // MARK: bdStyle

    /// borderStyle — NSNumber / String (0–3)
    @discardableResult
    func bdStyle(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        switch value {
        case let n as NSNumber:
            if let style = UITextField.BorderStyle(rawValue: n.intValue) { tf.borderStyle = style }
        case let s as String:
            if let raw = Int(s), let style = UITextField.BorderStyle(rawValue: raw) { tf.borderStyle = style }
        default: break
        }
        return self
    }

    // MARK: pHolder

    /// placeholder — String
    @discardableResult
    func pHolder(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField,
              let s = value as? String else { return self }
        tf.placeholder = s
        return self
    }

    // MARK: pHColor

    /// placeholder 文字颜色 — UIColor / hex String
    @discardableResult
    func pHColor(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField,
              let c = UIColor.haomissyouColor(value) else { return self }
        let attr = _tfAttrPlaceholder(tf)
        guard !attr.string.isEmpty else { return self }
        attr.addAttribute(.foregroundColor, value: c,
                          range: NSRange(location: 0, length: attr.string.utf16.count))
        tf.attributedPlaceholder = attr
        return self
    }

    // MARK: pHFont

    /// placeholder 字体 — UIFont / String("17","s17","b17","i17")
    @discardableResult
    func pHFont(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        let f: UIFont
        switch value {
        case let font as UIFont: f = font
        case let s as String:
            // 复用 Label 文件里的逻辑：直接调系统 API
            if let size = Double(s), size > 0 {
                f = .systemFont(ofSize: CGFloat(size))
            } else if s.count > 1 {
                let rest = String(s.dropFirst())
                if let size = Double(rest), size > 0 {
                    switch s.first {
                    case "b": f = .boldSystemFont(ofSize: CGFloat(size))
                    case "i": f = .italicSystemFont(ofSize: CGFloat(size))
                    default:  f = .systemFont(ofSize: CGFloat(size))
                    }
                } else { f = .systemFont(ofSize: UIFont.systemFontSize) }
            } else { f = .systemFont(ofSize: UIFont.systemFontSize) }
        default: return self
        }
        let attr = _tfAttrPlaceholder(tf)
        guard !attr.string.isEmpty else { return self }
        attr.addAttribute(.font, value: f,
                          range: NSRange(location: 0, length: attr.string.utf16.count))
        tf.attributedPlaceholder = attr
        return self
    }

    // MARK: cbMode

    /// clearButtonMode — NSNumber / String (0–3)
    @discardableResult
    func cbMode(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField,
              let mode = _textFieldViewMode(from: value) else { return self }
        tf.clearButtonMode = mode
        return self
    }

    // MARK: lvMode

    /// leftViewMode — NSNumber / String (0–3)
    @discardableResult
    func lvMode(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField,
              let mode = _textFieldViewMode(from: value) else { return self }
        tf.leftViewMode = mode
        return self
    }

    // MARK: rvMode

    /// rightViewMode — NSNumber / String (0–3)
    @discardableResult
    func rvMode(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField,
              let mode = _textFieldViewMode(from: value) else { return self }
        tf.rightViewMode = mode
        return self
    }

    // MARK: lfView

    /// leftView — UIView
    @discardableResult
    func lfView(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField,
              let v = value as? UIView else { return self }
        tf.leftView = v
        return self
    }

    // MARK: rtView

    /// rightView — UIView
    @discardableResult
    func rtView(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField,
              let v = value as? UIView else { return self }
        tf.rightView = v
        return self
    }

    // MARK: secure

    /// secureTextEntry — Bool / NSNumber / String
    @discardableResult
    func secure(_ value: Any) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        switch value {
        case let b as Bool:      tf.isSecureTextEntry = b
        case let n as NSNumber:  tf.isSecureTextEntry = n.boolValue
        case let s as String:    tf.isSecureTextEntry = (s as NSString).boolValue
        default: break
        }
        return self
    }
}


// MARK: - Delegate Handler

private final class _HaomissyouTextFieldDelegate: NSObject, UITextFieldDelegate {

    var shouldBeginEditingBlock:    ((UITextField) -> Bool)?
    var didBeginEditingBlock:       ((UITextField) -> Void)?
    var shouldEndEditingBlock:      ((UITextField) -> Bool)?
    var didEndEditingBlock:         ((UITextField) -> Void)?
    var shouldChangeCharactersBlock:((UITextField, NSRange, String) -> Bool)?
    var shouldClearBlock:           ((UITextField) -> Bool)?
    var shouldReturnBlock:          ((UITextField) -> Bool)?

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        shouldBeginEditingBlock?(textField) ?? true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditingBlock?(textField)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        shouldEndEditingBlock?(textField) ?? true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditingBlock?(textField)
    }
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        shouldChangeCharactersBlock?(textField, range, string) ?? true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        shouldClearBlock?(textField) ?? true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        shouldReturnBlock?(textField) ?? true
    }
}

// MARK: - Keyboard Handler (internal — shared with Haomissyou+UITextView.swift)

final class _HaomissyouTextFieldKeyboardHandler: NSObject {

    weak var textField: UITextField?
    var changeBlock: ((NSNotification.Name, CGRect, CGRect, CGFloat, UIView.AnimationCurve) -> Void)?
    private weak var activeResponder: UIResponder?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(_:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNoti(_:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func keyboardNoti(_ note: Notification) {
        guard let block = changeBlock else { return }
        let info = note.userInfo ?? [:]
        let beginFrame = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let endFrame   = (info[UIResponder.keyboardFrameEndUserInfoKey]   as? NSValue)?.cgRectValue ?? .zero
        let duration   = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let curveRaw   = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0
        let curve      = UIView.AnimationCurve(rawValue: curveRaw) ?? .easeInOut
        let name       = note.name

        let isShow = (name == UIResponder.keyboardWillShowNotification ||
                      name == UIResponder.keyboardDidShowNotification)
        if isShow {
            if textField?.isFirstResponder == true {
                activeResponder = textField
                block(name, beginFrame, endFrame, CGFloat(duration), curve)
            }
        } else if activeResponder != nil {
            block(name, beginFrame, endFrame, CGFloat(duration), curve)
            if name == UIResponder.keyboardDidHideNotification { activeResponder = nil }
        }
    }
}

// MARK: - Input Limit Handler

private final class _HaomissyouTextFieldInputLimitHandler: NSObject {

    weak var textField: UITextField?
    var limitType: HaomissyouInputLimitType = []
    var maxLength: Int = 0
    var customCharacters: String?
    var changeBlock: ((String, String) -> Void)?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)),
                                               name: UITextField.textDidChangeNotification, object: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func textDidChange(_ note: Notification) {
        guard let tf = textField, note.object as? UITextField === tf else { return }

        // 正在输入中文拼音时不处理
        if tf.textInputMode?.primaryLanguage == "zh-Hans",
           let marked = tf.markedTextRange,
           tf.position(from: marked.start, offset: 0) != nil {
            return
        }

        let original = tf.text ?? ""
        let matched  = filterText(original)

        if original != matched {
            tf.text = matched
            changeBlock?(original, matched)
        } else {
            changeBlock?(original, matched)
        }
    }

    private func filterText(_ text: String) -> String {
        guard !limitType.isEmpty else { return text }

        let checkDigital       = limitType.contains(.digital)
        let checkAlphabet      = limitType.contains(.alphabet)
        let checkAlphabetUpper = limitType.contains(.alphabetUpper)
        let checkAlphabetLower = limitType.contains(.alphabetLower)
        let checkChinese       = limitType.contains(.chinese)
        let checkCustom        = limitType.contains(.custom) && (customCharacters?.isEmpty == false)

        var result = ""
        var idx = text.startIndex
        while idx < text.endIndex {
            let range = text.rangeOfComposedCharacterSequence(at: idx)
            let sub   = String(text[range])
            let first = sub.unicodeScalars.first?.value ?? 0

            var append = false
            if (checkAlphabet || checkAlphabetUpper) && (first >= 0x41 && first <= 0x5A) { append = true }
            else if (checkAlphabet || checkAlphabetLower) && (first >= 0x61 && first <= 0x7A) { append = true }
            else if checkDigital && (first >= 0x30 && first <= 0x39) { append = true }
            else if checkChinese && _isChinese(sub) { append = true }
            else if checkCustom, let cc = customCharacters, cc.contains(sub) { append = true }

            if append {
                if maxLength > 0 && result.count >= maxLength { break }
                result.append(sub)
            }
            idx = range.upperBound
        }

        if maxLength > 0 && result.count > maxLength {
            let endIdx = result.index(result.startIndex, offsetBy: maxLength)
            return String(result[..<endIdx])
        }
        return result
    }
}

private func _isChinese(_ s: String) -> Bool {
    guard let v = s.unicodeScalars.first?.value else { return false }
    if (v >= 0x4E00 && v <= 0x9FFF) || (v >= 0x3400 && v <= 0x4DBF) || (v >= 0xF900 && v <= 0xFAFF) { return true }
    if s.utf16.count >= 2 {
        var utf32: UInt32 = 0
        s.withCString(encodedAs: UTF32.self) { utf32 = $0.pointee.littleEndian }
        return (utf32 >= 0x20000 && utf32 <= 0x2A6DF) ||
               (utf32 >= 0x2A700 && utf32 <= 0x2B73F) ||
               (utf32 >= 0x2B740 && utf32 <= 0x2B81F) ||
               (utf32 >= 0x2B820 && utf32 <= 0x2CEAF)
    }
    return false
}

// MARK: - Associated Object Keys

private var _tfDelegateKey:   UInt8 = 0
var         _tfKbHandlerKey:  UInt8 = 0   // internal — accessed from Haomissyou+UITextView.swift
private var _tfInputLimitKey: UInt8 = 0

// MARK: - Private Helpers

private func _tfDelegate(for tf: UITextField) -> _HaomissyouTextFieldDelegate {
    if let h = objc_getAssociatedObject(tf, &_tfDelegateKey) as? _HaomissyouTextFieldDelegate { return h }
    let h = _HaomissyouTextFieldDelegate()
    objc_setAssociatedObject(tf, &_tfDelegateKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    tf.delegate = h
    return h
}

func _tfKbHandler(for tf: UITextField) -> _HaomissyouTextFieldKeyboardHandler {
    if let h = objc_getAssociatedObject(tf, &_tfKbHandlerKey) as? _HaomissyouTextFieldKeyboardHandler { return h }
    let h = _HaomissyouTextFieldKeyboardHandler()
    h.textField = tf
    objc_setAssociatedObject(tf, &_tfKbHandlerKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return h
}

private func _tfInputLimitHandler(for tf: UITextField) -> _HaomissyouTextFieldInputLimitHandler {
    if let h = objc_getAssociatedObject(tf, &_tfInputLimitKey) as? _HaomissyouTextFieldInputLimitHandler { return h }
    let h = _HaomissyouTextFieldInputLimitHandler()
    h.textField = tf
    objc_setAssociatedObject(tf, &_tfInputLimitKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return h
}

// MARK: - UITextField Delegate Blocks

public extension Haomissyou {

    /// textFieldShouldBeginEditing:
    @discardableResult
    func tfShouldBeginEditing(_ block: @escaping (UITextField) -> Bool) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        _tfDelegate(for: tf).shouldBeginEditingBlock = block
        return self
    }

    /// textFieldDidBeginEditing:
    @discardableResult
    func tfDidBeginEditing(_ block: @escaping (UITextField) -> Void) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        _tfDelegate(for: tf).didBeginEditingBlock = block
        return self
    }

    /// textFieldShouldEndEditing:
    @discardableResult
    func tfShouldEndEditing(_ block: @escaping (UITextField) -> Bool) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        _tfDelegate(for: tf).shouldEndEditingBlock = block
        return self
    }

    /// textFieldDidEndEditing:
    @discardableResult
    func tfDidEndEditing(_ block: @escaping (UITextField) -> Void) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        _tfDelegate(for: tf).didEndEditingBlock = block
        return self
    }

    /// textField:shouldChangeCharactersInRange:replacementString:
    @discardableResult
    func tfShouldChangeCharacters(_ block: @escaping (UITextField, NSRange, String) -> Bool) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        _tfDelegate(for: tf).shouldChangeCharactersBlock = block
        return self
    }

    /// textFieldShouldClear:
    @discardableResult
    func tfShouldClear(_ block: @escaping (UITextField) -> Bool) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        _tfDelegate(for: tf).shouldClearBlock = block
        return self
    }

    /// textFieldShouldReturn:
    @discardableResult
    func tfShouldReturn(_ block: @escaping (UITextField) -> Bool) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        _tfDelegate(for: tf).shouldReturnBlock = block
        return self
    }
}

// MARK: - Input Limit

public extension Haomissyou {

    /// 输入限制（UITextField）。
    ///
    /// - Parameters:
    ///   - type: 允许的字符类型，可组合多种类型
    ///   - length: 最大字符数，0 表示不限制
    ///   - customCharacters: 自定义字符集（仅 type 含 `.custom` 时生效）
    ///   - changeBlock: 文字变化回调，参数为 (原始文本, 过滤后文本)
    ///
    /// 示例：
    /// ```swift
    /// // 1. 只允许数字，最多 6 位
    /// textField.haomissyou
    ///     .tfInputLimit(.digital, 6)
    ///
    /// // 2. 允许数字 + 小写字母，最多 10 位，监听变化
    /// textField.haomissyou
    ///     .tfInputLimit([.digital, .alphabetLower], 10) { original, matched in
    ///         print("输入：\(original) → 过滤后：\(matched)")
    ///     }
    ///
    /// // 3. 允许中文 + 字母（大小写），不限长度
    /// textField.haomissyou
    ///     .tfInputLimit([.chinese, .alphabet], 0)
    ///
    /// // 4. 自定义字符集（只允许 +、-、. 和数字），最多 15 位
    /// textField.haomissyou
    ///     .tfInputLimit([.digital, .custom], 15, "+-.")
    ///
    /// // 5. 纯大写字母，最多 4 位（如验证码）
    /// textField.haomissyou
    ///     .tfInputLimit(.alphabetUpper, 4)
    /// ```
    @discardableResult
    func tfInputLimit(
        _ type: HaomissyouInputLimitType,
        _ length: Int,
        _ customCharacters: String? = nil,
        _ changeBlock: ((String, String) -> Void)? = nil
    ) -> Haomissyou {
        guard let tf = view as? UITextField else { return self }
        let handler = _tfInputLimitHandler(for: tf)
        handler.limitType        = type
        handler.maxLength        = length
        handler.customCharacters = customCharacters
        handler.changeBlock      = changeBlock
        return self
    }
}
