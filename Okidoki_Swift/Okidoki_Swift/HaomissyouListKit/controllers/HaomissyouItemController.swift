//
//  HaomissyouItemController.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
//  负责 HaomissyouMultiItemSectionController 中单个 item 的 cell 渲染与交互。
//  一个 ItemController 对应一种（或一组同类型）cell。
//
//  用法：
//    1. 继承本类，重写 cellForCollectionView(_:at:)
//    2. 按需重写 sizeForCollectionView(_:) 和 didSelectInCollectionView(_:)
//    3. 按需重写 didUpdate(to:) 接收由 SC 分发的数据
//

import UIKit

open class HaomissyouItemController: NSObject {

    // MARK: - Injected (read-only)

    /// 所属的 SectionController
    public internal(set) weak var sectionController: HaomissyouMultiItemSectionController?

    /// 在 section 内的 item 索引（等于在 itemControllers 数组中的下标）
    public internal(set) var itemIndex: Int = 0

    // MARK: - Subclass Overrides

    /// 返回 cell，子类必须重写。
    /// 在此方法中调用 dequeueReusableCell(_:at:) 来复用 cell。
    open func cellForCollectionView(
        _ cv: HaomissyouCollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        assertionFailure("[HaomissyouListKit] \(type(of: self)) must override cellForCollectionView(_:at:)")
        return UICollectionViewCell()
    }

    /// 返回 cell 尺寸，默认 .zero（配合 FlowLayout 使用时需重写）
    open func sizeForCollectionView(_ cv: HaomissyouCollectionView) -> CGSize { .zero }

    /// 点击回调，默认无操作
    open func didSelectInCollectionView(_ cv: HaomissyouCollectionView) {}

    /// 数据更新，由 HaomissyouMultiItemSectionController 在 didUpdate(to:) 中分发调用
    open func didUpdate(to object: Any?) {}

    // MARK: - Utilities

    /// 自动注册并 dequeue cell（内部转发给 HaomissyouCollectionView）
    public func dequeueReusableCell<T: UICollectionViewCell>(
        _ cellClass: T.Type,
        at indexPath: IndexPath
    ) -> T {
        sectionController!.collectionView!.dequeueReusableCell(cellClass, at: indexPath)
    }

    /// 当前列宽（= collectionView 宽 − sectionInset − 列间距）
    public var columnWidth: CGFloat {
        if let flowSC = sectionController as? HaomissyouFlowSectionController {
            return flowSC.columnWidth
        }
        return sectionController?.collectionView?.bounds.width ?? 0
    }

    /// 局部刷新当前 item 对应的 cell（单个 indexPath reload）
    public func reload() {
        guard let cv = sectionController?.collectionView,
              let section = sectionController?.section else { return }
        let ip = IndexPath(item: itemIndex, section: section)
        cv.performBatchUpdates({ cv.reloadItems(at: [ip]) })
    }
}
