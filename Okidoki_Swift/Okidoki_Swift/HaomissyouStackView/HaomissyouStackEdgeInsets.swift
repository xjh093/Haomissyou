//
//  HaomissyouStackEdgeInsets.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - Private Guide Subclasses

private final class _HMTopGuide: HaomissyouLayoutGuide {}
private final class _HMLeadingGuide: HaomissyouLayoutGuide {}
private final class _HMBottomGuide: HaomissyouLayoutGuide {}
private final class _HMTrailingGuide: HaomissyouLayoutGuide {}

// MARK: - HaomissyouMargeGuide

/// 承载 `UIEdgeInsets` 的布局 Guide，作为 StackView 内容区域的逻辑边界。
///
/// ## 设计原理
/// StackView 的 `insets` 属性（内边距）不直接修改视图的 `layoutMargins`，
/// 而是在 StackView 内部创建一个 `HaomissyouMargeGuide`，其四条边分别通过
/// 约束与 StackView 的四条边保持偏移（即 insets 值）。
///
/// 所有子视图约束的锚点都连到这个 Guide 上，而不是直接连 StackView 本身。
/// 这样修改 `insets` 时只需更新四条约束的 `constant`，无需重建全部子视图约束。
final class HaomissyouMargeGuide: UILayoutGuide {

    weak var top: NSLayoutConstraint?
    weak var leading: NSLayoutConstraint?
    weak var bottom: NSLayoutConstraint?
    weak var trailing: NSLayoutConstraint?

    convenience init(view: UIView, insets: UIEdgeInsets) {
        self.init()
        view.addLayoutGuide(self)
        let topCons   = topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top)
        let leadCons  = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left)
        let botCons   = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        let trailCons = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right)
        NSLayoutConstraint.activate([topCons, leadCons, botCons, trailCons])
        self.top      = topCons
        self.leading  = leadCons
        self.bottom   = botCons
        self.trailing = trailCons
    }
}

// MARK: - HaomissyouStackEdgeInsets

/// 为 `HaomissyouFlexManager` 提供所有约束锚点的统一入口。
///
/// ## 职责
/// 这个类是约束生成层与视图层之间的**锚点适配器**，屏蔽了以下复杂性：
///
/// ### 1. insets 内边距
/// 通过懒加载的 `HaomissyouMargeGuide` 提供偏移后的四边锚点（`topAnchor` /
/// `leadingAnchor` / `bottomAnchor` / `trailingAnchor`），子视图的交叉轴
/// 约束全部连到这个 Guide，而非 StackView 本身。
///
/// ### 2. justify 感知的主轴起止锚点（jLeadingAnchor / jTrailingAnchor 等）
/// 对于需要两端对称 Guide 的 justify 模式（`center` / `spaceAround` /
/// `spaceEvenly`），主轴的起始锚点不是 `margeGuide.leadingAnchor`，
/// 而是一个懒加载的侧边 Guide 的内侧边缘（`leadingGuide.trailingAnchor`）。
/// 这样侧边 Guide 的宽度就自然等于视图链起始端到边界的距离，
/// 可以通过 `widthAnchors[0] == widthAnchors[1]` 实现两端对称。
///
/// ### 3. 对称 Guide 的尺寸锚点
/// `widthAnchors` / `heightAnchors` 分别返回两端 Guide 的尺寸 Dimension，
/// 供 `HaomissyouFlexManager` 在循环后添加对称约束使用。
///
/// ## 懒加载设计
/// 四个侧边 Guide（_topGuide / _leadingGuide / _bottomGuide / _trailingGuide）
/// 只在对应 justify 模式下才会被访问和创建，避免不必要的 Guide 对象。
final class HaomissyouStackEdgeInsets: NSObject {

    weak var stackView: HaomissyouBaseStackView?

    private var _topGuide: _HMTopGuide?
    private var _leadingGuide: _HMLeadingGuide?
    private var _bottomGuide: _HMBottomGuide?
    private var _trailingGuide: _HMTrailingGuide?
    private var _margeGuide: HaomissyouMargeGuide?

