//
//  HaomissyouWaterfallLayout.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
//  自定义瀑布流 Layout：每列高度独立推进，新 item 永远进入最短的列。
//  配合 HaomissyouWaterfallSectionController 和 HaomissyouCollectionView.waterfall(frame:) 使用。
//

import UIKit

// MARK: - HaomissyouWaterfallLayoutDelegate

public protocol HaomissyouWaterfallLayoutDelegate: AnyObject {

    /// 返回指定 item 的高度（宽度由 layout 传入，已扣除 inset 和列间距）
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         heightForItemAt indexPath: IndexPath,
                         itemWidth width: CGFloat) -> CGFloat

    /// 每个 section 的列数
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         columnCountForSection section: Int) -> Int

    /// section 的内边距
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         insetForSection section: Int) -> UIEdgeInsets

    /// 同列相邻 item 的纵向间距（行间距）
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         lineSpacingForSection section: Int) -> CGFloat

    /// 相邻列的横向间距（列间距）
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         columnSpacingForSection section: Int) -> CGFloat

    /// Section 背景色，nil 表示无背景（可选）
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         backgroundColorForSection section: Int) -> UIColor?

    /// Section 背景圆角半径，默认 0（可选）
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         backgroundCornerRadiusForSection section: Int) -> CGFloat

    /// Section 背景 inset（正数向内缩小，负数向外扩展），默认 .zero（可选）
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         backgroundInsetForSection section: Int) -> UIEdgeInsets
}

public extension HaomissyouWaterfallLayoutDelegate {
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         backgroundColorForSection section: Int) -> UIColor? { nil }
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         backgroundCornerRadiusForSection section: Int) -> CGFloat { 0 }
    func waterfallLayout(_ layout: HaomissyouWaterfallLayout,
                         backgroundInsetForSection section: Int) -> UIEdgeInsets { .zero }
}

// MARK: - HaomissyouWaterfallLayout

public final class HaomissyouWaterfallLayout: UICollectionViewLayout {

    public weak var delegate: HaomissyouWaterfallLayoutDelegate?

    // _itemAttributes[section][item]
    private var itemAttributes: [[UICollectionViewLayoutAttributes]] = []
    // nil entry = no background for that section
    private var sectionBackgroundAttrs: [UICollectionViewLayoutAttributes?] = []
    private var contentHeight: CGFloat = 0

    public override init() {
        super.init()
        register(HaomissyouSectionBackgroundView.self,
                 forDecorationViewOfKind: kHaomissyouSectionBackgroundKind)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    // MARK: - Core

    public override func prepare() {
        super.prepare()
        itemAttributes.removeAll()
        sectionBackgroundAttrs.removeAll()
        contentHeight = 0

        guard let cv = collectionView, let delegate else { return }

        let cvWidth = cv.bounds.width
        let sectionCount = cv.numberOfSections

        for s in 0 ..< sectionCount {
            let columns = max(1, delegate.waterfallLayout(self, columnCountForSection: s))
            let inset = delegate.waterfallLayout(self, insetForSection: s)
            let lineSpace = delegate.waterfallLayout(self, lineSpacingForSection: s)
            let colSpace = delegate.waterfallLayout(self, columnSpacingForSection: s)

            let itemWidth = (cvWidth - inset.left - inset.right - CGFloat(columns - 1) * colSpace)
                / CGFloat(columns)
            let sectionTop = contentHeight + inset.top

            // 每列当前高度（初始均为 sectionTop）
            var colHeights = [CGFloat](repeating: sectionTop, count: columns)

            let itemCount = cv.numberOfItems(inSection: s)
            var sectionAttrs = [UICollectionViewLayoutAttributes]()
            sectionAttrs.reserveCapacity(itemCount)

            for i in 0 ..< itemCount {
                // 找最短列
                var shortCol = 0
                var minH = colHeights[0]
                for c in 1 ..< columns {
                    if colHeights[c] < minH { minH = colHeights[c]; shortCol = c }
                }

                let ip = IndexPath(item: i, section: s)
                let itemH = delegate.waterfallLayout(self, heightForItemAt: ip, itemWidth: itemWidth)

                let curH = colHeights[shortCol]
                // 该列已放过 item 则加行间距，否则从 sectionTop 直接开始
                let yPos = curH <= sectionTop ? curH : curH + lineSpace
                let xPos = inset.left + CGFloat(shortCol) * (itemWidth + colSpace)

                let attrs = UICollectionViewLayoutAttributes(forCellWith: ip)
                attrs.frame = CGRect(x: xPos, y: yPos, width: itemWidth, height: itemH)
                sectionAttrs.append(attrs)

                colHeights[shortCol] = yPos + itemH
            }

            // section 底部 = 最高列 + bottom inset
            let maxH = colHeights.max() ?? sectionTop
            contentHeight = maxH + inset.bottom

            itemAttributes.append(sectionAttrs)

            // Section 背景
            if let bgColor = delegate.waterfallLayout(self, backgroundColorForSection: s) {
                let sectionStart = sectionTop - inset.top
                let radius = delegate.waterfallLayout(self, backgroundCornerRadiusForSection: s)
                let bgInset = delegate.waterfallLayout(self, backgroundInsetForSection: s)

                var bgFrame = CGRect(x: 0, y: sectionStart,
                                     width: cvWidth, height: contentHeight - sectionStart)
                if bgInset != .zero { bgFrame = bgFrame.inset(by: bgInset) }

                let bgAttr = HaomissyouSectionBackgroundAttributes(
                    forDecorationViewOfKind: kHaomissyouSectionBackgroundKind,
                    with: IndexPath(item: 0, section: s))
                bgAttr.frame = bgFrame
                bgAttr.zIndex = -1
                bgAttr.sectionBackgroundColor = bgColor
                bgAttr.sectionBackgroundCornerRadius = radius
                sectionBackgroundAttrs.append(bgAttr)
            } else {
                // 占位 nil，保持 index 与 section 对应
                sectionBackgroundAttrs.append(nil)
            }
        }
    }

    public override var collectionViewContentSize: CGSize {
        CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight)
    }

    public override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        for sectionAttrs in itemAttributes {
            for attrs in sectionAttrs where attrs.frame.intersects(rect) {
                result.append(attrs)
            }
        }
        for bgAttrs in sectionBackgroundAttrs {
            if let attrs = bgAttrs, attrs.frame.intersects(rect) {
                result.append(attrs)
            }
        }
        return result
    }

    public override func layoutAttributesForItem(
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < itemAttributes.count else { return nil }
        let sectionAttrs = itemAttributes[indexPath.section]
        guard indexPath.item < sectionAttrs.count else { return nil }
        return sectionAttrs[indexPath.item]
    }

    public override func layoutAttributesForDecorationView(
        ofKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard kind == kHaomissyouSectionBackgroundKind,
              indexPath.section < sectionBackgroundAttrs.count else { return nil }
        return sectionBackgroundAttrs[indexPath.section]
    }

    /// 宽度变化（旋转、分屏）时重新计算
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        newBounds.width != collectionView?.bounds.width
    }
}
