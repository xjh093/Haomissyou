//
//  HaomissyouFlexManager.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - HaomissyouFlexManager

/// 约束生成引擎，负责将 StackView 的布局参数翻译成 `NSLayoutConstraint` 数组。
///
/// ## 架构定位
///
/// ```
/// HaomissyouBaseStackView（布局控制层）
///         │  读取 axis / alignment / justifyContent / arrangedViews
///         ▼
/// HaomissyouFlexManager（约束生成层）← 读取每个视图的 HaomissyouFlexItem
///         │  生成 NSLayoutConstraint 数组
///         ▼
/// HaomissyouStackEdgeInsets（锚点适配层）
///         │  提供 insets 感知 + justify 感知的锚点
///         ▼
/// HaomissyouLayoutGuide（占位 Guide）
/// ```
///
/// ## 工作流程
///
/// 1. `HaomissyouBaseStackView.updateConstraints()` 调用：
///    - `deactivateConstraints()` → 停用并清空旧约束
///    - `removeAllSpacing()` → 移除旧 Guide
///    - `addHorizontalLayoutConstraints()` 或 `addVerticalLayoutConstraints()`（互斥）
///    - `activateConstraints()` → 批量激活新约束
///
/// 2. 两个布局方法通过 `guard isHorizontal` 互斥，调用方可以两个都调，
///    让守卫条件自动过滤。
///
/// ## 约束链模型
///
/// 循环内用 `nextAnchor` 游标将所有视图和 Guide 串成一条链：
///
/// ```
/// jLeadingAnchor
///   └─ [view.leading == nextAnchor]  → nextAnchor = view.trailing
///       └─ [flexSpace.leading == nextAnchor]（可选）→ nextAnchor = flexSpace.trailing
///           └─ [spacing.leading == nextAnchor]（可选）→ nextAnchor = spacing.trailing
///               └─ [equalSpacing.leading == nextAnchor]（可选）→ nextAnchor = equalSpacing.trailing
///                   └─ 下一个视图...
///   jTrailingAnchor（最终尾部约束）
/// ```
///
/// **顺序严格不可乱**：每次更新 `nextAnchor` 即确定了物理位置，无法回退。
///
/// ## 约束不激活原则
/// 所有约束只 `append` 到 `self.constraints`，**不直接激活**。
/// 由外部 `activateConstraints()` 统一批量激活，避免增量激活时的性能损耗。
final class HaomissyouFlexManager: NSObject {

    weak var stackView: HaomissyouBaseStackView?

    private var _stackEdgeInsets: HaomissyouStackEdgeInsets?
    private(set) var constraints: [NSLayoutConstraint] = []

    // MARK: - Accessors

    private var stackEdgeInsets: HaomissyouStackEdgeInsets {
        if let e = _stackEdgeInsets { return e }
        let e = HaomissyouStackEdgeInsets()
        e.stackView = stackView
        _stackEdgeInsets = e
        return e
    }

    private var views: [UIView] { stackView?.arrangedViews ?? [] }
    private var justify: HaomissyouJustify { stackView?.justifyContent ?? .fill }
    private var align: HaomissyouAlign { stackView?.alignment ?? .fill }
    private var isHorizontal: Bool { stackView?.axis == .horizontal }

    // MARK: - Public interface

    func removeAllSpacing() {
        _stackEdgeInsets?.removeEdgeInsets()
        stackView?.layoutGuides
            .compactMap { $0 as? HaomissyouLayoutGuide }
            .forEach { $0.removeFromOwningView() }
    }

    func activateConstraints() {
        NSLayoutConstraint.activate(constraints)
    }

    func deactivateConstraints() {
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
    }

    func updateInsets(_ insets: UIEdgeInsets) {
        stackEdgeInsets.insets = insets
    }

    // MARK: - Horizontal layout

