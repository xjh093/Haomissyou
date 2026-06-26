//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-23
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

/// UIView associated object keys for whenEnabled / whenDisabled blocks
private var _whenEnabledKey: UInt8 = 0
private var _whenDisabledKey: UInt8 = 0

private extension UIView {
    var _whenEnabledBlock: ((UIView) -> Void)? {
        get { objc_getAssociatedObject(self, &_whenEnabledKey) as? (UIView) -> Void }
        set { objc_setAssociatedObject(self, &_whenEnabledKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    var _whenDisabledBlock: ((UIView) -> Void)? {
        get { objc_getAssociatedObject(self, &_whenDisabledKey) as? (UIView) -> Void }
        set { objc_setAssociatedObject(self, &_whenDisabledKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
}

// MARK: - Private Helpers

private extension Haomissyou {

    /// 从 Any 中提取 CGFloat（Int / Double / Float / CGFloat / NSNumber / String）
    func cgFloat(from value: Any) -> CGFloat? {
        switch value {
        case let n as CGFloat:   return n
        case let n as Double:    return CGFloat(n)
        case let n as Float:     return CGFloat(n)
        case let n as Int:       return CGFloat(n)
        case let n as NSNumber:  return CGFloat(n.doubleValue)
        case let s as String:
            if let d = Double(s) { return CGFloat(d) }
            return nil
        default: return nil
        }
    }

    /// 从 Any 中提取 Bool（Bool / NSNumber / String）
    func bool(from value: Any) -> Bool? {
        // Bool 在 Swift 里是 NSNumber 的子类，必须先判断 Bool
        if let b = value as? Bool       { return b }
        if let n = value as? NSNumber   { return n.boolValue }
        if let s = value as? String     { return (s as NSString).boolValue }
        return nil
    }
}

// MARK: - UIView

public extension Haomissyou {

    // MARK: tag
    /// NSNumber / Int / String
    @discardableResult
    func tag(_ value: Any) -> Haomissyou {
        if let i = value as? Int {
            view.tag = i
        } else if let n = value as? NSNumber {
            view.tag = n.intValue
        } else if let s = value as? String, let i = Int(s) {
            view.tag = i
        }
        return self
    }

    // MARK: frame
    /// CGRect / NSValue(CGRect) / String (e.g. "{{0,0},{100,100}}")
    @discardableResult
    func frame(_ value: Any) -> Haomissyou {
        if let rect = value as? CGRect {
            view.frame = rect
        } else if let v = value as? NSValue {
            view.frame = v.cgRectValue
        } else if let s = value as? String {
            view.frame = NSCoder.cgRect(for: s)
        }
        return self
    }

    // MARK: alpha
    /// CGFloat / Double / NSNumber / String
    @discardableResult
    func alpha(_ value: Any) -> Haomissyou {
        guard let f = cgFloat(from: value) else { return self }
        view.alpha = f
        return self
    }

    // MARK: hidden
    /// Bool / NSNumber / String
    @discardableResult
    func hidden(_ value: Any) -> Haomissyou {
        guard let b = bool(from: value) else { return self }
        view.isHidden = b
        return self
    }

    // MARK: bgColor
    /// UIColor / String ("FFFEEE", "#FFFEEE", "0xFFFEEE", "0XFFFEEE")
    @discardableResult
    func bgColor(_ value: Any) -> Haomissyou {
        view.backgroundColor = UIColor.haomissyouColor(value)
        return self
    }

    // MARK: bdColor
    /// UIColor / String
    @discardableResult
    func bdColor(_ value: Any) -> Haomissyou {
        if let color = UIColor.haomissyouColor(value) {
            view.layer.borderColor = color.cgColor
        }
        return self
    }

    // MARK: bdWidth
    /// CGFloat / Double / NSNumber / String
    @discardableResult
    func bdWidth(_ value: Any) -> Haomissyou {
        guard let f = cgFloat(from: value) else { return self }
        view.layer.borderWidth = f
        return self
    }

    // MARK: cnRadius
    /// CGFloat / Double / NSNumber / String
    @discardableResult
    func cnRadius(_ value: Any) -> Haomissyou {
        guard let f = cgFloat(from: value) else { return self }
        view.layer.cornerRadius = f
        return self
    }

    // MARK: mkCorners
    /// [Int]：1=左上, 2=右上, 3=右下, 4=左下
    @discardableResult
    func mkCorners(_ value: Any) -> Haomissyou {

        // 支持 [Int] 或 [NSNumber]
        var ints: [Int] = []
        if let arr = value as? [Int] {
            ints = arr
        } else if let arr = value as? [NSNumber] {
            ints = arr.map { $0.intValue }
        }
        guard !ints.isEmpty else { return self }

        var mask: CACornerMask = []
        if ints.contains(1) { mask.insert(.layerMinXMinYCorner) }
        if ints.contains(2) { mask.insert(.layerMaxXMinYCorner) }
        if ints.contains(3) { mask.insert(.layerMaxXMaxYCorner) }
        if ints.contains(4) { mask.insert(.layerMinXMaxYCorner) }

        if !mask.isEmpty {
            view.layer.maskedCorners = mask
        }
        return self
    }

    // MARK: mtBounds
    /// Bool / NSNumber / String
    @discardableResult
    func mtBounds(_ value: Any) -> Haomissyou {
        guard let b = bool(from: value) else { return self }
        view.layer.masksToBounds = b
        return self
    }

    // MARK: shadowColor
    /// UIColor / String
    @discardableResult
    func shadowColor(_ value: Any) -> Haomissyou {
        if let color = UIColor.haomissyouColor(value) {
            view.layer.shadowColor = color.cgColor
        }
        return self
    }

    // MARK: shadowOpacity
    /// Float / Double / NSNumber / String
    @discardableResult
    func shadowOpacity(_ value: Any) -> Haomissyou {
        guard let f = cgFloat(from: value) else { return self }
        view.layer.shadowOpacity = Float(f)
        return self
    }

    // MARK: shadowOffset
    /// CGSize / NSValue(CGSize) / String (e.g. "{3, -3}")
    @discardableResult
    func shadowOffset(_ value: Any) -> Haomissyou {
        if let size = value as? CGSize {
            view.layer.shadowOffset = size
        } else if let v = value as? NSValue {
            view.layer.shadowOffset = v.cgSizeValue
        } else if let s = value as? String {
            view.layer.shadowOffset = NSCoder.cgSize(for: s)
        }
        return self
    }

    // MARK: shadowRadius
    /// CGFloat / Double / NSNumber / String
    @discardableResult
    func shadowRadius(_ value: Any) -> Haomissyou {
        guard let f = cgFloat(from: value) else { return self }
        view.layer.shadowRadius = f
        return self
    }

    // MARK: shadowPath
    /// UIBezierPath / CGPath
    @discardableResult
    func shadowPath(_ value: Any) -> Haomissyou {
        if let path = value as? UIBezierPath {
            view.layer.shadowPath = path.cgPath
        } else {
            // CGPath 是 CF 类型，不能用 as? 判断，需通过 CFGetTypeID 检查
            let obj = value as AnyObject
            if CFGetTypeID(obj) == CGPath.typeID {
                view.layer.shadowPath = (obj as! CGPath)
            }
        }
        return self
    }

    // MARK: addSubview
    /// UIView
    @discardableResult
    func addSubview(_ subview: UIView) -> Haomissyou {
        view.addSubview(subview)
        return self
    }

    // MARK: addSubviewWithConfig
    /// 添加子 view，并通过 block 配置子 view 的 Haomissyou
    @discardableResult
    func addSubviewWithConfig(_ subview: UIView,
                              _ config: (Haomissyou) -> Void) -> Haomissyou {
        view.addSubview(subview)
        config(subview.haomissyou)
        return self
    }

    /// 添加子 view，block 中额外提供父 view 引用（方便相对布局）
    @discardableResult
    func addSubviewWithConfig(_ subview: UIView,
                              _ config: (Haomissyou, UIView) -> Void) -> Haomissyou {
        view.addSubview(subview)
        config(subview.haomissyou, view)
        return self
    }

    // MARK: addToSuperview
    /// 将当前 view 添加到指定父 view
    @discardableResult
    func addToSuperview(_ superView: UIView) -> Haomissyou {
        superView.addSubview(view)
        return self
    }
    
    // MARK: then
    /// 在链式调用中插入任意逻辑，block 提供当前 view 引用，执行后继续链式。
    @discardableResult
    func then(_ block: (UIView) -> Void) -> Haomissyou {
        block(view)
        return self
    }
    
    // MARK: userInteractionEnabled
    /// Bool / NSNumber / String；设置后触发内联 block 及之前通过 whenEnabled/whenDisabled 注册的 block。
    @discardableResult
    func userInteractionEnabled(_ value: Any,
                                whenEnabled: ((UIView) -> Void)? = nil,
                                whenDisabled: ((UIView) -> Void)? = nil) -> Haomissyou {
        guard let b = bool(from: value) else { return self }
        view.isUserInteractionEnabled = b
        if b {
            whenEnabled?(view)
            view._whenEnabledBlock?(view)
        } else {
            whenDisabled?(view)
            view._whenDisabledBlock?(view)
        }
        return self
    }

    // MARK: whenEnabled
    /// 注册 block；当前已是 enabled 状态则立即调用，同时保存到 view 上以便后续再次触发。
    @discardableResult
    func whenEnabled(_ block: @escaping (UIView) -> Void) -> Haomissyou {
        view._whenEnabledBlock = block
        if view.isUserInteractionEnabled { block(view) }
        return self
    }

    // MARK: whenDisabled
    /// 注册 block；当前已是 disabled 状态则立即调用，同时保存到 view 上以便后续再次触发。
    @discardableResult
    func whenDisabled(_ block: @escaping (UIView) -> Void) -> Haomissyou {
        view._whenDisabledBlock = block
        if !view.isUserInteractionEnabled { block(view) }
        return self
    }
    
    // MARK: gradient

    /// 设置渐变颜色。内部使用 CAGradientLayer，自动插入 layer 层级最底层。
    /// 需在 view 已有 frame/bounds 后调用，或配合 then { } 在 layoutSubviews 后刷新。
    @discardableResult
    func gradient(_ colors: [UIColor]) -> Haomissyou {
        let layer = view._haomissyouGradientLayer
        layer.colors = colors.map(\.cgColor)
        layer.frame = view.bounds
        return self
    }

    /// 设置渐变方向，需在 gradient(_:) 之后或之前调用均可。
    @discardableResult
    func gradientDirection(_ direction: HaomissyouGradientDirection) -> Haomissyou {
        let layer = view._haomissyouGradientLayer
        let (start, end) = direction.points
        layer.startPoint = start
        layer.endPoint   = end
        layer.frame      = view.bounds
        return self
    }
}

// MARK: - HaomissyouGradientDirection

/// 渐变方向
public enum HaomissyouGradientDirection {
    case horizontal             // 左 → 右
    case vertical               // 上 → 下
    case diagonalDownRight      // 左上 → 右下
    case diagonalDownLeft       // 右上 → 左下
    case custom(start: CGPoint, end: CGPoint)

    fileprivate var points: (start: CGPoint, end: CGPoint) {
        switch self {
        case .horizontal:         return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        case .vertical:           return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
        case .diagonalDownRight:  return (CGPoint(x: 0, y: 0),   CGPoint(x: 1, y: 1))
        case .diagonalDownLeft:   return (CGPoint(x: 1, y: 0),   CGPoint(x: 0, y: 1))
        case .custom(let s, let e): return (s, e)
        }
    }
}

// MARK: - UIView gradient layer (associated object)

private var _haomissyouGradientLayerKey: UInt8 = 0

/// 隐藏的辅助视图：随父视图 layoutSubviews 自动同步渐变层 frame，无需手动管理。
private final class _GradientLayoutObserver: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        superview?._haomissyouGradientLayer.frame = superview?.bounds ?? .zero
    }
}

private extension UIView {
    /// 懒加载渐变层：首次访问时创建并插入 layer 层级最底层，同时挂载布局观察子视图。
    var _haomissyouGradientLayer: CAGradientLayer {
        if let existing = objc_getAssociatedObject(self, &_haomissyouGradientLayerKey) as? CAGradientLayer {
            return existing
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        // 默认方向：上 → 下
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
        objc_setAssociatedObject(self, &_haomissyouGradientLayerKey, gradientLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 添加布局观察视图，利用其 layoutSubviews 自动同步渐变层 frame
        let observer = _GradientLayoutObserver()
        observer.isHidden = true
        observer.isUserInteractionEnabled = false
        observer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(observer)

        return gradientLayer
    }
}
