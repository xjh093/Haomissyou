//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-23
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
// version: 0.1.0
// 2026-06-25 11:20:29


import UIKit
import ObjectiveC


// MARK: - Haomissyou

public final class Haomissyou {

    /// 被配置的 UIView（对应 ObjC `- (__kindof UIView *)view`）
    /// strong 引用：Haomissyou 不缓存在 view 上，无循环引用风险
    public let view: UIView

    /// 泛型版本，对应 ObjC `__kindof UIView *`，直接返回子类类型，无需解包。
    /// 用法：`let label: UILabel = someView.haomissyou.bgColor("FF0000").getView()`
    public func getView<T: UIView>() -> T {
        guard let v = view as? T else {
            fatalError("[Haomissyou] getView() type mismatch: view is \(type(of: view)), expected \(T.self)")
        }
        return v
    }

    // MARK: Internal — AutoLayout batch state
    var _batchDepth: Int = 0
    var _batchConstraints: [NSLayoutConstraint] = []

    init(_ view: UIView) {
        self.view = view
    }
}

// MARK: - UIView Entry Point

public extension UIView {
    /// 每次返回一个新的 Haomissyou 实例，view 以 strong 持有，链式期间 view 不会被释放。
    var haomissyou: Haomissyou {
        Haomissyou(self)
    }
}

extension UIFont {
    /// UIFont / NSNumber / String("17","s17","b17","i17") → UIFont
    static func haomissyouFont(_ value: Any?) -> UIFont {
        switch value {
        case let f as UIFont:
            return f
        case let n as NSNumber:
            let size = CGFloat(n.doubleValue)
            return size > 0 ? .systemFont(ofSize: size) : .systemFont(ofSize: UIFont.systemFontSize)
        case let s as String:
            if let size = Double(s), size > 0 {
                return .systemFont(ofSize: CGFloat(size))
            }
            if s.count > 1 {
                let rest = String(s.dropFirst())
                if let size = Double(rest), size > 0 {
                    switch s.first {
                    case "s": return .systemFont(ofSize: CGFloat(size))
                    case "b": return .boldSystemFont(ofSize: CGFloat(size))
                    case "i": return .italicSystemFont(ofSize: CGFloat(size))
                    default: break
                    }
                }
            }
            return .systemFont(ofSize: UIFont.systemFontSize)
        default:
            return .systemFont(ofSize: UIFont.systemFontSize)
        }
    }
}

// MARK: - Number Adaptor

/// 与 Okidoki_NumberAdaptor 逻辑一致：以 375pt 为基准宽度缩放，再做像素对齐。
public func haomissyou_NumberAdaptor(_ number: CGFloat) -> CGFloat {
    guard number != 0,
          number != .greatestFiniteMagnitude,
          number != -.greatestFiniteMagnitude else { return number }

    let scale = UIScreen.main.scale
    let width = UIScreen.main.bounds.width
    let n = number * width / 375.0

    if n < 0 {
        return ceil(n * scale - 0.5) / scale
    } else {
        return floor(n * scale + 0.5) / scale
    }
}
