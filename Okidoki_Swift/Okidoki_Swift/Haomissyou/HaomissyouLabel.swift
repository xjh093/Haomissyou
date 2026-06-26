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
    
    
#if DEBUG
    // MARK: - Debug

    /// 调试开关：可视化展示 textInsets 区域。
    ///
    /// 开启后叠加绘制：
    /// - 红色虚线框：标签 bounds 边界
    /// - 蓝色实线框：文字实际绘制区域（insets 收缩后）
    /// - 半透明红色填充：四个 inset 区域
    public var debugBorder: Bool = false {
        didSet { setNeedsDisplay() }
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard debugBorder, let ctx = UIGraphicsGetCurrentContext() else { return }

        let ins = resolvedInsets
        let textRect = rect.inset(by: ins)

        ctx.saveGState()

        // 半透明红色填充：insets 区域
        ctx.setFillColor(UIColor.systemRed.withAlphaComponent(0.18).cgColor)
        // top
        ctx.fill(CGRect(x: rect.minX, y: rect.minY,
                        width: rect.width, height: ins.top))
        // bottom
        ctx.fill(CGRect(x: rect.minX, y: rect.maxY - ins.bottom,
                        width: rect.width, height: ins.bottom))
        // left（top/bottom 之间）
        ctx.fill(CGRect(x: rect.minX, y: rect.minY + ins.top,
                        width: ins.left, height: rect.height - ins.top - ins.bottom))
        // right
        ctx.fill(CGRect(x: rect.maxX - ins.right, y: rect.minY + ins.top,
                        width: ins.right, height: rect.height - ins.top - ins.bottom))

        // 蓝色实线：文字绘制区域
        ctx.setStrokeColor(UIColor.systemBlue.cgColor)
        ctx.setLineWidth(1)
        ctx.stroke(textRect.insetBy(dx: 0.5, dy: 0.5))

        // 红色虚线：标签边界
        ctx.setStrokeColor(UIColor.systemRed.cgColor)
        ctx.setLineWidth(1)
        ctx.setLineDash(phase: 0, lengths: [4, 2])
        ctx.stroke(rect.insetBy(dx: 0.5, dy: 0.5))

        ctx.restoreGState()
    }
#endif
}
