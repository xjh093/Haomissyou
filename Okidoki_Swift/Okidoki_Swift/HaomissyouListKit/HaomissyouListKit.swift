//
//  HaomissyouListKit.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//

/*
 类型                          实现
 单 cell                       HaomissyouSingleSectionController
 多列固定高度                    HaomissyouFlowSectionController (columnCount > 1)
 多列动态高度（瀑布流）            HaomissyouWaterfallSectionController
 多种 Item 类型                 HaomissyouMultiItemSectionController + HaomissyouItemController
 */

/*
 ┌─────────────────────────────────────────────────────────────────────────────┐
 │  Core                                                                       │
 │    HaomissyouCollectionViewDataSource   数据源协议                            │
 │    HaomissyouSectionController          section 基类                         │
 │    HaomissyouCollectionView             核心 CollectionView                  │
 │    HaomissyouCollectionViewCell         基础 cell                            │
 │    HaomissyouSectionBackgroundView      section 背景 Decoration View         │
 │                                                                             │
 │  Controllers                                                                │
 │    HaomissyouSingleSectionController    单 cell section                     │
 │    HaomissyouFlowSectionController      多列固定高度                          │
 │    HaomissyouWaterfallSectionController 多列动态高度（瀑布流）                  │
 │    HaomissyouItemController             多 item 类型中单个 item 控制器         │
 │    HaomissyouMultiItemSectionController 多 item 类型 section                 │
 │                                                                             │
 │  Layout                                                                     │
 │    HaomissyouFlowLayout                 FlowLayout（支持 section 背景色）      │
 │    HaomissyouWaterfallLayout            瀑布流 Layout                        │
 └─────────────────────────────────────────────────────────────────────────────┘
 */

// MARK: - HaomissyouListKit namespace

import UIKit

/// 框架命名空间，集中存放全局常量。
public enum HaomissyouListKit {
    
    // MARK: - 元信息
    
    /// 框架版本号
    public static let version = "0.1.0"
    /// 发布日期
    public static let releaseDate = "2026-07-02 11:08:04"
    
    
    // MARK: - 全局默认配置
    // 在 AppDelegate / SceneDelegate 中统一设置一次，所有 SectionController 读取此值作为初始值。

    /// section 默认内边距，默认 .zero
    public static var defaultSectionInset: UIEdgeInsets = .zero

    /// 默认行间距（相邻两行 cell 的纵向间距），默认 0
    public static var defaultLineSpacing: CGFloat = 0

    /// 默认列间距（同行相邻 cell 的横向间距），默认 0
    public static var defaultInteritemSpacing: CGFloat = 0

    /// 默认 section 背景圆角半径，默认 0
    public static var defaultBackgroundCornerRadius: CGFloat = 0
}
