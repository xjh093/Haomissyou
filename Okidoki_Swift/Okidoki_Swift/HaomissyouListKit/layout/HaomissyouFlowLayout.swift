//
//  HaomissyouFlowLayout.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
//  UICollectionViewFlowLayout 子类，在标准 FlowLayout 布局基础上
//  支持 Section 背景色（通过 Decoration View 实现）。
//
//  用法：
//    1. HaomissyouCollectionView 默认已使用本类作为 FlowLayout 实例。
//    2. 在 HaomissyouFlowSectionController 上设置 sectionBackgroundColor 即可。
//

import UIKit

// MARK: - HaomissyouFlowLayoutBackgroundDelegate

/// HaomissyouFlowLayout 背景代理，由 HaomissyouCollectionView 实现。
public protocol HaomissyouFlowLayoutBackgroundDelegate: AnyObject {

    /// 返回指定 section 的背景色，nil 表示无背景。
    func collectionView(_ collectionView: UICollectionView,
                        backgroundColorForSection section: Int) -> UIColor?

    /// 返回指定 section 背景的圆角半径，默认 0。
    func collectionView(_ collectionView: UICollectionView,
                        backgroundCornerRadiusForSection section: Int) -> CGFloat

    /// 返回指定 section 背景的 inset（正数向内缩小，负数向外扩展），默认 .zero。
    func collectionView(_ collectionView: UICollectionView,
                        backgroundInsetForSection section: Int) -> UIEdgeInsets
}

public extension HaomissyouFlowLayoutBackgroundDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        backgroundCornerRadiusForSection section: Int) -> CGFloat { 0 }
    func collectionView(_ collectionView: UICollectionView,
                        backgroundInsetForSection section: Int) -> UIEdgeInsets { .zero }
}

// MARK: - HaomissyouFlowLayout

public final class HaomissyouFlowLayout: UICollectionViewFlowLayout {

    /// 由 HaomissyouCollectionView 在初始化时设为 self。
    public weak var backgroundDelegate: HaomissyouFlowLayoutBackgroundDelegate?

    /// section → CGRect 缓存，避免在 layoutAttributesForElements(in:) 中重复计算。
    /// prepare() / invalidateLayout() 时清除。
    private var sectionFrameCache: [Int: CGRect] = [:]

    public override init() {
        super.init()
        register(HaomissyouSectionBackgroundView.self,
                 forDecorationViewOfKind: kHaomissyouSectionBackgroundKind)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    // MARK: - Invalidation

    public override func prepare() {
        super.prepare()
        sectionFrameCache.removeAll()
    }

    public override func invalidateLayout() {
        super.invalidateLayout()
        sectionFrameCache.removeAll()
    }

    // MARK: - Core Overrides

    /// 在 super 返回的 cell/supplementary attributes 基础上，追加背景 Decoration 的 attributes。
    public override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        guard var attrs = super.layoutAttributesForElements(in: rect) else { return nil }
        guard backgroundDelegate != nil else { return attrs }

        // 收集本次 rect 内涉及的所有 section
        var sections = IndexSet()
        for a in attrs where a.representedElementCategory == .cell {
            sections.insert(a.indexPath.section)
        }

        for section in sections {
            guard let color = backgroundDelegate?.collectionView(
                collectionView!, backgroundColorForSection: section),
                  color != .clear else { continue }
            let ip = IndexPath(item: 0, section: section)
            if let bgAttr = layoutAttributesForDecorationView(
                ofKind: kHaomissyouSectionBackgroundKind, at: ip) {
                attrs.append(bgAttr)
            }
        }
        return attrs
    }

    /// 为 Decoration View 返回携带颜色信息的自定义 attributes。
    public override func layoutAttributesForDecorationView(
        ofKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard kind == kHaomissyouSectionBackgroundKind else {
            return super.layoutAttributesForDecorationView(ofKind: kind, at: indexPath)
        }
        guard let cv = collectionView,
              let delegate = backgroundDelegate else { return nil }

        guard let color = delegate.collectionView(cv, backgroundColorForSection: indexPath.section)
        else { return nil }

        let radius = delegate.collectionView(cv, backgroundCornerRadiusForSection: indexPath.section)
        let frame = backgroundFrame(for: indexPath.section)
        guard !frame.isEmpty else { return nil }

        let bgAttrs = HaomissyouSectionBackgroundAttributes(
            forDecorationViewOfKind: kind,
            with: indexPath)
        bgAttrs.frame = frame
        bgAttrs.zIndex = -1
        bgAttrs.sectionBackgroundColor = color
        bgAttrs.sectionBackgroundCornerRadius = radius
        return bgAttrs
    }

    // MARK: - Section Frame Calculation

    /// 计算 section 的背景区域。
    /// FlowLayout 的 section 结构：
    ///   [header] [inset.top] [cells] [inset.bottom] [footer]
    /// header/footer 在 sectionInset 外侧，因此：
    ///   - 有 header：背景顶 = header.top
    ///   - 无 header：背景顶 = firstCell.top - inset.top
    ///   - 有 footer：背景底 = footer.bottom
    ///   - 无 footer：背景底 = lastCell.bottom + inset.bottom
    /// 水平方向固定为 collectionView 全宽。
    private func backgroundFrame(for section: Int) -> CGRect {
        if let cached = sectionFrameCache[section] { return cached }
        guard let cv = collectionView else { return .zero }

        let ip0 = IndexPath(item: 0, section: section)

        // Header
        let header = layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader, at: ip0)
        let hasHeader = (header?.frame.height ?? 0) > 0

        // Footer
        let footer = layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter, at: ip0)
        let hasFooter = (footer?.frame.height ?? 0) > 0

        // 所有 cell 的 union rect
        let itemCount = cv.numberOfItems(inSection: section)
        var cellsFrame = CGRect.null
        for i in 0 ..< itemCount {
            if let a = layoutAttributesForItem(at: IndexPath(item: i, section: section)) {
                cellsFrame = cellsFrame.isNull ? a.frame : cellsFrame.union(a.frame)
            }
        }

        if !hasHeader && cellsFrame.isNull && !hasFooter {
            sectionFrameCache[section] = .zero
            return .zero
        }

        // 取 sectionInset（仅在无 header/footer 时用于扩展边界）
        var inset = UIEdgeInsets.zero
        if let flowDelegate = cv.delegate as? UICollectionViewDelegateFlowLayout {
            inset = flowDelegate.collectionView?(cv, layout: self, insetForSectionAt: section) ?? .zero
        }

        // 顶部
        let top: CGFloat
        if hasHeader, let headerFrame = header?.frame {
            top = headerFrame.minY
        } else if !cellsFrame.isNull {
            top = cellsFrame.minY - inset.top
        } else {
            top = footer!.frame.minY
        }

        // 底部
        let bottom: CGFloat
        if hasFooter, let footerFrame = footer?.frame {
            bottom = footerFrame.maxY
        } else if !cellsFrame.isNull {
            bottom = cellsFrame.maxY + inset.bottom
        } else {
            bottom = header!.frame.maxY
        }

        var result = CGRect(x: 0, y: top, width: cv.bounds.width, height: bottom - top)

        // 应用背景 inset（正数向内缩小，负数向外扩展）
        let bgInset = backgroundDelegate?.collectionView(cv, backgroundInsetForSection: section) ?? .zero
        if bgInset != .zero {
            result = result.inset(by: bgInset)
        }

        sectionFrameCache[section] = result
        return result
    }
}