    func addHorizontalLayoutConstraints() {
        guard isHorizontal else { return }

        var nextAnchor: NSLayoutXAxisAnchor = stackEdgeInsets.jLeadingAnchor
        let count = views.count
        var widthDim:     NSLayoutDimension?  // for SpaceBetween/Around/Evenly
        var viewWidthDim: NSLayoutDimension?  // for FillEqually
        var flexWidthDim: NSLayoutDimension?  // for FlexSpace

        var flexViews: [UIView] = []

        for i in 0 ..< count {
            let view = views[i]
            view.translatesAutoresizingMaskIntoConstraints = false

            // Low-priority fallback height so views with no intrinsic size don't collapse
            if align != .fill,
               view.intrinsicContentSize == CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) {
                let c = view.heightAnchor.constraint(equalToConstant: 0)
                c.priority = UILayoutPriority(UILayoutPriority.fittingSizeLevel.rawValue / 2.0)
                constraints.append(c)
            }

            let cfg = view.hmFlex
            if cfg.flexValue > 0, justify != .fillEqually {
                flexViews.append(view)
            }

            // Cross-axis (vertical) constraints
            addCrossAxisConstraints(for: view, cfg: cfg, isHorizontal: true)

            // Main-axis leading constraint
            let leadingCons: NSLayoutConstraint
            if justify == .end, i == 0 {
                leadingCons = view.leadingAnchor.constraint(greaterThanOrEqualTo: nextAnchor)
            } else {
                leadingCons = view.leadingAnchor.constraint(equalTo: nextAnchor)
            }
            nextAnchor = view.trailingAnchor
            constraints.append(leadingCons)

            // FillEqually: equal widths
            if justify == .fillEqually {
                if let wd = viewWidthDim {
                    constraints.append(view.widthAnchor.constraint(equalTo: wd))
                }
                viewWidthDim = view.widthAnchor
            }

            // FillEqually + Fill: handle flex space
            if (justify == .fillEqually || justify == .fill), cfg.isFlexSpace {
                let guide = makeGuide()
                constraints.append(guide.leadingAnchor.constraint(equalTo: nextAnchor))
                nextAnchor = guide.trailingAnchor
                constraints.append(guide.widthAnchor.constraint(greaterThanOrEqualToConstant: 0))
                if let fd = flexWidthDim {
                    constraints.append(fd.constraint(equalTo: guide.widthAnchor))
                }
                flexWidthDim = guide.widthAnchor
            }

            // FillEqually + Fill + Start + End + Center: spacing guide between items
            let isStandardJustify: Bool = {
                switch justify {
                case .fillEqually, .fill, .start, .end, .center: return true
                default: return false
                }
            }()

            if isStandardJustify, i < count - 1 {
                let spacing = cfg.spacing
                if cfg.spacing >= 0 || cfg.minSpacing >= 0 || cfg.maxSpacing >= 0 {
                    let guide = makeGuide()
                    constraints.append(guide.leadingAnchor.constraint(equalTo: nextAnchor))
                    nextAnchor = guide.trailingAnchor

                    var spacingFlag = true
                    if cfg.minSpacing >= 0 {
                        let minCons = guide.widthAnchor.constraint(greaterThanOrEqualToConstant: cfg.minSpacing)
                        minCons.hmItem.type = .minSpacing; minCons.hmItem.view = view
                        constraints.append(minCons)
                        let minFallback = guide.widthAnchor.constraint(equalToConstant: cfg.minSpacing)
                        minFallback.priority = UILayoutPriority(UILayoutPriority.fittingSizeLevel.rawValue / 2.0)
                        minFallback.hmItem.type = .minSpacing; minFallback.hmItem.view = view
                        constraints.append(minFallback)
                        if cfg.spacing < cfg.minSpacing { spacingFlag = false }
                    }
                    if cfg.maxSpacing >= 0 {
                        let maxCons = guide.widthAnchor.constraint(lessThanOrEqualToConstant: cfg.maxSpacing)
                        maxCons.hmItem.type = .maxSpacing; maxCons.hmItem.view = view
                        constraints.append(maxCons)
                        let maxFallback = guide.widthAnchor.constraint(equalToConstant: 0)
                        maxFallback.priority = UILayoutPriority(UILayoutPriority.fittingSizeLevel.rawValue / 2.0)
                        maxFallback.hmItem.type = .maxSpacing; maxFallback.hmItem.view = view
                        constraints.append(maxFallback)
                        if cfg.spacing > cfg.maxSpacing { spacingFlag = false }
                    }
                    if spacingFlag, cfg.spacing >= 0 {
                        let spacingCons = guide.widthAnchor.constraint(equalToConstant: spacing)
                        spacingCons.hmItem.type = .spacing; spacingCons.hmItem.view = view
                        constraints.append(spacingCons)
                    }
                }
            }

            // SpaceBetween / SpaceAround / SpaceEvenly: equal spacing guides
            switch justify {
            case .spaceBetween, .spaceAround, .spaceEvenly:
                if i < count - 1 {
                    let guide = makeGuide()
                    constraints.append(guide.leadingAnchor.constraint(equalTo: nextAnchor))
                    nextAnchor = guide.trailingAnchor
                    if let wd = widthDim {
                        constraints.append(guide.widthAnchor.constraint(equalTo: wd))
                    }
                    widthDim = guide.widthAnchor
                }
            default: break
            }
        }

