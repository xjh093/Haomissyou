//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-23
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

extension UIColor {

    /// 从任意值解析 UIColor，支持格式与 Okidoki 一致。
    /// - `UIColor` → 原样返回
    /// - `String`  → 解析十六进制色值字符串
    /// @nonobjc 阻止桥接到 ObjC，避免与 UIColor(Okidoki) category 冲突
    @nonobjc
    static func haomissyouColor(_ value: Any?) -> UIColor? {
    guard let value = value else { return nil }

    if let color = value as? UIColor { return color }

    guard let raw = value as? String else { return nil }

    var hex = raw.trimmingCharacters(in: .whitespaces)

    if hex.hasPrefix("#") {
        hex = String(hex.dropFirst())
    } else if hex.lowercased().hasPrefix("0x") {
        hex = String(hex.dropFirst(2))
    }

    guard hex.count == 6 || hex.count == 8 else { return nil }

    var rgb: UInt64 = 0
    guard Scanner(string: hex).scanHexInt64(&rgb) else { return nil }

    if hex.count == 6 {
        return UIColor(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >>  8) / 255.0,
            blue:  CGFloat( rgb & 0x0000FF)         / 255.0,
            alpha: 1.0
        )
    } else {
        return UIColor(
            red:   CGFloat((rgb & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgb & 0x00FF0000) >> 16) / 255.0,
            blue:  CGFloat((rgb & 0x0000FF00) >>  8) / 255.0,
            alpha: CGFloat( rgb & 0x000000FF)         / 255.0
        )
    }
}

    /// 返回指定透明度的新颜色。
    /// 对应 ObjC `UIColor.okidokiAlpha(0.5)`。
    /// 用法：`UIColor.red.haomissyouAlpha(0.5)`
    @nonobjc
    func haomissyouAlpha(_ alpha: CGFloat) -> UIColor {
        withAlphaComponent(alpha)
    }
}

// MARK: - String + haomissyouHexColor

extension String {

    /// 将十六进制色值字符串转为 UIColor。
    /// 对应 ObjC `@"FF0000".okidokiHexColor`。
    /// 用法：`"FF0000".haomissyouHexColor`
    public var haomissyouHexColor: UIColor? {
        UIColor.haomissyouColor(self)
    }
}
