//
//  HaomissyouSectionController.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//

import UIKit

/// SectionController 基类，每个实例对应 UICollectionView 中的一个 section。
/// 子类重写业务方法即可，无需调用 super。
open class HaomissyouSectionController: NSObject {

    /// 当前所在的 collectionView，由 HaomissyouCollectionView 自动注入，勿手动赋值
    public internal(set) weak var collectionView: HaomissyouCollectionView?
    /// 宿主 ViewController，由 HaomissyouCollectionView 自动注入，勿手动赋值
    public internal(set) weak var viewController: UIViewController?
    /// 当前 section 索引，由 HaomissyouCollectionView 自动注入，勿手动赋值
    public internal(set) var section: Int = 0

    // MARK: - Subclass Overrides

    /// section 内的 item 数量，默认 1
    open func numberOfItems() -> Int { 1 }

    /// 返回指定 index 的 cell，子类必须重写
    open func cellForItem(at index: Int) -> UICollectionViewCell {
        assertionFailure("[HaomissyouListKit] \(type(of: self)) must override cellForItem(at:)")
        return UICollectionViewCell()
    }

    /// 返回指定 index 的 cell 尺寸，默认 .zero
    open func sizeForItem(at index: Int) -> CGSize { .zero }

    /// 点击回调
    open func didSelectItem(at index: Int) {}

    /// 数据更新时由外部调用（调用 reloadData 前手动调用），子类重写以接收数据
    open func didUpdate(to object: Any?) {}

    // MARK: - Utilities

    /// 局部刷新本 section（无动画）
    public func reload() {
        collectionView?.reloadSectionController(self, animated: false, completion: nil)
    }

    /// 局部刷新本 section（带批量动画）
    public func reload(completion: ((Bool) -> Void)? = nil) {
        collectionView?.reloadSectionController(self, animated: true, completion: completion)
    }

    /// 在 cellForItem(at:) 内使用，自动注册并 dequeue cell
    public func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, at index: Int) -> T {
        let indexPath = IndexPath(item: index, section: section)
        return collectionView!.dequeueReusableCell(cellClass, at: indexPath)
    }

    /// 在 viewForHeader/viewForFooter 内使用，自动注册并 dequeue supplementary view
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        _ viewClass: T.Type,
        kind: String,
        at index: Int
    ) -> T {
        let indexPath = IndexPath(item: index, section: section)
        return collectionView!.dequeueReusableSupplementaryView(viewClass, kind: kind, at: indexPath)
    }

    /// iOS 13+：返回该 section 的 Compositional Layout 描述。
    /// 与 HaomissyouCollectionView.compositional(frame:) 配合使用。
    /// 默认返回单列、estimated 高度的基础 section，子类按需重写。
    @available(iOS 13.0, *)
    open func layoutSection(for environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        return NSCollectionLayoutSection(group: group)
    }
}
