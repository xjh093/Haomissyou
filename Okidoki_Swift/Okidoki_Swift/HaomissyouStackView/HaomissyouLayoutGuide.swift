//
//  HaomissyouLayoutGuide.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - Enums

/// 主轴方向。决定子视图沿水平还是垂直方向排列。
public enum HaomissyouStackViewAxis {
    case horizontal  // 水平排列
    case vertical    // 垂直排列
}

/// 交叉轴对齐方式（等价于 CSS Flexbox 的 `align-items` / `align-self`）。
///
/// 控制子视图在**垂直于主轴方向**上的摆放位置。
/// 例如水平布局时，`align` 控制每个子视图在垂直方向上如何对齐。
///
/// - center: 交叉轴居中
/// - start:  靠交叉轴起始端（水平布局→顶部，垂直布局→左侧）
/// - end:    靠交叉轴末端（水平布局→底部，垂直布局→右侧）
/// - fill:   拉伸填满整个交叉轴（默认）
public enum HaomissyouAlign: Int {
    case center = 0
    case start
    case end
    case fill
}

/// 主轴对齐方式（等价于 CSS Flexbox 的 `justify-content`）。
///
/// 控制子视图在**主轴方向**上的分布策略。
/// `HaomissyouFlexManager` 根据此值决定插入何种 Guide 以及如何生成约束链。
///
/// - fill:         所有子视图拉伸均分主轴
/// - fillEqually:  所有子视图等宽/等高（`widthAnchor == widthAnchor`）
/// - start:        靠起始端对齐，尾部 `<=` 约束留空
/// - center:       居中，两端各插入一个等宽/等高的对称 Guide
/// - end:          靠末端，首个视图用 `>=` 约束，允许前端留空
/// - spaceBetween: 首尾无边距，相邻视图间插入等宽 Guide
/// - spaceAround:  两端 Guide = 中间 Guide × 0.5
/// - spaceEvenly:  两端 Guide = 中间 Guide（所有间距完全相等）
public enum HaomissyouJustify: Int {
    case fill = 0
    case fillEqually
    case start
    case center
    case end
    case spaceBetween  // 两边没有间距，中间相等
    case spaceAround   // 两边是中间一半
    case spaceEvenly   // 所有间距都相等
}

// MARK: - HaomissyouLayoutGuide

/// 不可见的布局占位 Guide，用于在子视图之间插入弹性空白或固定间距。
///
/// ## 设计原理
/// AutoLayout 不允许直接在两个视图之间插入"空白"，只能借助辅助视图或
/// `UILayoutGuide` 来占位。`HaomissyouLayoutGuide` 继承自 `UILayoutGuide`
///（纯逻辑对象，无渲染开销），由 `HaomissyouFlexManager` 在约束生成循环中
/// 按需创建，插入主轴约束链，充当三种角色之一：
///
/// | 角色         | 约束                          | 用途            |
/// |--------------|-------------------------------|-----------------|
/// | fixedSpacing | `width/height == 固定值`      | 相邻视图固定间隔 |
/// | flexSpace    | `width/height >= 0`（可伸缩） | 弹性弹簧        |
/// | equalSpacing | `width/height == 首个 Guide`  | 等距分布        |
///
/// ## 生命周期
/// 随 StackView 布局失效而重建：`removeAllSpacing()` 统一将其从 owningView 移除。
class HaomissyouLayoutGuide: UILayoutGuide {

    weak var stackView: UIView? {
        didSet {
            if let view = stackView {
                view.addLayoutGuide(self)
            }
        }
    }

    func removeFromOwningView() {
        owningView?.removeLayoutGuide(self)
    }
}
