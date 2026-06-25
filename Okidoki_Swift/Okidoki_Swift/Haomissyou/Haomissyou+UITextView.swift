//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-24
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit
import ObjectiveC

// MARK: - Delegate Handler

private final class _HaomissyouTextViewDelegate: NSObject, UITextViewDelegate {

    var shouldBeginEditingBlock:    ((UITextView) -> Bool)?
    var didBeginEditingBlock:       ((UITextView) -> Void)?
    var shouldEndEditingBlock:      ((UITextView) -> Bool)?
    var didEndEditingBlock:         ((UITextView) -> Void)?
    var didChangeBlock:             ((UITextView) -> Void)?
    var didChangeSelectionBlock:    ((UITextView) -> Void)?
    var shouldChangeTextBlock:      ((UITextView, NSRange, String) -> Bool)?
    // iOS 26+ ranges block (stored as Any to avoid availability requirement on the property)
    var shouldChangeTextInRangesBlock: Any?

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        shouldBeginEditingBlock?(textView) ?? true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditingBlock?(textView)
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        shouldEndEditingBlock?(textView) ?? true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        didEndEditingBlock?(textView)
    }
    func textViewDidChange(_ textView: UITextView) {
        didChangeBlock?(textView)
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        didChangeSelectionBlock?(textView)
    }
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if #available(iOS 26.0, *) {
            // iOS 26+ 优先使用 ranges block（若设置），否则降级到旧 block
            if let rangesBlock = shouldChangeTextInRangesBlock
                as? (UITextView, [NSValue], String) -> Bool {
                return rangesBlock(textView, [NSValue(range: range)], text)
            }
        }
        return shouldChangeTextBlock?(textView, range, text) ?? true
    }

    @available(iOS 26.0, *)
    func textView(_ textView: UITextView,
                  shouldChangeTextInRanges ranges: [NSValue],
                  replacementText text: String) -> Bool {
        if let rangesBlock = shouldChangeTextInRangesBlock
            as? (UITextView, [NSValue], String) -> Bool {
            return rangesBlock(textView, ranges, text)
        }
        // 降级：取第一个 range 调用旧 block
        if let block = shouldChangeTextBlock, let first = ranges.first {
            return block(textView, first.rangeValue, text)
        }
        return true
    }
}

// MARK: - Keyboard Handler

private final class _HaomissyouTextViewKeyboardHandler: NSObject {

    weak var textView: UITextView?
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
            if textView?.isFirstResponder == true {
                activeResponder = textView
                block(name, beginFrame, endFrame, CGFloat(duration), curve)
            }
        } else if activeResponder != nil {
            block(name, beginFrame, endFrame, CGFloat(duration), curve)
            if name == UIResponder.keyboardDidHideNotification { activeResponder = nil }
        }
    }
}

// MARK: - Input Limit

/// 输入限制类型，与 ObjC OkidokiInputLimitType 对应。
public struct HaomissyouInputLimitType: OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }

    public static let digital:        HaomissyouInputLimitType = .init(rawValue: 1 << 0)
    public static let alphabet:       HaomissyouInputLimitType = .init(rawValue: 1 << 1)
    public static let alphabetUpper:  HaomissyouInputLimitType = .init(rawValue: 1 << 2)
    public static let alphabetLower:  HaomissyouInputLimitType = .init(rawValue: 1 << 3)
    public static let chinese:        HaomissyouInputLimitType = .init(rawValue: 1 << 4)
    public static let custom:         HaomissyouInputLimitType = .init(rawValue: 1 << 5)
}

private final class _HaomissyouInputLimitHandler: NSObject {

