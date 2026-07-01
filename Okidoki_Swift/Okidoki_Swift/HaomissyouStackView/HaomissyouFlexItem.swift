//
//  HaomissyouFlexItem.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit
import ObjectiveC

// MARK: - UIView dimension constraint helpers (replaces ZLLayout dependency)

private var _hmWidthConsKey:     UInt8 = 0
private var _hmHeightConsKey:    UInt8 = 0
private var _hmMinWidthConsKey:  UInt8 = 0
private var _hmMaxWidthConsKey:  UInt8 = 0
private var _hmMinHeightConsKey: UInt8 = 0
private var _hmMaxHeightConsKey: UInt8 = 0

extension UIView {
    func hmSetWidth(_ w: CGFloat) {
        if let c = objc_getAssociatedObject(self, &_hmWidthConsKey) as? NSLayoutConstraint {
            c.constant = w
        } else {
            let c = widthAnchor.constraint(equalToConstant: w)
            c.isActive = true
            objc_setAssociatedObject(self, &_hmWidthConsKey, c, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func hmSetHeight(_ h: CGFloat) {
        if let c = objc_getAssociatedObject(self, &_hmHeightConsKey) as? NSLayoutConstraint {
            c.constant = h
        } else {
            let c = heightAnchor.constraint(equalToConstant: h)
            c.isActive = true
            objc_setAssociatedObject(self, &_hmHeightConsKey, c, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func hmSetMinWidth(_ w: CGFloat) {
        if let c = objc_getAssociatedObject(self, &_hmMinWidthConsKey) as? NSLayoutConstraint {
            c.constant = w
        } else {
            let c = widthAnchor.constraint(greaterThanOrEqualToConstant: w)
            c.isActive = true
            objc_setAssociatedObject(self, &_hmMinWidthConsKey, c, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func hmSetMaxWidth(_ w: CGFloat) {
        if let c = objc_getAssociatedObject(self, &_hmMaxWidthConsKey) as? NSLayoutConstraint {
            c.constant = w
        } else {
            let c = widthAnchor.constraint(lessThanOrEqualToConstant: w)
            c.isActive = true
            objc_setAssociatedObject(self, &_hmMaxWidthConsKey, c, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func hmSetMinHeight(_ h: CGFloat) {
        if let c = objc_getAssociatedObject(self, &_hmMinHeightConsKey) as? NSLayoutConstraint {
            c.constant = h
        } else {
            let c = heightAnchor.constraint(greaterThanOrEqualToConstant: h)
            c.isActive = true
            objc_setAssociatedObject(self, &_hmMinHeightConsKey, c, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func hmSetMaxHeight(_ h: CGFloat) {
        if let c = objc_getAssociatedObject(self, &_hmMaxHeightConsKey) as? NSLayoutConstraint {
            c.constant = h
        } else {
            let c = heightAnchor.constraint(lessThanOrEqualToConstant: h)
            c.isActive = true
            objc_setAssociatedObject(self, &_hmMaxHeightConsKey, c, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - UIView extension for hmFlex

private var _hmFlexItemKey: UInt8 = 0

/// 为每个 `UIView` 懒加载一个 `HaomissyouFlexItem`，通过 Associated Object 绑定。
/// 使用方式：`view.hmFlex.spacing = 8`，`view.hmFlex.flexValue = 1`
public extension UIView {
    /// 获取关联的弹性布局属性对象 (equivalent to zl_flex)
    var hmFlex: HaomissyouFlexItem {
        if let item = objc_getAssociatedObject(self, &_hmFlexItemKey) as? HaomissyouFlexItem {
            return item
        }
        let item = HaomissyouFlexItem()
        item.weakView = self
        objc_setAssociatedObject(self, &_hmFlexItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return item
    }
}

// MARK: - HaomissyouFlexItem

/// 每个子视图的 Flex 布局配置容器，通过 `UIView.hmFlex` 访问。
///
/// ## 职责
/// `HaomissyouFlexItem` 是**数据层**，存储单个子视图在 StackView 中的所有布局参数。
/// `HaomissyouFlexManager`（约束层）读取这些参数来决定生成什么约束。
///
/// ## 属性分类
///
/// ### 主轴间距（影响 nextAnchor 约束链）
/// - `spacing`：与下一个视图的固定间距。值 `< 0` 时回退使用 `stackView.spacing`
/// - `minSpacing`：间距下限（`>= minSpacing`，值 `< 0` 表示不设置）
/// - `maxSpacing`：间距上限（`<= maxSpacing`，值 `< 0` 表示不设置）
/// - `isFlexSpace`：是否在视图尾部插入弹性 Guide（fill/fillEqually 模式有效）
///
/// ### 主轴弹性比例
/// - `flexValue`：Flex 权重。`> 0` 时与同轴其他 flex 视图按比例分配剩余空间。
///   最终生成 `widthAnchor == firstFlexView.widthAnchor × (flex/firstFlex)` 约束。
///
/// ### 交叉轴对齐
/// - `alignSelf`：覆盖 StackView 全局 `alignment`。未显式设置时继承全局值。
/// - `startSpacing`：交叉轴起始端的额外内边距（叠加在 insets 之上）
/// - `endSpacing`：交叉轴末端的额外内边距
///
/// ### 尺寸约束（独立于 StackView 约束链）
/// - `width` / `height` / `minWidth` / `maxWidth` / `minHeight` / `maxHeight`：
///   通过 `hmSetWidth` 等帮助方法为视图本身添加独立的尺寸约束，
///   与主轴链约束无关，可随时修改 `constant` 而无需重建布局。
///
/// ## 动态更新设计
/// 属性的 `didSet` 会尝试**直接修改已有约束的 `constant`**（通过 `hmItem` 标签查找），
/// 只在找不到对应约束时才回退到 `triggerStackViewUpdate()`（整体重建）。
/// 这是性能优化的关键：频繁调用 `spacing = x` 不会触发全量重建。
///
/// ## KVO 监听 isHidden
/// `weakView` 设置时自动注册 `isHidden` 的 KVO，视图隐藏/显示时
/// 通知 StackView 标记 dirty 并重建约束（隐藏的视图不参与排列）。
public final class HaomissyouFlexItem: NSObject {

    // MARK: - Backing storage

    private var _startSpacing: CGFloat = 0
    private var _endSpacing:   CGFloat = 0
    private var _spacing:      CGFloat = -1
    private var _minSpacing:   CGFloat = -2
    private var _maxSpacing:   CGFloat = -2
    private var _alignSelf:    HaomissyouAlign = .center
    private var _isSetAlign:   Bool = false
    private var _isKVOAdded:   Bool = false

    // MARK: - Public read-only view reference

    public var view: UIView? { return weakView }

    // MARK: - Internal references

    weak var weakView: UIView? {
        didSet {
            guard let v = weakView, !_isKVOAdded else { return }
            _isKVOAdded = true
            v.addObserver(self, forKeyPath: "hidden", options: [.new, .old], context: nil)
        }
    }

    weak var stackView: HaomissyouBaseStackView?

    // MARK: - Cross-axis alignment spacing

    public var startSpacing: CGFloat {
        get { _startSpacing }
        set {
            guard newValue != _startSpacing else { return }
            _startSpacing = newValue
            let arr = filterConstraints { $0.hmItem.view === weakView && $0.hmItem.type == .start }
            if let cons = arr.first {
                let insetStart: CGFloat = stackView.map {
                    $0.axis == .horizontal ? $0.insets.top : $0.insets.left
                } ?? 0
                cons.constant = newValue + insetStart
                if alignSelf == .center {
                    filterConstraints { $0.hmItem.view === weakView && $0.hmItem.type == .center }
                        .first?.constant = (newValue - endSpacing) * 0.5
                }
            } else {
                triggerStackViewUpdate()
            }
        }
    }

    public var endSpacing: CGFloat {
        get { _endSpacing }
        set {
            guard newValue != _endSpacing else { return }
            _endSpacing = newValue
            let arr = filterConstraints { $0.hmItem.view === weakView && $0.hmItem.type == .end }
            if let cons = arr.first {
                let insetEnd: CGFloat = stackView.map {
                    $0.axis == .horizontal ? $0.insets.bottom : $0.insets.right
                } ?? 0
                cons.constant = -newValue - insetEnd
                if alignSelf == .center {
                    filterConstraints { $0.hmItem.view === weakView && $0.hmItem.type == .center }
                        .first?.constant = (startSpacing - newValue) * 0.5
                }
            } else {
                triggerStackViewUpdate()
            }
        }
    }

    // MARK: - Spacing (custom getter: uses stackView.spacing when own spacing <= 0)

    public var spacing: CGFloat {
        get { _spacing > 0 ? _spacing : (stackView?.spacing ?? _spacing) }
        set {
            guard newValue != _spacing else { return }
            _spacing = newValue
            triggerStackViewUpdate()
        }
    }

    public var minSpacing: CGFloat {
        get { _minSpacing }
        set {
            guard newValue != _minSpacing else { return }
            stackView?.setCustomMinSpacing(newValue, afterView: weakView!)
            _minSpacing = newValue
        }
    }

    public var maxSpacing: CGFloat {
        get { _maxSpacing }
        set {
            guard newValue != _maxSpacing else { return }
            stackView?.setCustomMaxSpacing(newValue, afterView: weakView!)
            _maxSpacing = newValue
        }
    }

    // MARK: - Flex spacing flag (ZLJustifyFill 才会有效)

    public var isFlexSpace: Bool = false {
        didSet {
            guard isFlexSpace != oldValue else { return }
            triggerStackViewUpdate()
        }
    }

    // MARK: - Flex weight (横向=宽度比例，纵向=高度比例)

    public var flexValue: Int = 0 {
        didSet {
            guard flexValue != oldValue else { return }
            triggerStackViewUpdate()
        }
    }

    // MARK: - Per-item alignment (custom getter: falls back to stackView.alignment)

    public var alignSelf: HaomissyouAlign {
        get { _isSetAlign ? _alignSelf : (stackView?.alignment ?? _alignSelf) }
        set {
            _isSetAlign = true
            guard newValue != _alignSelf else { return }
            _alignSelf = newValue
            triggerStackViewUpdate()
        }
    }

    // MARK: - Dimension constraints (delegated to UIView helpers)

    public var width: CGFloat = 0 {
        didSet { guard width != oldValue else { return }; weakView?.hmSetWidth(width) }
    }
    public var height: CGFloat = 0 {
        didSet { guard height != oldValue else { return }; weakView?.hmSetHeight(height) }
    }
    public var minWidth: CGFloat = 0 {
        didSet { guard minWidth != oldValue else { return }; weakView?.hmSetMinWidth(minWidth) }
    }
    public var maxWidth: CGFloat = 0 {
        didSet { guard maxWidth != oldValue else { return }; weakView?.hmSetMaxWidth(maxWidth) }
    }
    public var minHeight: CGFloat = 0 {
        didSet { guard minHeight != oldValue else { return }; weakView?.hmSetMinHeight(minHeight) }
    }
    public var maxHeight: CGFloat = 0 {
        didSet { guard maxHeight != oldValue else { return }; weakView?.hmSetMaxHeight(maxHeight) }
    }
    public var size: CGSize = .zero {
        didSet {
            guard size != oldValue else { return }
            weakView?.hmSetWidth(size.width)
            weakView?.hmSetHeight(size.height)
        }
    }

    // MARK: - Internal bypass setters (skip side-effects, used by ZLBaseStackView)

    func setSpacingWithoutUpdate(_ v: CGFloat)    { _spacing    = v }
    func setMinSpacingWithoutUpdate(_ v: CGFloat) { _minSpacing  = v }
    func setMaxSpacingWithoutUpdate(_ v: CGFloat) { _maxSpacing  = v }

    // MARK: - Private helpers

    private func filterConstraints(where predicate: (NSLayoutConstraint) -> Bool) -> [NSLayoutConstraint] {
        guard let sv = stackView else { return [] }
        return sv.layoutManager.constraints.filter(predicate)
    }

    private func triggerStackViewUpdate() {
        guard let v = weakView, let sv = stackView, v.superview === sv else { return }
        sv.markedDirty = true
        sv.setNeedsUpdateConstraints()
    }

    // MARK: - KVO

    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if keyPath == "hidden" {
            let oldHidden = (change?[.oldKey] as? Bool) ?? false
            let newHidden = (change?[.newKey] as? Bool) ?? false
            guard oldHidden != newHidden else { return }
            triggerStackViewUpdate()
        }
    }

    deinit {
        if _isKVOAdded {
            weakView?.removeObserver(self, forKeyPath: "hidden")
        }
    }

    // MARK: - Chainable API

    @discardableResult public func start(_ s: CGFloat)  -> HaomissyouFlexItem { startSpacing = s; return self }
    @discardableResult public func end(_ s: CGFloat)    -> HaomissyouFlexItem { endSpacing   = s; return self }
    @discardableResult public func space(_ s: CGFloat)  -> HaomissyouFlexItem { spacing      = s; return self }
    @discardableResult public func minSpace(_ s: CGFloat) -> HaomissyouFlexItem { minSpacing  = s; return self }
    @discardableResult public func maxSpace(_ s: CGFloat) -> HaomissyouFlexItem { maxSpacing  = s; return self }
    @discardableResult public func flexSpace(_ f: Bool) -> HaomissyouFlexItem { isFlexSpace  = f; return self }
    @discardableResult public func flex(_ v: Int)       -> HaomissyouFlexItem { flexValue    = v; return self }
    @discardableResult public func align(_ a: HaomissyouAlign) -> HaomissyouFlexItem { alignSelf = a; return self }

    @discardableResult public func alignStart()  -> HaomissyouFlexItem { alignSelf = .start;  return self }
    @discardableResult public func alignEnd()    -> HaomissyouFlexItem { alignSelf = .end;    return self }
    @discardableResult public func alignCenter() -> HaomissyouFlexItem { alignSelf = .center; return self }
    @discardableResult public func alignFill()   -> HaomissyouFlexItem { alignSelf = .fill;   return self }

    @discardableResult public func h(_ v: CGFloat)   -> HaomissyouFlexItem { height    = v; return self }
    @discardableResult public func w(_ v: CGFloat)   -> HaomissyouFlexItem { width     = v; return self }
    @discardableResult public func square(_ v: CGFloat) -> HaomissyouFlexItem { width  = v; height = v; return self }
    @discardableResult public func minW(_ v: CGFloat) -> HaomissyouFlexItem { minWidth  = v; return self }
    @discardableResult public func maxW(_ v: CGFloat) -> HaomissyouFlexItem { maxWidth  = v; return self }
    @discardableResult public func minH(_ v: CGFloat) -> HaomissyouFlexItem { minHeight = v; return self }
    @discardableResult public func maxH(_ v: CGFloat) -> HaomissyouFlexItem { maxHeight = v; return self }
}
