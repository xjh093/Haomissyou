//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-24
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - Private helpers

private func _btnState(from value: Any) -> UIControl.State? {
    switch value {
    case let s as UIControl.State: return s
    case let n as NSNumber:        return UIControl.State(rawValue: UInt(n.uintValue))
    case let s as String:          return UIControl.State(rawValue: UInt(Int(s) ?? 0))
    default: return nil
    }
}

/// 获取 button 某 state 的 attributed title，与 plain title 不一致时用 plain title 重建。
private func _btnAttrTitle(_ btn: UIButton, for state: UIControl.State) -> NSMutableAttributedString {
    let plain = btn.title(for: state) ?? ""
    if let attr = btn.attributedTitle(for: state), attr.string == plain {
        return NSMutableAttributedString(attributedString: attr)
    }
    return NSMutableAttributedString(string: plain)
}

// MARK: - UIButton

public extension Haomissyou {

    // MARK: title (normal state)

    /// UIButton normal state title — String
    @discardableResult
    func title(_ value: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let s = value as? String else { return self }
        btn.setTitle(s, for: .normal)
        return self
    }

    // MARK: titleForState

    /// title: String, state: NSNumber / String
    @discardableResult
    func titleForState(_ title: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let s = title as? String,
              let st = _btnState(from: state) else { return self }
        btn.setTitle(s, for: st)
        return self
    }

    // MARK: colorForState

    /// color: UIColor / hex String, state: NSNumber / String
    @discardableResult
    func colorForState(_ color: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let st = _btnState(from: state),
              let c = UIColor.haomissyouColor(color) else { return self }
        btn.setTitleColor(c, for: st)
        return self
    }

    // MARK: imageForState

    /// image: UIImage / String (imageNamed), state: NSNumber / String
    @discardableResult
    func imageForState(_ image: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let st = _btnState(from: state) else { return self }
        if let img = image as? UIImage {
            btn.setImage(img, for: st)
        } else if let name = image as? String {
            btn.setImage(UIImage(named: name), for: st)
        }
        return self
    }

    // MARK: bgImageForState

    /// bgImage: UIImage / String (imageNamed), state: NSNumber / String
    @discardableResult
    func bgImageForState(_ bgImage: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let st = _btnState(from: state) else { return self }
        if let img = bgImage as? UIImage {
            btn.setBackgroundImage(img, for: st)
        } else if let name = bgImage as? String {
            btn.setBackgroundImage(UIImage(named: name), for: st)
        }
        return self
    }

    // MARK: lineSpaceForState

    /// 行间距（NSNumber / String），state: NSNumber / String
    @discardableResult
    func lineSpaceForState(_ lineSpace: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let st = _btnState(from: state) else { return self }
        let space: CGFloat
        switch lineSpace {
        case let n as CGFloat:  space = n
        case let n as Double:   space = CGFloat(n)
        case let n as NSNumber: space = CGFloat(n.doubleValue)
        case let s as String:   space = CGFloat(Double(s) ?? 0)
        default: return self
        }
        let font = btn.titleLabel?.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let lineSpacing = max(0, space - (font.lineHeight - font.pointSize))
        let attr = _btnAttrTitle(btn, for: st)
        let para = NSMutableParagraphStyle()
        para.lineSpacing = lineSpacing
        para.alignment = btn.titleLabel?.textAlignment ?? .natural
        attr.addAttribute(.paragraphStyle, value: para,
                          range: NSRange(location: 0, length: attr.string.utf16.count))
        btn.setAttributedTitle(attr, for: st)
        return self
    }

    // MARK: imageUpTitleDown

