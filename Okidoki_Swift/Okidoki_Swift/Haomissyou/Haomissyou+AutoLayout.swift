//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-24
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - Constraint Identifier Constants

public let kHaomissyouConstraintLeading    = "haomissyou_leading"
public let kHaomissyouConstraintLeadingGTE = "haomissyou_leading_gte"
public let kHaomissyouConstraintLeadingLTE = "haomissyou_leading_lte"

public let kHaomissyouConstraintTrailing    = "haomissyou_trailing"
public let kHaomissyouConstraintTrailingGTE = "haomissyou_trailing_gte"
public let kHaomissyouConstraintTrailingLTE = "haomissyou_trailing_lte"

public let kHaomissyouConstraintLeft    = "haomissyou_left"
public let kHaomissyouConstraintLeftGTE = "haomissyou_left_gte"
public let kHaomissyouConstraintLeftLTE = "haomissyou_left_lte"

public let kHaomissyouConstraintRight    = "haomissyou_right"
public let kHaomissyouConstraintRightGTE = "haomissyou_right_gte"
public let kHaomissyouConstraintRightLTE = "haomissyou_right_lte"

public let kHaomissyouConstraintTop    = "haomissyou_top"
public let kHaomissyouConstraintTopGTE = "haomissyou_top_gte"
public let kHaomissyouConstraintTopLTE = "haomissyou_top_lte"

public let kHaomissyouConstraintBottom    = "haomissyou_bottom"
public let kHaomissyouConstraintBottomGTE = "haomissyou_bottom_gte"
public let kHaomissyouConstraintBottomLTE = "haomissyou_bottom_lte"

public let kHaomissyouConstraintWidth    = "haomissyou_width"
public let kHaomissyouConstraintWidthGTE = "haomissyou_width_gte"
public let kHaomissyouConstraintWidthLTE = "haomissyou_width_lte"

public let kHaomissyouConstraintHeight    = "haomissyou_height"
public let kHaomissyouConstraintHeightGTE = "haomissyou_height_gte"
public let kHaomissyouConstraintHeightLTE = "haomissyou_height_lte"

public let kHaomissyouConstraintCenterX    = "haomissyou_centerX"
public let kHaomissyouConstraintCenterXGTE = "haomissyou_centerX_gte"
public let kHaomissyouConstraintCenterXLTE = "haomissyou_centerX_lte"

public let kHaomissyouConstraintCenterY    = "haomissyou_centerY"
public let kHaomissyouConstraintCenterYGTE = "haomissyou_centerY_gte"
public let kHaomissyouConstraintCenterYLTE = "haomissyou_centerY_lte"

// MARK: - Private Helpers

extension Haomissyou {

    /// Activate or queue (batch mode) a constraint.
    func _activateConstraint(_ constraint: NSLayoutConstraint) {
        if _batchDepth > 0 {
            // Remove existing constraint with the same identifier to avoid conflicts
            if let id = constraint.identifier {
                _batchConstraints.removeAll { $0.identifier == id }
            }
            _batchConstraints.append(constraint)
        } else {
            constraint.isActive = true
        }
    }

