//
//  HaomissyouLayoutGuide.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - Enums

public enum HaomissyouStackViewAxis {
    case horizontal  // 水平排列
    case vertical    // 垂直排列
}

public enum HaomissyouAlign: Int {
    case center = 0
    case start
    case end
    case fill
}

public enum HaomissyouJustify: Int {
    case fill = 0
    case fillEqually
    case start
    case center
    case end
    case spaceBetween  // 两边没有间距，中间相等
    case spaceAround   // 两边是中间一半
    case spaceEvenly   // 所有间距都相等
}

// MARK: - HaomissyouLayoutGuide

class HaomissyouLayoutGuide: UILayoutGuide {

    weak var stackView: UIView? {
        didSet {
            if let view = stackView {
                view.addLayoutGuide(self)
            }
        }
    }

    func removeFromOwningView() {
        owningView?.removeLayoutGuide(self)
    }
}