    weak var textView: UITextView?
    var limitType: HaomissyouInputLimitType = []
    var maxLength: Int = 0
    var customCharacters: String?
    var changeBlock: ((String, String) -> Void)?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)),
                                               name: UITextView.textDidChangeNotification, object: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func textDidChange(_ note: Notification) {
        guard let tv = textView, note.object as? UITextView === tv else { return }

        // 正在输入中文拼音时不处理
        if tv.textInputMode?.primaryLanguage == "zh-Hans",
           let marked = tv.markedTextRange,
           tv.position(from: marked.start, offset: 0) != nil {
            return
        }

        let original = tv.text ?? ""
        let matched = filterText(original)

        if original != matched {
            tv.text = matched
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
            let sub = String(text[range])
            let first = sub.unicodeScalars.first?.value ?? 0

            var append = false
            if (checkAlphabet || checkAlphabetUpper) && (first >= 0x41 && first <= 0x5A) { append = true }
            else if (checkAlphabet || checkAlphabetLower) && (first >= 0x61 && first <= 0x7A) { append = true }
            else if checkDigital && (first >= 0x30 && first <= 0x39) { append = true }
            else if checkChinese && isChinese(sub) { append = true }
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

    private func isChinese(_ s: String) -> Bool {
        guard let v = s.unicodeScalars.first?.value else { return false }
        if (v >= 0x4E00 && v <= 0x9FFF) || (v >= 0x3400 && v <= 0x4DBF) || (v >= 0xF900 && v <= 0xFAFF) { return true }
        // 代理对扩展区（utf32）
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
}

// MARK: - Associated Object Keys

private var _tvDelegateKey:     UInt8 = 0
private var _tvKeyboardKey:     UInt8 = 0
private var _tvInputLimitKey:   UInt8 = 0

// MARK: - Private helpers

private func _tvDelegate(for tv: UITextView) -> _HaomissyouTextViewDelegate {
    if let h = objc_getAssociatedObject(tv, &_tvDelegateKey) as? _HaomissyouTextViewDelegate { return h }
    let h = _HaomissyouTextViewDelegate()
    objc_setAssociatedObject(tv, &_tvDelegateKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    tv.delegate = h
    return h
}

private func _tvKeyboardHandler(for tv: UITextView) -> _HaomissyouTextViewKeyboardHandler {
    if let h = objc_getAssociatedObject(tv, &_tvKeyboardKey) as? _HaomissyouTextViewKeyboardHandler { return h }
    let h = _HaomissyouTextViewKeyboardHandler()
    h.textView = tv
    objc_setAssociatedObject(tv, &_tvKeyboardKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return h
}

private func _tvInputLimitHandler(for tv: UITextView) -> _HaomissyouInputLimitHandler {
    if let h = objc_getAssociatedObject(tv, &_tvInputLimitKey) as? _HaomissyouInputLimitHandler { return h }
    let h = _HaomissyouInputLimitHandler()
    h.textView = tv
    objc_setAssociatedObject(tv, &_tvInputLimitKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return h
}

// MARK: - UITextView Properties

public extension Haomissyou {

    /// isEditable — Bool / NSNumber / String
    @discardableResult
    func editable(_ value: Any) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        tv.isEditable = _tvBool(value)
        return self
    }

    /// isSelectable — Bool / NSNumber / String
    @discardableResult
    func selectable(_ value: Any) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        tv.isSelectable = _tvBool(value)
        return self
    }

    /// attributedText — NSAttributedString
    @discardableResult
    func attributedText(_ value: Any) -> Haomissyou {
        guard let tv = view as? UITextView,
              let attr = value as? NSAttributedString else { return self }
        tv.attributedText = attr
        return self
    }

    /// inputView — UIView
    @discardableResult
    func inputView(_ value: Any) -> Haomissyou {
        guard let tv = view as? UITextView,
              let v = value as? UIView else { return self }
        tv.inputView = v
        return self
    }

    /// inputAccessoryView — UIView
    @discardableResult
    func inputAccessoryView(_ value: Any) -> Haomissyou {
        guard let tv = view as? UITextView,
              let v = value as? UIView else { return self }
        tv.inputAccessoryView = v
        return self
    }

    /// textContainerInset — NSValue(UIEdgeInsets) / String("{t,l,b,r}")
    @discardableResult
    func textContainerInset(_ value: Any) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        if let val = value as? NSValue {
            tv.textContainerInset = val.uiEdgeInsetsValue
        } else if let s = value as? String {
            tv.textContainerInset = NSCoder.uiEdgeInsets(for: s)
        }
        return self
    }
}

// MARK: - UITextView Delegate Blocks

public extension Haomissyou {

    /// textViewShouldBeginEditing:
    @discardableResult
    func tvShouldBeginEditing(_ block: @escaping (UITextView) -> Bool) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).shouldBeginEditingBlock = block
        return self
    }

    /// textViewDidBeginEditing:
    @discardableResult
    func tvDidBeginEditing(_ block: @escaping (UITextView) -> Void) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).didBeginEditingBlock = block
        return self
    }

    /// textViewShouldEndEditing:
    @discardableResult
    func tvShouldEndEditing(_ block: @escaping (UITextView) -> Bool) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).shouldEndEditingBlock = block
        return self
    }

    /// textViewDidEndEditing:
    @discardableResult
    func tvDidEndEditing(_ block: @escaping (UITextView) -> Void) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).didEndEditingBlock = block
        return self
    }

    /// textViewDidChange:
    @discardableResult
    func tvDidChange(_ block: @escaping (UITextView) -> Void) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).didChangeBlock = block
        return self
    }

    /// textViewDidChangeSelection:
    @discardableResult
    func tvDidChangeSelection(_ block: @escaping (UITextView) -> Void) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).didChangeSelectionBlock = block
        return self
    }

    /// textView:shouldChangeTextInRange:replacementText:
    @discardableResult
    func tvShouldChangeText(_ block: @escaping (UITextView, NSRange, String) -> Bool) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).shouldChangeTextBlock = block
        return self
    }

    /// textView:shouldChangeTextInRanges:replacementText: (iOS 26+)
    /// 在旧系统自动降级为 `tvShouldChangeText`（取第一个 range）。
    @available(iOS 26.0, *)
    @discardableResult
    func tvShouldChangeTextInRanges(_ block: @escaping (UITextView, [NSValue], String) -> Bool) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        _tvDelegate(for: tv).shouldChangeTextInRangesBlock = block
        return self
    }
}

