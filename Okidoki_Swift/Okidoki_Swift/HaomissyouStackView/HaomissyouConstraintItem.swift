//
//  HaomissyouConstraintItem.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit
import ObjectiveC

// MARK: - HaomissyouLayoutConType

/// 约束的语义类型，用于后续精准查找和动态修改特定约束。
///
/// `HaomissyouFlexManager` 生成约束时，通过 `constraint.hmItem.type` 打标签。
/// `HaomissyouBaseStackView` 的动态更新方法（如 `setCustomSpacing`）依赖此标签
/// 找到目标约束直接修改 `constant`，避免整体重建所有约束。
enum HaomissyouLayoutConType: Int {
    case start       // 交叉轴起始端约束（top / leading）
    case end         // 交叉轴末端约束（bottom / trailing）
    case center      // 交叉轴居中约束（centerY / centerX）
    case top
    case bottom
    case leading
    case trailing
    case spacing     // 固定间距约束
    case minSpacing  // 最小间距约束
    case maxSpacing  // 最大间距约束
}

// MARK: - HaomissyouConstraintItem

/// 附加在 `NSLayoutConstraint` 上的元数据对象。
///
/// ## 设计原理
/// AutoLayout 约束本身没有"标识符"语义，无法区分"这条约束是视图 A 后面的 spacing"
/// 还是"视图 B 的 minSpacing"。`HaomissyouConstraintItem` 通过 Associated Object
/// 附加在每条约束上，记录两个信息：
///
/// - `type`：约束的语义类型（间距 / 对齐 / 居中等）
/// - `view`：约束所归属的子视图（weak 引用，避免循环）
///
/// 这样 StackView 在需要动态调整某个视图的间距时，只需遍历 `constraints` 数组，
/// 过滤 `hmItem.view === targetView && hmItem.type == .spacing`，即可精准定位。
final class HaomissyouConstraintItem: NSObject {
    var type: HaomissyouLayoutConType = .start
    weak var view: UIView?
}

// MARK: - NSLayoutConstraint Extension

private var _hmConstraintItemKey: UInt8 = 0

/// 为每条 `NSLayoutConstraint` 提供懒加载的 `HaomissyouConstraintItem` 元数据。
extension NSLayoutConstraint {
    var hmItem: HaomissyouConstraintItem {
        if let item = objc_getAssociatedObject(self, &_hmConstraintItemKey) as? HaomissyouConstraintItem {
            return item
        }
        let item = HaomissyouConstraintItem()
        objc_setAssociatedObject(self, &_hmConstraintItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return item
    }
}
