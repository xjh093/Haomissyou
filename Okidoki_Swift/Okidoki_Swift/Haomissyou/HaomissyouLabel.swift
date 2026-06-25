//
//  HaomissyouLabel.swift
//
//  Created by HaoCold on 2026-06-24
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  UILabel 子类，支持四方向文字内边距，且兼容阿拉伯语等 RTL 语言。
//  textInsets 的 left/right 按「语义（leading/trailing）」解释：
//    LTR：left = 起始边距，right = 结束边距
//    RTL：left/right 自动互换，保持视觉一致
//
//  MIT License

import UIKit

public final class HaomissyouLabel: UILabel {

    /// 文字内边距。left/right 按 leading/trailing 语义自动适配 RTL。
    public var textInsets: UIEdgeInsets = .zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    // MARK: - RTL 适配

    /// 将语义 insets 转换为当前布局方向下的物理 insets。
    private var resolvedInsets: UIEdgeInsets {
        guard effectiveUserInterfaceLayoutDirection == .rightToLeft else {
            return textInsets
        }
        // RTL：left(leading) ↔ right(trailing) 互换
        return UIEdgeInsets(top:    textInsets.top,
                            left:   textInsets.right,
                            bottom: textInsets.bottom,
                            right:  textInsets.left)
    }

    // MARK: - Overrides

    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: resolvedInsets))
    }

    /// Auto Layout 感知：intrinsicContentSize 加上 insets。
    public override var intrinsicContentSize: CGSize {
        var s = super.intrinsicContentSize
        s.width  += textInsets.left + textInsets.right
        s.height += textInsets.top  + textInsets.bottom
        return s
    }

    /// sizeToFit / sizeThatFits 感知：先缩减可用区域再加回 insets。
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let ins = resolvedInsets
        var s = super.sizeThatFits(
            CGSize(width:  max(0, size.width  - ins.left - ins.right),
                   height: max(0, size.height - ins.top  - ins.bottom)))
        s.width  += ins.left + ins.right
        s.height += ins.top  + ins.bottom
        return s
    }
}
