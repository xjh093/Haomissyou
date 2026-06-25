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

// MARK: - autoWidth / autoHeight persistent keys

/// 记录 autoWidth 的 maxW 限制；存在即表示已开启自动宽度。
private var _autoWidthMaxKey: UInt8 = 0

/// 用当前 attributedText / font 重新计算并写入 label 宽度。
/// 只有 autoWidth 被调用过（关联对象存在）时才生效。
private func _applyAutoWidth(_ lbl: UILabel) {
    guard let maxWNum = objc_getAssociatedObject(lbl, &_autoWidthMaxKey) as? NSNumber else { return }
    let maxW = CGFloat(maxWNum.doubleValue)
    lbl.numberOfLines = 1
    let font = lbl.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
    let text = lbl.text ?? ""
    var fitW = ceil((text as NSString).boundingRect(
        with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: [.font: font],
        context: nil).width)
    // HaomissyouLabel：加上 left + right textInsets
    if let paddingLbl = lbl as? HaomissyouLabel {
        fitW += paddingLbl.textInsets.left + paddingLbl.textInsets.right
    }
    var f = lbl.frame
    f.size.width = (maxW > 0 && fitW > maxW) ? maxW : fitW
    lbl.frame = f
}

/// 记录 autoHeight 的 maxH 限制；存在即表示已开启自动高度。
private var _autoHeightMaxKey: UInt8 = 0

/// 用当前 attributedText / font 重新计算并写入 label 高度。
/// 只有 autoHeight 被调用过（关联对象存在）时才生效。
private func _applyAutoHeight(_ lbl: UILabel) {
    guard let maxHNum = objc_getAssociatedObject(lbl, &_autoHeightMaxKey) as? NSNumber else { return }
    let maxH = CGFloat(maxHNum.doubleValue)
    lbl.numberOfLines = 0
    let savedWidth = lbl.frame.size.width > 0 ? lbl.frame.size.width : UIScreen.main.bounds.width
    var bigFrame = lbl.frame
    bigFrame.size.width  = savedWidth
    bigFrame.size.height = 9999
    lbl.frame = bigFrame
    lbl.sizeToFit()
    let fitH = lbl.frame.size.height
    var f = lbl.frame
    f.size.width  = savedWidth
    f.size.height = (maxH > 0 && fitH > maxH) ? maxH : fitH
    lbl.frame = f
}

/// 同时触发 autoWidth / autoHeight 重算（哪个没开启就跳过）。
private func _applyAutoLayout(_ lbl: UILabel) {
    _applyAutoWidth(lbl)
    _applyAutoHeight(lbl)
}

// MARK: - Private helpers for views with text/attributedText

private func _getText(_ view: UIView) -> String? {
    if let v = view as? UILabel      { return v.text }
    if let v = view as? UITextField  { return v.text }
    if let v = view as? UITextView   { return v.text }
    return nil
}

private func _getAttributedText(_ view: UIView) -> NSAttributedString? {
    if let v = view as? UILabel      { return v.attributedText }
    if let v = view as? UITextField  { return v.attributedText }
    if let v = view as? UITextView   { return v.attributedText }
    return nil
}

private func _setAttributedText(_ attr: NSAttributedString, on view: UIView) {
    if let v = view as? UILabel      { v.attributedText = attr }
    else if let v = view as? UITextField { v.attributedText = attr }
    else if let v = view as? UITextView  { v.attributedText = attr }
}

// MARK: - UILabel & UITextView & UITextField + UILabel

public extension Haomissyou {

    // MARK: text

    /// `view.text = value` — UILabel / UITextField / UITextView
    @discardableResult
    func text(_ value: Any) -> Haomissyou {
        guard let s = value as? String else { return self }
        if let v = view as? UILabel          { v.text = s }
        else if let v = view as? UITextField { v.text = s }
        else if let v = view as? UITextView  { v.text = s }
        return self
    }

    // MARK: font

    /// UIFont / String("17","s17","b17","i17") / NSNumber → setFont
    /// UIButton → titleLabel.font
    @discardableResult
    func font(_ value: Any) -> Haomissyou {
        let f = UIFont.haomissyouFont(value)
        if let btn = view as? UIButton {
            btn.titleLabel?.font = f
        } else if let lbl = view as? UILabel {
            lbl.font = f
        } else if let tf = view as? UITextField {
            tf.font = f
        } else if let tv = view as? UITextView {
            tv.font = f
        }
        return self
    }

    // MARK: color

    /// UIColor / hex String → textColor（或 UIButton normal title color）
    @discardableResult
    func color(_ value: Any) -> Haomissyou {
        guard let c = UIColor.haomissyouColor(value) else { return self }
        if let btn = view as? UIButton {
            btn.setTitleColor(c, for: .normal)
        } else if let lbl = view as? UILabel {
            lbl.textColor = c
        } else if let tf = view as? UITextField {
            tf.textColor = c
        } else if let tv = view as? UITextView {
            tv.textColor = c
        }
        return self
    }