    /// X-axis anchor helper (leading / trailing / left / right / centerX / centerY… wait, centerX is X).
    /// params: [toView/toAnchor, constant?]
    @discardableResult
    func _x(
        my: NSLayoutXAxisAnchor,
        params: Any,
        viewAnchor: (UIView) -> NSLayoutXAxisAnchor,
        id: String,
        rel: NSLayoutConstraint.Relation = .equal
    ) -> Haomissyou {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // 支持裸 UIView / 裸 NSLayoutXAxisAnchor（constant = 0）
        if let v = params as? UIView {
            let con: NSLayoutConstraint
            switch rel {
            case .equal:              con = my.constraint(equalTo: viewAnchor(v), constant: 0)
            case .greaterThanOrEqual: con = my.constraint(greaterThanOrEqualTo: viewAnchor(v), constant: 0)
            default:                  con = my.constraint(lessThanOrEqualTo: viewAnchor(v), constant: 0)
            }
            con.identifier = id; _activateConstraint(con); return self
        }
        if let a = params as? NSLayoutXAxisAnchor {
            let con: NSLayoutConstraint
            switch rel {
            case .equal:              con = my.constraint(equalTo: a, constant: 0)
            case .greaterThanOrEqual: con = my.constraint(greaterThanOrEqualTo: a, constant: 0)
            default:                  con = my.constraint(lessThanOrEqualTo: a, constant: 0)
            }
            con.identifier = id; _activateConstraint(con); return self
        }

        guard let arr = params as? [Any], !arr.isEmpty else { return self }
        let toItem = arr[0]
        let constant = arr.count > 1 ? CGFloat((arr[1] as? NSNumber)?.doubleValue ?? 0) : 0

        let toAnchor: NSLayoutXAxisAnchor
        if let v = toItem as? UIView { toAnchor = viewAnchor(v) }
        else if let a = toItem as? NSLayoutXAxisAnchor { toAnchor = a }
        else { return self }

        let con: NSLayoutConstraint
        switch rel {
        case .equal:              con = my.constraint(equalTo: toAnchor, constant: constant)
        case .greaterThanOrEqual: con = my.constraint(greaterThanOrEqualTo: toAnchor, constant: constant)
        default:                  con = my.constraint(lessThanOrEqualTo: toAnchor, constant: constant)
        }
        con.identifier = id
        _activateConstraint(con)
        return self
    }

    /// Y-axis anchor helper (top / bottom / centerY).
    @discardableResult
    func _y(
        my: NSLayoutYAxisAnchor,
        params: Any,
        viewAnchor: (UIView) -> NSLayoutYAxisAnchor,
        id: String,
        rel: NSLayoutConstraint.Relation = .equal
    ) -> Haomissyou {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // 支持裸 UIView / 裸 NSLayoutYAxisAnchor（constant = 0）
        if let v = params as? UIView {
            let con: NSLayoutConstraint
            switch rel {
            case .equal:              con = my.constraint(equalTo: viewAnchor(v), constant: 0)
            case .greaterThanOrEqual: con = my.constraint(greaterThanOrEqualTo: viewAnchor(v), constant: 0)
            default:                  con = my.constraint(lessThanOrEqualTo: viewAnchor(v), constant: 0)
            }
            con.identifier = id; _activateConstraint(con); return self
        }
        if let a = params as? NSLayoutYAxisAnchor {
            let con: NSLayoutConstraint
            switch rel {
            case .equal:              con = my.constraint(equalTo: a, constant: 0)
            case .greaterThanOrEqual: con = my.constraint(greaterThanOrEqualTo: a, constant: 0)
            default:                  con = my.constraint(lessThanOrEqualTo: a, constant: 0)
            }
            con.identifier = id; _activateConstraint(con); return self
        }

        guard let arr = params as? [Any], !arr.isEmpty else { return self }
        let toItem = arr[0]
        let constant = arr.count > 1 ? CGFloat((arr[1] as? NSNumber)?.doubleValue ?? 0) : 0

        let toAnchor: NSLayoutYAxisAnchor
        if let v = toItem as? UIView { toAnchor = viewAnchor(v) }
        else if let a = toItem as? NSLayoutYAxisAnchor { toAnchor = a }
        else { return self }

        let con: NSLayoutConstraint
        switch rel {
        case .equal:              con = my.constraint(equalTo: toAnchor, constant: constant)
        case .greaterThanOrEqual: con = my.constraint(greaterThanOrEqualTo: toAnchor, constant: constant)
        default:                  con = my.constraint(lessThanOrEqualTo: toAnchor, constant: constant)
        }
        con.identifier = id
        _activateConstraint(con)
        return self
    }

