//
//  HaomissyouCollectionViewCell.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//

import UIKit

/// HaomissyouListKit 基础 cell，子类继承后在 setupViews() 中布局。
///
/// 自动高度场景：
/// 1. 子类在 contentView 上建立完整的纵向约束链（顶部 → 内容 → 底部）
/// 2. 创建 HaomissyouCollectionView 时在 FlowLayout 设置：
///    flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
/// 3. sizeForItem(at:) 返回一个粗略估算值即可（如 CGSize(width: width, height: 44)）
/// 该类已重写 preferredLayoutAttributesFitting(_:)，无需子类处理。
open class HaomissyouCollectionViewCell: UICollectionViewCell {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    /// 子类重写：初始化并添加子视图（在 init 时自动调用，只调用一次）
    open func setupViews() {}

    /// 自动高度场景：让 Auto Layout 引擎计算真实尺寸并回写给布局系统
    open override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        let targetWidth = layoutAttributes.size.width

        // 关键：先把 cell frame 宽度设为目标值，否则 contentView 宽度不受约束，
        // layoutIfNeeded 会用错误的初始宽度展开，导致宽度溢出。
        var frame = self.frame
        frame.size.width = targetWidth
        self.frame = frame

        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()

        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        attributes.size = CGSize(width: targetWidth, height: size.height)
        return attributes
    }
}
