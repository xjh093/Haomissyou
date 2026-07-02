//
//  HaomissyouCollectionViewDataSource.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//

import UIKit

/// HaomissyouListKit 的数据源协议，提供 SectionControllers 和空视图。
public protocol HaomissyouCollectionViewDataSource: AnyObject {

    /// 返回当前 collectionView 的所有 SectionControllers
    func sectionControllers(for collectionView: HaomissyouCollectionView) -> [HaomissyouSectionController]

    /// 数据为空时显示的占位视图（可选）
    func emptyView(for collectionView: HaomissyouCollectionView) -> UIView?
}

public extension HaomissyouCollectionViewDataSource {
    func emptyView(for collectionView: HaomissyouCollectionView) -> UIView? { nil }
}
