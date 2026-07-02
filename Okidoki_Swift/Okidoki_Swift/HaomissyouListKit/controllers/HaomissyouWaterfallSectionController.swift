//
//  HaomissyouWaterfallSectionController.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
//  瀑布流 SectionController。配合 HaomissyouCollectionView.waterfall(frame:) 使用。
//
//  用法：
//    1. 创建 collectionView：let cv = HaomissyouCollectionView.waterfall(frame: ...)
//    2. 子类继承本类，设置 columnCount/sectionInset/minimumLineSpacing/minimumInteritemSpacing
//    3. 重写 heightForItem(at:width:) 返回 item 高度
//    4. 重写 cellForItem(at:) 返回 cell
//

import UIKit

open class HaomissyouWaterfallSectionController: HaomissyouFlowSectionController {

    /// 返回指定 index 的 item 高度。
    /// - Parameters:
    ///   - index: item 索引
    ///   - width: 由框架传入的 item 宽度（已根据 columnCount/sectionInset/columnSpacing 计算好）
    /// 子类必须重写此方法。
    open func heightForItem(at index: Int, width: CGFloat) -> CGFloat {
        assertionFailure("[HaomissyouListKit] \(type(of: self)) must override heightForItem(at:width:)")
        return 0
    }
}