        // Trailing constraint
        if justify == .start {
            constraints.append(nextAnchor.constraint(lessThanOrEqualTo: stackEdgeInsets.jTrailingAnchor))
        } else {
            constraints.append(nextAnchor.constraint(equalTo: stackEdgeInsets.jTrailingAnchor))
        }

        // Space-distribution side constraints
        if let wd = widthDim {
            let anchors = stackEdgeInsets.widthAnchors
            constraints.append(anchors[0].constraint(equalTo: anchors[1]))
            if justify == .spaceAround {
                constraints.append(anchors[0].constraint(equalTo: wd, multiplier: 0.5))
            } else if justify == .spaceEvenly {
                constraints.append(anchors[0].constraint(equalTo: wd))
            }
        }
        if justify == .center {
            let anchors = stackEdgeInsets.widthAnchors
            constraints.append(anchors[0].constraint(equalTo: anchors[1]))
        }
        if align == .center {
            let anchors = stackEdgeInsets.heightAnchors
            constraints.append(anchors[0].constraint(equalTo: anchors[1]))
        }

        // Flex weights (relative widths)
        if let firstView = flexViews.first {
            let firstFlex = CGFloat(firstView.hmFlex.flexValue)
            for (idx, flexView) in flexViews.enumerated() {
                flexView.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
                flexView.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)
                if idx > 0 {
                    let multiplier = CGFloat(flexView.hmFlex.flexValue) / firstFlex
                    constraints.append(flexView.widthAnchor.constraint(equalTo: firstView.widthAnchor, multiplier: multiplier))
                }
            }
        }
    }

    // MARK: - Vertical layout

    func addVerticalLayoutConstraints() {
        guard !isHorizontal else { return }

        var nextAnchor: NSLayoutYAxisAnchor = stackEdgeInsets.jTopAnchor
        let count = views.count
        var heightDim:     NSLayoutDimension?
        var viewHeightDim: NSLayoutDimension?
        var flexHeightDim: NSLayoutDimension?

        var flexViews: [UIView] = []

        for i in 0 ..< count {
            let view = views[i]
            view.translatesAutoresizingMaskIntoConstraints = false

            // Low-priority fallback width so views with no intrinsic size don't collapse
            if align != .fill,
               view.intrinsicContentSize == CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) {
                let c = view.widthAnchor.constraint(equalToConstant: 0)
                c.priority = UILayoutPriority(UILayoutPriority.fittingSizeLevel.rawValue / 2.0)
                constraints.append(c)
            }

            let cfg = view.hmFlex
            if cfg.flexValue > 0, justify != .fillEqually {
                flexViews.append(view)
            }

            // Cross-axis (horizontal) constraints
            addCrossAxisConstraints(for: view, cfg: cfg, isHorizontal: false)

            // Main-axis top constraint
            let topCons: NSLayoutConstraint
            if justify == .end, i == 0 {
                topCons = view.topAnchor.constraint(greaterThanOrEqualTo: nextAnchor)
            } else {
                topCons = view.topAnchor.constraint(equalTo: nextAnchor)
            }
            nextAnchor = view.bottomAnchor
            constraints.append(topCons)

            // FillEqually: equal heights
            if justify == .fillEqually {
                if let hd = viewHeightDim {
                    constraints.append(view.heightAnchor.constraint(equalTo: hd))
                }
                viewHeightDim = view.heightAnchor
            }

            // FillEqually + Fill: handle flex space
            if (justify == .fillEqually || justify == .fill), cfg.isFlexSpace {
                let guide = makeGuide()
                constraints.append(guide.topAnchor.constraint(equalTo: nextAnchor))
                nextAnchor = guide.bottomAnchor
                constraints.append(guide.heightAnchor.constraint(greaterThanOrEqualToConstant: 0))
                if let fd = flexHeightDim {
                    constraints.append(fd.constraint(equalTo: guide.heightAnchor))
                }
                flexHeightDim = guide.heightAnchor
            }

            // Standard justify: spacing guide between items
            let isStandardJustify: Bool = {
                switch justify {
                case .fillEqually, .fill, .start, .end, .center: return true
                default: return false
                }
            }()

            if isStandardJustify, i < count - 1 {
                let spacing = cfg.spacing
                if cfg.spacing >= 0 || cfg.minSpacing >= 0 || cfg.maxSpacing >= 0 {
                    let guide = makeGuide()
                    constraints.append(guide.topAnchor.constraint(equalTo: nextAnchor))
                    nextAnchor = guide.bottomAnchor

                    var spacingFlag = true
                    if cfg.minSpacing >= 0 {
                        let minCons = guide.heightAnchor.constraint(greaterThanOrEqualToConstant: cfg.minSpacing)
                        minCons.hmItem.type = .minSpacing; minCons.hmItem.view = view
                        constraints.append(minCons)
                        let minFallback = guide.heightAnchor.constraint(equalToConstant: cfg.minSpacing)
                        minFallback.priority = UILayoutPriority(UILayoutPriority.fittingSizeLevel.rawValue / 2.0)
                        minFallback.hmItem.type = .minSpacing; minFallback.hmItem.view = view
                        constraints.append(minFallback)
                        if cfg.spacing < cfg.minSpacing { spacingFlag = false }
                    }
                    if cfg.maxSpacing >= 0 {
                        let maxCons = guide.heightAnchor.constraint(lessThanOrEqualToConstant: cfg.maxSpacing)
                        maxCons.hmItem.type = .maxSpacing; maxCons.hmItem.view = view
                        constraints.append(maxCons)
                        let maxFallback = guide.heightAnchor.constraint(equalToConstant: 0)
                        maxFallback.priority = UILayoutPriority(UILayoutPriority.fittingSizeLevel.rawValue / 2.0)
                        maxFallback.hmItem.type = .maxSpacing; maxFallback.hmItem.view = view
                        constraints.append(maxFallback)
                        if cfg.spacing > cfg.maxSpacing { spacingFlag = false }
                    }
                    if spacingFlag, cfg.spacing >= 0 {
                        let spacingCons = guide.heightAnchor.constraint(equalToConstant: spacing)
                        spacingCons.hmItem.type = .spacing; spacingCons.hmItem.view = view
                        constraints.append(spacingCons)
                    }
                }
            }

            // SpaceBetween / SpaceAround / SpaceEvenly
            switch justify {
            case .spaceBetween, .spaceAround, .spaceEvenly:
                if i < count - 1 {
                    let guide = makeGuide()
                    constraints.append(guide.topAnchor.constraint(equalTo: nextAnchor))
                    nextAnchor = guide.bottomAnchor
                    if let hd = heightDim {
                        constraints.append(guide.heightAnchor.constraint(equalTo: hd))
                    }
                    heightDim = guide.heightAnchor
                }
            default: break
            }
        }

        // Bottom constraint
        if justify == .start {
            constraints.append(nextAnchor.constraint(lessThanOrEqualTo: stackEdgeInsets.jBottomAnchor))
        } else {
            constraints.append(nextAnchor.constraint(equalTo: stackEdgeInsets.jBottomAnchor))
        }

        // Space-distribution side constraints
        if let hd = heightDim {
            let anchors = stackEdgeInsets.heightAnchors
            constraints.append(anchors[0].constraint(equalTo: anchors[1]))
            if justify == .spaceAround {
                constraints.append(anchors[0].constraint(equalTo: hd, multiplier: 0.5))
            } else if justify == .spaceEvenly {
                constraints.append(anchors[0].constraint(equalTo: hd))
            }
        }
        if justify == .center {
            let anchors = stackEdgeInsets.heightAnchors
            constraints.append(anchors[0].constraint(equalTo: anchors[1]))
        }
        if align == .center {
            let anchors = stackEdgeInsets.widthAnchors
            constraints.append(anchors[0].constraint(equalTo: anchors[1]))
        }

        // Flex weights (relative heights)
        if let firstView = flexViews.first {
            let firstFlex = CGFloat(firstView.hmFlex.flexValue)
            for (idx, flexView) in flexViews.enumerated() {
                flexView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
                flexView.setContentCompressionResistancePriority(.defaultHigh - 1, for: .vertical)
                if idx > 0 {
                    let multiplier = CGFloat(flexView.hmFlex.flexValue) / firstFlex
                    constraints.append(flexView.heightAnchor.constraint(equalTo: firstView.heightAnchor, multiplier: multiplier))
                }
            }
        }
    }

    // MARK: - Cross-axis constraint helper

    private func addCrossAxisConstraints(for view: UIView, cfg: HaomissyouFlexItem, isHorizontal: Bool) {
        let startSpacing = cfg.startSpacing
        let endSpacing   = cfg.endSpacing

        if isHorizontal {
            // Horizontal layout: cross axis = vertical (top/bottom)
            switch cfg.alignSelf {
            case .start:
                let c1 = view.topAnchor.constraint(equalTo: stackEdgeInsets.topAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.bottomAnchor.constraint(lessThanOrEqualTo: stackEdgeInsets.bottomAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)

            case .center:
                let offset = (startSpacing - endSpacing) * 0.5
                let c1 = view.topAnchor.constraint(greaterThanOrEqualTo: stackEdgeInsets.topAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.bottomAnchor.constraint(lessThanOrEqualTo: stackEdgeInsets.bottomAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)
                let c3 = view.centerYAnchor.constraint(equalTo: stackEdgeInsets.centerYAnchor, constant: offset)
                c3.hmItem.type = .center; c3.hmItem.view = view; constraints.append(c3)

            case .end:
                let c1 = view.topAnchor.constraint(greaterThanOrEqualTo: stackEdgeInsets.topAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.bottomAnchor.constraint(equalTo: stackEdgeInsets.bottomAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)

            case .fill:
                let c1 = view.topAnchor.constraint(equalTo: stackEdgeInsets.topAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.bottomAnchor.constraint(equalTo: stackEdgeInsets.bottomAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)
            }
        } else {
            // Vertical layout: cross axis = horizontal (leading/trailing)
            switch cfg.alignSelf {
            case .start:
                let c1 = view.leadingAnchor.constraint(equalTo: stackEdgeInsets.leadingAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.trailingAnchor.constraint(lessThanOrEqualTo: stackEdgeInsets.trailingAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)

            case .center:
                let offset = (startSpacing - endSpacing) * 0.5
                let c1 = view.leadingAnchor.constraint(greaterThanOrEqualTo: stackEdgeInsets.leadingAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.trailingAnchor.constraint(lessThanOrEqualTo: stackEdgeInsets.trailingAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)
                let c3 = view.centerXAnchor.constraint(equalTo: stackEdgeInsets.centerXAnchor, constant: offset)
                c3.hmItem.type = .center; c3.hmItem.view = view; constraints.append(c3)

            case .end:
                let c1 = view.leadingAnchor.constraint(greaterThanOrEqualTo: stackEdgeInsets.leadingAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.trailingAnchor.constraint(equalTo: stackEdgeInsets.trailingAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)

            case .fill:
                let c1 = view.leadingAnchor.constraint(equalTo: stackEdgeInsets.leadingAnchor, constant: startSpacing)
                c1.hmItem.type = .start; c1.hmItem.view = view; constraints.append(c1)
                let c2 = view.trailingAnchor.constraint(equalTo: stackEdgeInsets.trailingAnchor, constant: -endSpacing)
                c2.hmItem.type = .end; c2.hmItem.view = view; constraints.append(c2)
            }
        }
    }

    // MARK: - Helper

    private func makeGuide() -> HaomissyouLayoutGuide {
        let guide = HaomissyouLayoutGuide()
        guide.stackView = stackView
        return guide
    }
}
