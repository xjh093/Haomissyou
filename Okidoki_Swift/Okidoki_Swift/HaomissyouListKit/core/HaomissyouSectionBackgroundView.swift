//
//  HaomissyouSectionBackgroundView.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
//  Section 背景 Decoration View。
//  配合 HaomissyouFlowLayout / HaomissyouWaterfallLayout / Compositional Layout 使用。
//

import UIKit

/// Decoration View 的 element kind 常量，三种布局统一使用。
public let kHaomissyouSectionBackgroundKind = "HaomissyouSectionBackground"

// MARK: - HaomissyouSectionBackgroundAttributes

/// UICollectionViewLayoutAttributes 子类，携带背景色和圆角半径。
/// Layout 在返回 decoration 的 attributes 时使用此类，
/// HaomissyouSectionBackgroundView.apply(_:) 读取并应用。
public final class HaomissyouSectionBackgroundAttributes: UICollectionViewLayoutAttributes {
    public var sectionBackgroundColor: UIColor?
    public var sectionBackgroundCornerRadius: CGFloat = 0

    public override func copy(with zone: NSZone? = nil) -> Any {
        // UICollectionViewLayoutAttributes 的 copy 在内部被调用，必须正确实现。
        let copy = super.copy(with: zone) as! HaomissyouSectionBackgroundAttributes
        copy.sectionBackgroundColor = sectionBackgroundColor
        copy.sectionBackgroundCornerRadius = sectionBackgroundCornerRadius
        return copy
    }
}

// MARK: - HaomissyouSectionBackgroundView

/// Section 背景 Decoration View。
/// 通过 apply(_:) 接收颜色与圆角，外部无需手动配置。
public final class HaomissyouSectionBackgroundView: UICollectionReusableView {

    public override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attrs = layoutAttributes as? HaomissyouSectionBackgroundAttributes else { return }
        backgroundColor = attrs.sectionBackgroundColor
        layer.cornerRadius = attrs.sectionBackgroundCornerRadius
        layer.masksToBounds = attrs.sectionBackgroundCornerRadius > 0
    }
}