// MARK: - Keyboard Handler

public extension Haomissyou {

    /// 键盘通知回调，同时支持 UITextField 和 UITextView。
    ///
    /// - Parameter block: 键盘状态变化时触发，参数依次为：
    ///   - `name`: 通知名称（WillShow / DidShow / WillHide / DidHide）
    ///   - `beginFrame`: 键盘动画起始 frame
    ///   - `endFrame`: 键盘动画结束 frame（键盘最终位置）
    ///   - `duration`: 动画时长（秒）
    ///   - `curve`: 动画曲线
    ///
    /// 示例：
    /// ```swift
    /// // 1. 键盘弹起时上移底部输入框
    /// textField.haomissyou
    ///     .keyboardHandler { [weak self] name, _, endFrame, duration, curve in
    ///         guard let self else { return }
    ///         let isShow = (name == UIResponder.keyboardWillShowNotification)
    ///         let offset = isShow ? -endFrame.height : 0
    ///         UIView.animate(withDuration: duration) {
    ///             self.inputBar.transform = CGAffineTransform(translationX: 0, y: offset)
    ///         }
    ///     }
    ///
    /// // 2. 调整 scrollView contentInset 避免键盘遮挡
    /// textView.haomissyou
    ///     .keyboardHandler { [weak self] name, _, endFrame, duration, _ in
    ///         guard let self else { return }
    ///         let isShow = (name == UIResponder.keyboardWillShowNotification ||
    ///                       name == UIResponder.keyboardDidShowNotification)
    ///         let bottom = isShow ? endFrame.height : 0
    ///         UIView.animate(withDuration: duration) {
    ///             self.scrollView.contentInset.bottom = bottom
    ///             self.scrollView.verticalScrollIndicatorInsets.bottom = bottom
    ///         }
    ///     }
    /// ```
    @discardableResult
    func keyboardHandler(_ block: @escaping (NSNotification.Name, CGRect, CGRect, CGFloat, UIView.AnimationCurve) -> Void) -> Haomissyou {
        if let tv = view as? UITextView {
            _tvKeyboardHandler(for: tv).changeBlock = block
        } else if let tf = view as? UITextField {
            _tfKbHandler(for: tf).changeBlock = block
        }
        return self
    }
}

// MARK: - Input Limit

public extension Haomissyou {

    /// 输入限制（UITextView）。
    /// - type: 允许的字符类型（可用 `|` 组合），如 `.digital`、`.chinese`
    /// - length: 最大字符数，0 表示不限制
    /// - customCharacters: 自定义字符集（仅 type 含 `.custom` 时生效）
    /// - changeBlock: 文字变化回调 (originalText, matchedText)
    @discardableResult
    func tvInputLimit(
        _ type: HaomissyouInputLimitType,
        _ length: Int,
        _ customCharacters: String? = nil,
        _ changeBlock: ((String, String) -> Void)? = nil
    ) -> Haomissyou {
        guard let tv = view as? UITextView else { return self }
        let handler = _tvInputLimitHandler(for: tv)
        handler.limitType         = type
        handler.maxLength         = length
        handler.customCharacters  = customCharacters
        handler.changeBlock       = changeBlock
        return self
    }
}

// MARK: - Private Bool helper (scoped to this file)

private func _tvBool(_ value: Any) -> Bool {
    switch value {
    case let b as Bool:     return b
    case let n as NSNumber: return n.boolValue
    case let s as String:   return (s as NSString).boolValue
    default: return false
    }
}
