//
//  HaomissyouFlowSectionController.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//

import UIKit

/// 支持 UICollectionViewFlowLayout 的 SectionController。
/// 提供间距、边距、多列、Header/Footer 等布局配置。
open class HaomissyouFlowSectionController: HaomissyouSectionController {

    // MARK: - Layout Parameters

    /// section 的内边距，默认读取 HaomissyouListKit.defaultSectionInset
    public var sectionInset: UIEdgeInsets = HaomissyouListKit.defaultSectionInset

    /// 行间距（垂直方向相邻两行 cell 的间距），默认读取 HaomissyouListKit.defaultLineSpacing
    public var minimumLineSpacing: CGFloat = HaomissyouListKit.defaultLineSpacing

    /// 同行相邻 cell 的间距，默认读取 HaomissyouListKit.defaultInteritemSpacing
    public var minimumInteritemSpacing: CGFloat = HaomissyouListKit.defaultInteritemSpacing


    /// Header 高度，> 0 时才会请求 viewForHeader()，默认 0
    public var headerHeight: CGFloat = 0

    /// Footer 高度，> 0 时才会请求 viewForFooter()，默认 0
    public var footerHeight: CGFloat = 0

    /// 每行显示的列数，默认 1
    public var columnCount: Int = 1

    /// 根据 collectionView 宽度、sectionInset、minimumInteritemSpacing、columnCount 自动计算
    /// 注意：在 SectionController 初始化阶段 collectionView 尚未赋值，请在业务回调里使用
    public var columnWidth: CGFloat {
        let totalWidth = collectionView?.bounds.width ?? 0
        let columns = max(1, columnCount)
        return (totalWidth
            - sectionInset.left
            - sectionInset.right
            - CGFloat(columns - 1) * minimumInteritemSpacing
        ) / CGFloat(columns)
    }

    // MARK: - Section Background

    /// Section 背景色，nil 表示无背景，默认 nil
    public var sectionBackgroundColor: UIColor?

    /// Section 背景圆角半径，默认 0
    public var sectionBackgroundCornerRadius: CGFloat = 0

    /// Section 背景相对于 section geometry 的 inset（正数向内缩小，负数向外扩展），默认 .zero
    public var sectionBackgroundInset: NSDirectionalEdgeInsets = .zero

    // MARK: - Orthogonal Scrolling (Compositional Layout only)

    /// Section 内部横向滚动行为，默认 .none。
    /// 仅在 HaomissyouCollectionView.compositional(frame:) 中有效，FlowLayout / WaterfallLayout 忽略。
    @available(iOS 13.0, *)
    public var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
        get { (_orthogonalScrollingBehavior as? UICollectionLayoutSectionOrthogonalScrollingBehavior) ?? .none }
        set { _orthogonalScrollingBehavior = newValue }
    }
    private var _orthogonalScrollingBehavior: Any?

    // MARK: - Header / Footer

    /// 返回 header view，headerHeight > 0 时由框架调用，子类重写。
    open func viewForHeader() -> UICollectionReusableView? { nil }

    /// 返回 footer view，footerHeight > 0 时由框架调用，子类重写。
    open func viewForFooter() -> UICollectionReusableView? { nil }

    /// 内部供 HaomissyouCollectionView 调用，外部勿直接调用
    func viewForSupplementaryElement(ofKind kind: String, at index: Int) -> UICollectionReusableView? {
        if kind == UICollectionView.elementKindSectionHeader { return viewForHeader() }
        if kind == UICollectionView.elementKindSectionFooter { return viewForFooter() }
        return nil
    }

    // MARK: - Compositional Layout

    /// iOS 13+ Compositional Layout 高度方法。
    /// layoutSection(for:) 已由本类统一实现（读取 sectionInset/columnCount 等属性）。
    /// 子类只需覆写此方法返回选择的高度策略，默认为 .estimated(44)。
    /// 例：固定高度返回 .absolute(100)
    @available(iOS 13.0, *)
    open func itemHeightDimension(
        for environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutDimension {
        .estimated(44)
    }

    /// 统一实现：把 sectionInset/columnCount/minimumLineSpacing/minimumInteritemSpacing 转换为 Compositional Layout
    @available(iOS 13.0, *)
    open override func layoutSection(
        for environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        let containerWidth = environment.container.effectiveContentSize.width
        let columns = max(1, columnCount)
        let interItem = minimumInteritemSpacing
        let insetH = sectionInset.left + sectionInset.right
        let itemWidth = (containerWidth - insetH - CGFloat(columns - 1) * interItem) / CGFloat(columns)

        let heightDimension = itemHeightDimension(for: environment)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: heightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // group 宽度占满容器（去除左右 inset）
        // group 高度始终用 estimated，让 Compositional Layout 引擎自适应到行内最高的 cell
        let groupWidth = containerWidth - insetH
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(groupWidth),
            heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        if columns > 1 {
            group.interItemSpacing = .fixed(interItem)
        }

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: sectionInset.top,
            leading: sectionInset.left,
            bottom: sectionInset.bottom,
            trailing: sectionInset.right)
        section.interGroupSpacing = minimumLineSpacing

        // Section 背景：通过 NSCollectionLayoutDecorationItem 实现
        if sectionBackgroundColor != nil {
            let bg = NSCollectionLayoutDecorationItem.background(
                elementKind: kHaomissyouSectionBackgroundKind)
            bg.contentInsets = sectionBackgroundInset
            section.decorationItems = [bg]
        }

        // 横向滚动（仅 Compositional Layout 路径有效）
        section.orthogonalScrollingBehavior = orthogonalScrollingBehavior

        return section
    }
}