    // MARK: align

    /// NSNumber / String → textAlignment（UIButton → titleLabel.textAlignment）
    @discardableResult
    func align(_ value: Any) -> Haomissyou {
        let raw: Int
        switch value {
        case let n as NSNumber: raw = n.intValue
        case let s as String:   raw = Int(s) ?? 0
        default: return self
        }
        guard let alignment = NSTextAlignment(rawValue: raw) else { return self }
        if let btn = view as? UIButton {
            btn.titleLabel?.textAlignment = alignment
        } else if let lbl = view as? UILabel {
            lbl.textAlignment = alignment
        } else if let tf = view as? UITextField {
            tf.textAlignment = alignment
        } else if let tv = view as? UITextView {
            tv.textAlignment = alignment
        }
        return self
    }

    // MARK: attributedSubstring

    /// 对 `substring` 首次出现的范围应用 `value`（UIColor → foregroundColor，UIFont → font）
    @discardableResult
    func attributedSubstring(_ substring: Any, _ value: Any) -> Haomissyou {
        guard let str = _getText(view),
              let sub = substring as? String,
              let nsRange = str.range(of: sub).map({ NSRange($0, in: str) })
        else { return self }

        let attr = NSMutableAttributedString(attributedString:
            _getAttributedText(view) ?? NSAttributedString(string: str))

        if let c = value as? UIColor {
            attr.addAttribute(.foregroundColor, value: c, range: nsRange)
        } else if let c = UIColor.haomissyouColor(value as? String) {
            attr.addAttribute(.foregroundColor, value: c, range: nsRange)
        } else if let f = value as? UIFont {
            attr.addAttribute(.font, value: f, range: nsRange)
        }
        _setAttributedText(attr, on: view)
        if let lbl = view as? UILabel { _applyAutoLayout(lbl) }
        return self
    }

    // MARK: attributedSubstringInRange

    /// 在指定 `range`（NSValue wrapping NSRange）对 `value` 应用属性
    @discardableResult
    func attributedSubstringInRange(_ substring: Any, _ value: Any, _ range: Any) -> Haomissyou {
        guard let str = _getText(view),
              let nsRange = (range as? NSValue)?.rangeValue
        else { return self }

        let attr = NSMutableAttributedString(attributedString:
            _getAttributedText(view) ?? NSAttributedString(string: str))

        if let c = value as? UIColor {
            attr.addAttribute(.foregroundColor, value: c, range: nsRange)
        } else if let c = UIColor.haomissyouColor(value as? String) {
            attr.addAttribute(.foregroundColor, value: c, range: nsRange)
        } else if let f = value as? UIFont {
            attr.addAttribute(.font, value: f, range: nsRange)
        }
        _setAttributedText(attr, on: view)
        if let lbl = view as? UILabel { _applyAutoLayout(lbl) }
        return self
    }

    // MARK: attributedSubstringKeyValue

    /// 对 `substring` 首次出现的范围应用任意 `NSAttributedString.Key`
    @discardableResult
    func attributedSubstringKeyValue(_ substring: Any, _ key: Any, _ value: Any) -> Haomissyou {
        guard let str = _getText(view), !str.isEmpty,
              let sub = substring as? String,
              let attrKey = key as? NSAttributedString.Key,
              let nsRange = str.range(of: sub).map({ NSRange($0, in: str) })
        else { return self }

        let attr = NSMutableAttributedString(attributedString:
            _getAttributedText(view) ?? NSAttributedString(string: str))
        attr.addAttribute(attrKey, value: value, range: nsRange)
        _setAttributedText(attr, on: view)
        if let lbl = view as? UILabel { _applyAutoLayout(lbl) }
        return self
    }

    // MARK: attributedSubstringKeyValueInRange

    /// 在指定 `range` 应用任意 `NSAttributedString.Key`
    @discardableResult
    func attributedSubstringKeyValueInRange(_ substring: Any, _ key: Any, _ value: Any, _ range: Any) -> Haomissyou {
        guard let str = _getText(view), !str.isEmpty,
              let attrKey = key as? NSAttributedString.Key,
              let nsRange = (range as? NSValue)?.rangeValue
        else { return self }

        let attr = NSMutableAttributedString(attributedString:
            _getAttributedText(view) ?? NSAttributedString(string: str))
        attr.addAttribute(attrKey, value: value, range: nsRange)
        _setAttributedText(attr, on: view)
        if let lbl = view as? UILabel { _applyAutoLayout(lbl) }
        return self
    }

    // MARK: - UILabel

    // MARK: lines