    var insets: UIEdgeInsets = .zero {
        didSet {
            guard let mg = _margeGuide, insets != oldValue else { return }
            mg.top?.constant      = insets.top
            mg.leading?.constant  = insets.left
            mg.bottom?.constant   = -insets.bottom
            mg.trailing?.constant = -insets.right
        }
    }

    // MARK: Justify-aware anchors

    var jLeadingAnchor: NSLayoutXAxisAnchor {
        guard let sv = stackView else { return margeGuide.leadingAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return leadingGuide.trailingAnchor
        default:
            return margeGuide.leadingAnchor
        }
    }

    var jTrailingAnchor: NSLayoutXAxisAnchor {
        guard let sv = stackView else { return margeGuide.trailingAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return trailingGuide.leadingAnchor
        default:
            return margeGuide.trailingAnchor
        }
    }

    var jTopAnchor: NSLayoutYAxisAnchor {
        guard let sv = stackView else { return margeGuide.topAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return topGuide.bottomAnchor
        default:
            return margeGuide.topAnchor
        }
    }

    var jBottomAnchor: NSLayoutYAxisAnchor {
        guard let sv = stackView else { return margeGuide.bottomAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return bottomGuide.topAnchor
        default:
            return margeGuide.bottomAnchor
        }
    }

    // MARK: Edge anchors

    var leadingAnchor:  NSLayoutXAxisAnchor { margeGuide.leadingAnchor  }
    var trailingAnchor: NSLayoutXAxisAnchor { margeGuide.trailingAnchor }
    var topAnchor:      NSLayoutYAxisAnchor { margeGuide.topAnchor      }
    var bottomAnchor:   NSLayoutYAxisAnchor { margeGuide.bottomAnchor   }
    var centerYAnchor:  NSLayoutYAxisAnchor { margeGuide.centerYAnchor  }
    var centerXAnchor:  NSLayoutXAxisAnchor { margeGuide.centerXAnchor  }

    var widthAnchors: [NSLayoutDimension] {
        [leadingGuide.widthAnchor, trailingGuide.widthAnchor]
    }

    var heightAnchors: [NSLayoutDimension] {
        [topGuide.heightAnchor, bottomGuide.heightAnchor]
    }

    // MARK: Cleanup

    func removeEdgeInsets() {
        _leadingGuide?.removeFromOwningView();  _leadingGuide  = nil
        _trailingGuide?.removeFromOwningView(); _trailingGuide = nil
        _topGuide?.removeFromOwningView();      _topGuide      = nil
        _bottomGuide?.removeFromOwningView();   _bottomGuide   = nil
    }

    // MARK: Lazy guides

    private var topGuide: _HMTopGuide {
        if let g = _topGuide { return g }
        let g = _HMTopGuide()
        stackView?.addLayoutGuide(g)
        g.topAnchor.constraint(equalTo: margeGuide.topAnchor).isActive = true
        _topGuide = g
        return g
    }

    private var leadingGuide: _HMLeadingGuide {
        if let g = _leadingGuide { return g }
        let g = _HMLeadingGuide()
        stackView?.addLayoutGuide(g)
        g.leadingAnchor.constraint(equalTo: margeGuide.leadingAnchor).isActive = true
        _leadingGuide = g
        return g
    }

    private var bottomGuide: _HMBottomGuide {
        if let g = _bottomGuide { return g }
        let g = _HMBottomGuide()
        stackView?.addLayoutGuide(g)
        g.bottomAnchor.constraint(equalTo: margeGuide.bottomAnchor).isActive = true
        _bottomGuide = g
        return g
    }

    private var trailingGuide: _HMTrailingGuide {
        if let g = _trailingGuide { return g }
        let g = _HMTrailingGuide()
        stackView?.addLayoutGuide(g)
        margeGuide.trailingAnchor.constraint(equalTo: g.trailingAnchor).isActive = true
        _trailingGuide = g
        return g
    }

    var margeGuide: HaomissyouMargeGuide {
        if let g = _margeGuide { return g }
        guard let sv = stackView else {
            // stackView 已释放，返回一个无 owner 的安全占位 Guide，避免崩溃
            let g = HaomissyouMargeGuide()
            _margeGuide = g
            return g
        }
        let g = HaomissyouMargeGuide(view: sv, insets: sv.insets)
        _margeGuide = g
        return g
    }
}