    /// 图上文下，space: NSNumber / CGFloat
    @discardableResult
    func imageUpTitleDown(_ value: Any) -> Haomissyou {
        guard let btn = view as? UIButton else { return self }
        let Y: CGFloat
        switch value {
        case let n as CGFloat:  Y = n
        case let n as Double:   Y = CGFloat(n)
        case let n as NSNumber: Y = CGFloat(n.doubleValue)
        default: return self
        }
        if #available(iOS 15.0, *) {
            var config = btn.configuration ?? .plain()
            config.imagePlacement = .top
            config.imagePadding   = Y
            btn.configuration = config
        } else {
            btn.layoutIfNeeded()
            let titleW = btn.titleLabel?.intrinsicContentSize.width  ?? 0
            let titleH = btn.titleLabel?.intrinsicContentSize.height ?? 0
            let imageW = btn.imageView?.frame.width  ?? 0
            let imageH = btn.imageView?.frame.height ?? 0
            btn.imageEdgeInsets = UIEdgeInsets(top: -(titleH + Y), left: 0, bottom: 0, right: -titleW)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageW, bottom: -(imageH + Y), right: 0)
        }
        return self
    }

    // MARK: imageDownTitleUp

    /// 图下文上，space: NSNumber / CGFloat
    @discardableResult
    func imageDownTitleUp(_ value: Any) -> Haomissyou {
        guard let btn = view as? UIButton else { return self }
        let Y: CGFloat
        switch value {
        case let n as CGFloat:  Y = n
        case let n as Double:   Y = CGFloat(n)
        case let n as NSNumber: Y = CGFloat(n.doubleValue)
        default: return self
        }
        if #available(iOS 15.0, *) {
            var config = btn.configuration ?? .plain()
            config.imagePlacement = .bottom
            config.imagePadding   = Y
            btn.configuration = config
        } else {
            btn.layoutIfNeeded()
            let titleH = btn.titleLabel?.intrinsicContentSize.height ?? 0
            let imageW = btn.imageView?.frame.width  ?? 0
            let imageH = btn.imageView?.frame.height ?? 0
            btn.imageEdgeInsets = UIEdgeInsets(top: titleH + Y, left: 0, bottom: 0, right: -imageW)
            btn.titleEdgeInsets = UIEdgeInsets(top: -(imageH + Y), left: -imageW, bottom: 0, right: 0)
        }
        return self
    }

    // MARK: imageRightTitleLeft

    /// 图右文左，space: NSNumber / CGFloat
    @discardableResult
    func imageRightTitleLeft(_ value: Any) -> Haomissyou {
        guard let btn = view as? UIButton else { return self }
        let X: CGFloat
        switch value {
        case let n as CGFloat:  X = n
        case let n as Double:   X = CGFloat(n)
        case let n as NSNumber: X = CGFloat(n.doubleValue)
        default: return self
        }
        if #available(iOS 15.0, *) {
            var config = btn.configuration ?? .plain()
            config.imagePlacement = .trailing
            config.imagePadding   = X
            btn.configuration = config
        } else {
            btn.layoutIfNeeded()
            let titleW = btn.titleLabel?.intrinsicContentSize.width ?? 0
            let imageW = btn.imageView?.frame.width ?? 0
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -(titleW * 2 + X))
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageW * 2 + X), bottom: 0, right: 0)
        }
        return self
    }

    // MARK: imageLeftTitleRight

    /// 图左文右（增加间距），space: NSNumber / CGFloat
    @discardableResult
    func imageLeftTitleRight(_ value: Any) -> Haomissyou {
        guard let btn = view as? UIButton else { return self }
        let X: CGFloat
        switch value {
        case let n as CGFloat:  X = n
        case let n as Double:   X = CGFloat(n)
        case let n as NSNumber: X = CGFloat(n.doubleValue)
        default: return self
        }
        if #available(iOS 15.0, *) {
            var config = btn.configuration ?? .plain()
            config.imagePlacement = .leading
            config.imagePadding   = X
            btn.configuration = config
        } else {
            btn.layoutIfNeeded()
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: X)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: X, bottom: 0, right: 0)
        }
        return self
    }

    // MARK: imageCenterTitleCenter

    /// 图文均居中。iOS 15+ 使用 .leading 布局（图左文右居中组合）；iOS 14- 使用 EdgeInsets 使两者重叠居中。
    @discardableResult
    func imageCenterTitleCenter() -> Haomissyou {
        guard let btn = view as? UIButton else { return self }
        if #available(iOS 15.0, *) {
            var config = btn.configuration ?? .plain()
            config.imagePlacement = .leading
            config.imagePadding   = 0
            btn.configuration = config
        } else {
            btn.layoutIfNeeded()
            let titleW = btn.titleLabel?.intrinsicContentSize.width ?? 0
            let imageW = btn.imageView?.frame.width ?? 0
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleW)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageW, bottom: 0, right: 0)
        }
        return self
    }

    // MARK: attributedSubstringForState

    /// substring: String, value: UIColor / UIFont, state: NSNumber / String
    @discardableResult
    func attributedSubstringForState(_ substring: Any, _ value: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let sub = substring as? String,
              let st = _btnState(from: state) else { return self }
        let attr = _btnAttrTitle(btn, for: st)
        guard let range = attr.string.range(of: sub).map({ NSRange($0, in: attr.string) }) else { return self }
        if let c = value as? UIColor {
            attr.addAttribute(.foregroundColor, value: c, range: range)
        } else if let c = UIColor.haomissyouColor(value as? String) {
            attr.addAttribute(.foregroundColor, value: c, range: range)
        } else if let f = value as? UIFont {
            attr.addAttribute(.font, value: f, range: range)
        } else { return self }
        btn.setAttributedTitle(attr, for: st)
        return self
    }

    // MARK: attributedSubstringInRangeForState

    /// substring: String, value: UIColor / UIFont, range: NSValue, state: NSNumber / String
    @discardableResult
    func attributedSubstringInRangeForState(_ substring: Any, _ value: Any,
                                            _ range: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let nsRange = (range as? NSValue)?.rangeValue,
              let st = _btnState(from: state) else { return self }
        let attr = _btnAttrTitle(btn, for: st)
        if let c = value as? UIColor {
            attr.addAttribute(.foregroundColor, value: c, range: nsRange)
        } else if let c = UIColor.haomissyouColor(value as? String) {
            attr.addAttribute(.foregroundColor, value: c, range: nsRange)
        } else if let f = value as? UIFont {
            attr.addAttribute(.font, value: f, range: nsRange)
        } else { return self }
        btn.setAttributedTitle(attr, for: st)
        return self
    }

    // MARK: attributedSubstringKeyValueForState

    /// substring: String, key: NSAttributedString.Key, value: Any, state: NSNumber / String
    @discardableResult
    func attributedSubstringKeyValueForState(_ substring: Any, _ key: Any,
                                             _ value: Any, _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let sub = substring as? String,
              let attrKey = key as? NSAttributedString.Key,
              let st = _btnState(from: state) else { return self }
        let attr = _btnAttrTitle(btn, for: st)
        guard !attr.string.isEmpty,
              let range = attr.string.range(of: sub).map({ NSRange($0, in: attr.string) }) else { return self }
        attr.addAttribute(attrKey, value: value, range: range)
        btn.setAttributedTitle(attr, for: st)
        return self
    }

    // MARK: attributedSubstringKeyValueInRangeForState

    /// substring: String, key: NSAttributedString.Key, value: Any, range: NSValue, state: NSNumber / String
    @discardableResult
    func attributedSubstringKeyValueInRangeForState(_ substring: Any, _ key: Any,
                                                    _ value: Any, _ range: Any,
                                                    _ state: Any) -> Haomissyou {
        guard let btn = view as? UIButton,
              let attrKey = key as? NSAttributedString.Key,
              let nsRange = (range as? NSValue)?.rangeValue,
              let st = _btnState(from: state) else { return self }
        let attr = _btnAttrTitle(btn, for: st)
        guard !attr.string.isEmpty else { return self }
        attr.addAttribute(attrKey, value: value, range: nsRange)
        btn.setAttributedTitle(attr, for: st)
        return self
    }
}