    /// Dimension anchor helper (width / height).
    /// params: NSNumber (constant) or [toView/toAnchor, multiplier?, constant?]
    /// GTE/LTE also accept [NSNumber] array (array-wrapped constant).
    @discardableResult
    func _dim(
        my: NSLayoutDimension,
        params: Any,
        viewAnchor: (UIView) -> NSLayoutDimension,
        id: String,
        rel: NSLayoutConstraint.Relation = .equal
    ) -> Haomissyou {
        view.translatesAutoresizingMaskIntoConstraints = false

        func makeConst(_ c: CGFloat) -> NSLayoutConstraint {
            switch rel {
            case .equal:              return my.constraint(equalToConstant: c)
            case .greaterThanOrEqual: return my.constraint(greaterThanOrEqualToConstant: c)
            default:                  return my.constraint(lessThanOrEqualToConstant: c)
            }
        }

        func makeRelative(_ anchor: NSLayoutDimension, mult: CGFloat, c: CGFloat) -> NSLayoutConstraint {
            switch rel {
            case .equal:              return my.constraint(equalTo: anchor, multiplier: mult, constant: c)
            case .greaterThanOrEqual: return my.constraint(greaterThanOrEqualTo: anchor, multiplier: mult, constant: c)
            default:                  return my.constraint(lessThanOrEqualTo: anchor, multiplier: mult, constant: c)
            }
        }

        if let n = params as? NSNumber {
            let con = makeConst(CGFloat(n.doubleValue))
            con.identifier = id
            _activateConstraint(con)
        } else if let v = params as? UIView {
            // 裸 UIView — 等价于 [view, 1.0, 0]
            let con = makeRelative(viewAnchor(v), mult: 1.0, c: 0)
            con.identifier = id
            _activateConstraint(con)
        } else if let a = params as? NSLayoutDimension {
            // 裸 NSLayoutDimension — 等价于 [anchor, 1.0, 0]
            let con = makeRelative(a, mult: 1.0, c: 0)
            con.identifier = id
            _activateConstraint(con)
        } else if let arr = params as? [Any], !arr.isEmpty {
            let first = arr[0]
            if let n = first as? NSNumber {
                // [NSNumber] — array-wrapped constant (used in GTE/LTE variants)
                let con = makeConst(CGFloat(n.doubleValue))
                con.identifier = id
                _activateConstraint(con)
            } else {
                let mult = arr.count > 1 ? CGFloat((arr[1] as? NSNumber)?.doubleValue ?? 1.0) : 1.0
                let c    = arr.count > 2 ? CGFloat((arr[2] as? NSNumber)?.doubleValue ?? 0)   : 0

                let toAnchor: NSLayoutDimension
                if let v = first as? UIView { toAnchor = viewAnchor(v) }
                else if let a = first as? NSLayoutDimension { toAnchor = a }
                else { return self }

                let con = makeRelative(toAnchor, mult: mult, c: c)
                con.identifier = id
                _activateConstraint(con)
            }
        }
        return self
    }
}

// MARK: - AutoLayout

public extension Haomissyou {

    // MARK: Leading

    /// Leading 等于约束。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.leadingAnchor([superview, 16])
    /// view.haomissyou.leadingAnchor([siblingView.trailingAnchor, 8])
    /// ```
    @discardableResult
    func leadingAnchor(_ params: Any) -> Haomissyou {
        _x(my: view.leadingAnchor, params: params, viewAnchor: { $0.leadingAnchor },
           id: kHaomissyouConstraintLeading)
    }

