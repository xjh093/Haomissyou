//
//  HaomissyouMultiItemSectionController.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
//  一个 section 内包含多个不同类型 cell 的 SectionController。
//  每种 cell 由一个 HaomissyouItemController 子类负责，本类只做分发。
//
//  用法：
//    1. 继承本类，在 init() 中填充 itemControllers 数组
//    2. 重写 distributeObject(_:to:) 把数据按 IC 类型分发（可选）
//    3. 调用 reloadItemController(_:completion:) 可局部刷新单个 IC
//
//  示例：
//    override init() {
//        super.init()
//        sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
//        minimumLineSpacing = 8
//        itemControllers = [MyBannerIC(), MyTagsIC(), MyDescriptionIC()]
//    }
//
//    override func distributeObject(_ object: Any?, to itemController: HaomissyouItemController) {
//        if let ic = itemController as? MyBannerIC       { ic.didUpdate(to: model.banner) }
//        else if let ic = itemController as? MyTagsIC   { ic.didUpdate(to: model.tags) }
//    }
//

import UIKit

open class HaomissyouMultiItemSectionController: HaomissyouFlowSectionController {

    /// ItemController 列表，按 item 顺序排列。
    /// 赋值时框架自动注入 sectionController / itemIndex。
    public var itemControllers: [HaomissyouItemController] = [] {
        didSet {
            for (idx, ic) in itemControllers.enumerated() {
                ic.sectionController = self
                ic.itemIndex = idx
            }
        }
    }

    // MARK: - HaomissyouSectionController overrides

    open override func numberOfItems() -> Int { itemControllers.count }

    open override func cellForItem(at index: Int) -> UICollectionViewCell {
        let ic = itemControllers[index]
        let ip = IndexPath(item: index, section: section)
        return ic.cellForCollectionView(collectionView!, at: ip)
    }

    open override func sizeForItem(at index: Int) -> CGSize {
        itemControllers[index].sizeForCollectionView(collectionView!)
    }

    open override func didSelectItem(at index: Int) {
        itemControllers[index].didSelectInCollectionView(collectionView!)
    }

    /// 数据更新：逐个分发给每个 IC
    open override func didUpdate(to object: Any?) {
        itemControllers.forEach { distributeObject(object, to: $0) }
    }

    // MARK: - Data Distribution

    /// 数据分发钩子，在 didUpdate(to:) 中对每个 IC 调用一次。
    /// 默认把 object 原样传给每个 IC，子类重写以实现差异化分发。
    open func distributeObject(_ object: Any?, to itemController: HaomissyouItemController) {
        itemController.didUpdate(to: object)
    }

    // MARK: - Partial Reload

    /// 刷新指定 IC 对应的 cell（单个 indexPath，无动画）
    public func reloadItemController(_ ic: HaomissyouItemController) {
        reloadItemController(ic, completion: nil)
    }

    /// 刷新指定 IC 对应的 cell（带批量动画）
    public func reloadItemController(
        _ ic: HaomissyouItemController,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let idx = itemControllers.firstIndex(of: ic) else {
            completion?(false)
            return
        }
        let ip = IndexPath(item: idx, section: section)
        collectionView?.performBatchUpdates(
            { self.collectionView?.reloadItems(at: [ip]) },
            completion: completion)
    }
}
