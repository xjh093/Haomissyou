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

enum HaomissyouLayoutConType: Int {
    case start
    case end
    case center
    case top
    case bottom
    case leading
    case trailing
    case spacing
    case minSpacing
    case maxSpacing
}

// MARK: - HaomissyouConstraintItem

final class HaomissyouConstraintItem: NSObject {
    var type: HaomissyouLayoutConType = .start
    weak var view: UIView?
}

// MARK: - NSLayoutConstraint Extension

private var _hmConstraintItemKey: UInt8 = 0

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