    /// Leading 大于等于约束。`params` 格式同 `leadingAnchor`。
    @discardableResult
    func leadingAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.leadingAnchor, params: params, viewAnchor: { $0.leadingAnchor },
           id: kHaomissyouConstraintLeadingGTE, rel: .greaterThanOrEqual)
    }

    /// Leading 小于等于约束。`params` 格式同 `leadingAnchor`。
    @discardableResult
    func leadingAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.leadingAnchor, params: params, viewAnchor: { $0.leadingAnchor },
           id: kHaomissyouConstraintLeadingLTE, rel: .lessThanOrEqual)
    }

    // MARK: Trailing

    /// Trailing 等于约束。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.trailingAnchor([superview, -16])
    /// view.haomissyou.trailingAnchor([siblingView.leadingAnchor, -8])
    /// ```
    @discardableResult
    func trailingAnchor(_ params: Any) -> Haomissyou {
        _x(my: view.trailingAnchor, params: params, viewAnchor: { $0.trailingAnchor },
           id: kHaomissyouConstraintTrailing)
    }

    /// Trailing 大于等于约束。`params` 格式同 `trailingAnchor`。
    @discardableResult
    func trailingAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.trailingAnchor, params: params, viewAnchor: { $0.trailingAnchor },
           id: kHaomissyouConstraintTrailingGTE, rel: .greaterThanOrEqual)
    }

    /// Trailing 小于等于约束。`params` 格式同 `trailingAnchor`。
    @discardableResult
    func trailingAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.trailingAnchor, params: params, viewAnchor: { $0.trailingAnchor },
           id: kHaomissyouConstraintTrailingLTE, rel: .lessThanOrEqual)
    }

    // MARK: Left

    /// Left 等于约束（绝对方向，不随 RTL 翻转）。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.leftAnchor([superview, 16])
    /// ```
    @discardableResult
    func leftAnchor(_ params: Any) -> Haomissyou {
        _x(my: view.leftAnchor, params: params, viewAnchor: { $0.leftAnchor },
           id: kHaomissyouConstraintLeft)
    }

    /// Left 大于等于约束。`params` 格式同 `leftAnchor`。
    @discardableResult
    func leftAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.leftAnchor, params: params, viewAnchor: { $0.leftAnchor },
           id: kHaomissyouConstraintLeftGTE, rel: .greaterThanOrEqual)
    }

    /// Left 小于等于约束。`params` 格式同 `leftAnchor`。
    @discardableResult
    func leftAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.leftAnchor, params: params, viewAnchor: { $0.leftAnchor },
           id: kHaomissyouConstraintLeftLTE, rel: .lessThanOrEqual)
    }

    // MARK: Right

    /// Right 等于约束（绝对方向，不随 RTL 翻转）。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.rightAnchor([superview, -16])
    /// ```
    @discardableResult
    func rightAnchor(_ params: Any) -> Haomissyou {
        _x(my: view.rightAnchor, params: params, viewAnchor: { $0.rightAnchor },
           id: kHaomissyouConstraintRight)
    }

    /// Right 大于等于约束。`params` 格式同 `rightAnchor`。
    @discardableResult
    func rightAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.rightAnchor, params: params, viewAnchor: { $0.rightAnchor },
           id: kHaomissyouConstraintRightGTE, rel: .greaterThanOrEqual)
    }

    /// Right 小于等于约束。`params` 格式同 `rightAnchor`。
    @discardableResult
    func rightAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.rightAnchor, params: params, viewAnchor: { $0.rightAnchor },
           id: kHaomissyouConstraintRightLTE, rel: .lessThanOrEqual)
    }

    // MARK: Top

    /// Top 等于约束。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.topAnchor([superview, 20])
    /// view.haomissyou.topAnchor([headerView.bottomAnchor, 8])
    /// ```
    @discardableResult
    func topAnchor(_ params: Any) -> Haomissyou {
        _y(my: view.topAnchor, params: params, viewAnchor: { $0.topAnchor },
           id: kHaomissyouConstraintTop)
    }

    /// Top 大于等于约束。`params` 格式同 `topAnchor`。
    @discardableResult
    func topAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _y(my: view.topAnchor, params: params, viewAnchor: { $0.topAnchor },
           id: kHaomissyouConstraintTopGTE, rel: .greaterThanOrEqual)
    }

    /// Top 小于等于约束。`params` 格式同 `topAnchor`。
    @discardableResult
    func topAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _y(my: view.topAnchor, params: params, viewAnchor: { $0.topAnchor },
           id: kHaomissyouConstraintTopLTE, rel: .lessThanOrEqual)
    }

    // MARK: Bottom

    /// Bottom 等于约束。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.bottomAnchor([superview, -20])
    /// view.haomissyou.bottomAnchor([footerView.topAnchor, -8])
    /// ```
    @discardableResult
    func bottomAnchor(_ params: Any) -> Haomissyou {
        _y(my: view.bottomAnchor, params: params, viewAnchor: { $0.bottomAnchor },
           id: kHaomissyouConstraintBottom)
    }

    /// Bottom 大于等于约束。`params` 格式同 `bottomAnchor`。
    @discardableResult
    func bottomAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _y(my: view.bottomAnchor, params: params, viewAnchor: { $0.bottomAnchor },
           id: kHaomissyouConstraintBottomGTE, rel: .greaterThanOrEqual)
    }

    /// Bottom 小于等于约束。`params` 格式同 `bottomAnchor`。
    @discardableResult
    func bottomAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _y(my: view.bottomAnchor, params: params, viewAnchor: { $0.bottomAnchor },
           id: kHaomissyouConstraintBottomLTE, rel: .lessThanOrEqual)
    }

    // MARK: Width

    /// 宽度约束。
    /// - params:
    ///   - `NSNumber`：固定宽度。`view.haomissyou.widthAnchor(100)`
    ///   - `[toView, multiplier?, constant?]`：相对宽度。`view.haomissyou.widthAnchor([superview, 0.5, -20])`
    @discardableResult
    func widthAnchor(_ params: Any) -> Haomissyou {
        _dim(my: view.widthAnchor, params: params, viewAnchor: { $0.widthAnchor },
             id: kHaomissyouConstraintWidth)
    }

    /// 最小宽度约束。`params` 格式同 `widthAnchor`。
    @discardableResult
    func widthAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _dim(my: view.widthAnchor, params: params, viewAnchor: { $0.widthAnchor },
             id: kHaomissyouConstraintWidthGTE, rel: .greaterThanOrEqual)
    }

    /// 最大宽度约束。`params` 格式同 `widthAnchor`。
    @discardableResult
    func widthAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _dim(my: view.widthAnchor, params: params, viewAnchor: { $0.widthAnchor },
             id: kHaomissyouConstraintWidthLTE, rel: .lessThanOrEqual)
    }

    // MARK: Height

    /// 高度约束。
    /// - params:
    ///   - `NSNumber`：固定高度。`view.haomissyou.heightAnchor(50)`
    ///   - `[toView, multiplier?, constant?]`：相对高度。`view.haomissyou.heightAnchor([superview, 0.5, 0])`
    @discardableResult
    func heightAnchor(_ params: Any) -> Haomissyou {
        _dim(my: view.heightAnchor, params: params, viewAnchor: { $0.heightAnchor },
             id: kHaomissyouConstraintHeight)
    }

    /// 最小高度约束。`params` 格式同 `heightAnchor`。
    @discardableResult
    func heightAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _dim(my: view.heightAnchor, params: params, viewAnchor: { $0.heightAnchor },
             id: kHaomissyouConstraintHeightGTE, rel: .greaterThanOrEqual)
    }

    /// 最大高度约束。`params` 格式同 `heightAnchor`。
    @discardableResult
    func heightAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _dim(my: view.heightAnchor, params: params, viewAnchor: { $0.heightAnchor },
             id: kHaomissyouConstraintHeightLTE, rel: .lessThanOrEqual)
    }

    // MARK: CenterX

    /// 水平居中约束。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.centerXAnchor([superview])          // 与父视图水平居中
    /// view.haomissyou.centerXAnchor([superview, 10])      // 偏右 10pt
    /// ```
    @discardableResult
    func centerXAnchor(_ params: Any) -> Haomissyou {
        _x(my: view.centerXAnchor, params: params, viewAnchor: { $0.centerXAnchor },
           id: kHaomissyouConstraintCenterX)
    }

    /// CenterX 大于等于约束。`params` 格式同 `centerXAnchor`。
    @discardableResult
    func centerXAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.centerXAnchor, params: params, viewAnchor: { $0.centerXAnchor },
           id: kHaomissyouConstraintCenterXGTE, rel: .greaterThanOrEqual)
    }

    /// CenterX 小于等于约束。`params` 格式同 `centerXAnchor`。
    @discardableResult
    func centerXAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _x(my: view.centerXAnchor, params: params, viewAnchor: { $0.centerXAnchor },
           id: kHaomissyouConstraintCenterXLTE, rel: .lessThanOrEqual)
    }

    // MARK: CenterY

    /// 垂直居中约束。
    /// - params: `[toView, constant?]` 或 `[toAnchor, constant?]`
    /// ```swift
    /// view.haomissyou.centerYAnchor([superview])          // 与父视图垂直居中
    /// view.haomissyou.centerYAnchor([superview, -10])     // 偏上 10pt
    /// ```
    @discardableResult
    func centerYAnchor(_ params: Any) -> Haomissyou {
        _y(my: view.centerYAnchor, params: params, viewAnchor: { $0.centerYAnchor },
           id: kHaomissyouConstraintCenterY)
    }

    /// CenterY 大于等于约束。`params` 格式同 `centerYAnchor`。
    @discardableResult
    func centerYAnchorGreaterOrEqual(_ params: Any) -> Haomissyou {
        _y(my: view.centerYAnchor, params: params, viewAnchor: { $0.centerYAnchor },
           id: kHaomissyouConstraintCenterYGTE, rel: .greaterThanOrEqual)
    }

    /// CenterY 小于等于约束。`params` 格式同 `centerYAnchor`。
    @discardableResult
    func centerYAnchorLessOrEqual(_ params: Any) -> Haomissyou {
        _y(my: view.centerYAnchor, params: params, viewAnchor: { $0.centerYAnchor },
           id: kHaomissyouConstraintCenterYLTE, rel: .lessThanOrEqual)
    }

    // MARK: edgeToSuperView

    /**
     四边贴 superview。
     - nil or no param: 全 0
     - NSNumber: 四边相同 inset（bottom/right 自动取反）
     - [top, left, bottom, right]: 直接传给约束 constant（bottom/right 需调用者自行传负数）
     - [vertical, horizontal]: top/left 正值，bottom/right 自动取反
     - [singleValue]: 等同 NSNumber
     - UIEdgeInsets（NSValue）: insets.bottom/right 取反
     */
    @discardableResult
    func edgeToSuperView(_ params: Any? = nil) -> Haomissyou {
        guard let superview = view.superview else {
            print("[Haomissyou AutoLayout] Warning: View has no superview for edgeToSuperView")
            return self
        }
        view.translatesAutoresizingMaskIntoConstraints = false

        var top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0

        if let params = params {
            if let n = params as? NSNumber {
                let v = CGFloat(n.doubleValue)
                top = v; left = v; bottom = -v; right = -v
            } else if let arr = params as? [Any] {
                switch arr.count {
                case 0:
                    break
                case 1:
                    let v = CGFloat((arr[0] as? NSNumber)?.doubleValue ?? 0)
                    top = v; left = v; bottom = -v; right = -v
                case 2:
                    let vertical   = CGFloat((arr[0] as? NSNumber)?.doubleValue ?? 0)
                    let horizontal = CGFloat((arr[1] as? NSNumber)?.doubleValue ?? 0)
                    top = vertical; left = horizontal; bottom = -vertical; right = -horizontal
                default: // 4+
                    top    = CGFloat((arr[0] as? NSNumber)?.doubleValue ?? 0)
                    left   = CGFloat((arr[1] as? NSNumber)?.doubleValue ?? 0)
                    bottom = CGFloat((arr[2] as? NSNumber)?.doubleValue ?? 0)
                    right  = CGFloat((arr[3] as? NSNumber)?.doubleValue ?? 0)
                }
            } else if let val = params as? NSValue {
                let insets = val.uiEdgeInsetsValue
                top = insets.top; left = insets.left
                bottom = -insets.bottom; right = -insets.right
            }
        }

        let cTop      = view.topAnchor.constraint(equalTo: superview.topAnchor, constant: top)
        let cLeading  = view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: left)
        let cTrailing = view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: right)
        let cBottom   = view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom)
        _activateConstraint(cTop)
        _activateConstraint(cLeading)
        _activateConstraint(cTrailing)
        _activateConstraint(cBottom)
        return self
    }

    // MARK: batch

    /**
     批量激活约束，提升性能。block 内所有约束方法统一收集，block 结束后一次性调用
     `NSLayoutConstraint.activate`。支持嵌套；异常安全（defer 保证计数器归零）。

     ```swift
     view.haomissyou.batch { hm in
         hm.leadingAnchor([superview, 10])
           .topAnchor([superview, 10])
           .widthAnchor(100)
           .heightAnchor(50)
     }
     ```
     */
    @discardableResult
    func batch(_ block: (Haomissyou) -> Void) -> Haomissyou {
        _batchDepth += 1
        defer {
            _batchDepth -= 1
            if _batchDepth == 0 {
                NSLayoutConstraint.activate(_batchConstraints)
                _batchConstraints.removeAll()
            }
        }
        block(self)
        return self
    }
}