    /// numberOfLines — UILabel / UIButton.titleLabel
    @discardableResult
    func lines(_ value: Any) -> Haomissyou {
        let n: Int
        switch value {
        case let num as NSNumber: n = num.intValue
        case let s as String:     n = Int(s) ?? 0
        default: return self
        }
        if let lbl = view as? UILabel {
            lbl.numberOfLines = n
        } else if let btn = view as? UIButton {
            btn.titleLabel?.numberOfLines = n
        }
        return self
    }

    // MARK: adjust

    /// adjustsFontSizeToFitWidth — UILabel / UIButton.titleLabel
    @discardableResult
    func adjust(_ value: Any) -> Haomissyou {
        let b: Bool
        switch value {
        case let bv as Bool:      b = bv
        case let num as NSNumber: b = num.boolValue
        case let s as String:     b = (s as NSString).boolValue
        default: return self
        }
        if let lbl = view as? UILabel {
            lbl.adjustsFontSizeToFitWidth = b
        } else if let btn = view as? UIButton {
            btn.titleLabel?.adjustsFontSizeToFitWidth = b
        }
        return self
    }

    // MARK: lineSpace

    /// 行间距（CGFloat / NSNumber / String）— 仅 UILabel
    @discardableResult
    func lineSpace(_ value: Any) -> Haomissyou {
        guard let lbl = view as? UILabel else { return self }
        let space: CGFloat
        switch value {
        case let n as CGFloat:   space = n
        case let n as Double:    space = CGFloat(n)
        case let n as Float:     space = CGFloat(n)
        case let n as NSNumber:  space = CGFloat(n.doubleValue)
        case let s as String:
            guard let d = Double(s) else { return self }
            space = CGFloat(d)
        default: return self
        }

        let text = lbl.text ?? ""
        let base = lbl.attributedText ?? NSAttributedString(string: text)
        let attr = NSMutableAttributedString(attributedString: base)
        let para = NSMutableParagraphStyle()
        // 与 ObjC 一致：lineSpacing = max(0, space - (lineHeight - pointSize))
        let lineSpacing = max(0, space - (lbl.font.lineHeight - lbl.font.pointSize))
        para.lineSpacing = lineSpacing
        para.alignment = lbl.textAlignment
        attr.addAttribute(.paragraphStyle, value: para,
                          range: NSRange(location: 0, length: (text as NSString).length))
        lbl.attributedText = attr
        return self
    }

    // MARK: autoWidth

    /// 计算单行所需宽度，保持原高度；maxWidth=0 表示不限 — 仅 UILabel
    /// 调用后，后续 attributedSubstring 系列方法改变文字属性时会自动重新计算宽度。
    @discardableResult
    func autoWidth(_ value: Any) -> Haomissyou {
        guard let lbl = view as? UILabel else { return self }
        let maxW: CGFloat
        switch value {
        case let n as CGFloat:   maxW = n
        case let n as Double:    maxW = CGFloat(n)
        case let n as NSNumber:  maxW = CGFloat(n.doubleValue)
        case let s as String:    maxW = CGFloat(Double(s) ?? 0)
        default: return self
        }
        // 记录 maxW 到关联对象，供后续 attributedSubstring 自动重算使用
        objc_setAssociatedObject(lbl, &_autoWidthMaxKey,
                                 NSNumber(value: Double(maxW)),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        _applyAutoWidth(lbl)
        return self
    }

    // MARK: autoHeight

    /// 计算多行所需高度；maxHeight=0 表示不限 — 仅 UILabel
    /// 调用后，后续 attributedSubstring 系列方法改变文字属性时会自动重新计算高度。
    @discardableResult
    func autoHeight(_ value: Any) -> Haomissyou {
        guard let lbl = view as? UILabel else { return self }
        let maxH: CGFloat
        switch value {
        case let n as CGFloat:   maxH = n
        case let n as Double:    maxH = CGFloat(n)
        case let n as NSNumber:  maxH = CGFloat(n.doubleValue)
        case let s as String:    maxH = CGFloat(Double(s) ?? 0)
        default: return self
        }
        // 记录 maxH 到关联对象，供后续 attributedSubstring 自动重算使用
        objc_setAssociatedObject(lbl, &_autoHeightMaxKey,
                                 NSNumber(value: Double(maxH)),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        _applyAutoHeight(lbl)
        return self
    }

    // MARK: textInsets

    /// HaomissyouLabel 文字内边距（left/right 自动适配 RTL）。
    /// 仅对 HaomissyouLabel 生效。
    @discardableResult
    func textInsets(_ value: UIEdgeInsets) -> Haomissyou {
        guard let lbl = view as? HaomissyouLabel else { return self }
        lbl.textInsets = value
        return self
    }

    // MARK: highlightedTextColor

    /// UILabel.highlightedTextColor — UIColor / hex String
    @discardableResult
    func highlightedTextColor(_ value: Any) -> Haomissyou {
        guard let lbl = view as? UILabel,
              let c = UIColor.haomissyouColor(value) else { return self }
        lbl.highlightedTextColor = c
        return self
    }
}
