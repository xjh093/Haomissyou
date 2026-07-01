//
//  HaomissyouStackView.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//
// version: 0.1.0
// 2026-06-30 14:44:59

import UIKit
import ObjectiveC

// MARK: - Color helper (replaces ZLColorFromObj)

private func _hmColorFromAny(_ value: Any) -> UIColor? {
    if let color = value as? UIColor { return color }
    if let hex = value as? String    { return UIColor(_hmHex: hex) }
    return nil
}

private extension UIColor {
    convenience init?(_hmHex hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h = String(h.dropFirst()) }
        guard h.count == 6 || h.count == 8 else { return nil }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        if h.count == 6 {
            self.init(red:   CGFloat((rgb >> 16) & 0xFF) / 255,
                      green: CGFloat((rgb >>  8) & 0xFF) / 255,
                      blue:  CGFloat( rgb        & 0xFF) / 255,
                      alpha: 1.0)
        } else {
            self.init(red:   CGFloat((rgb >> 24) & 0xFF) / 255,
                      green: CGFloat((rgb >> 16) & 0xFF) / 255,
                      blue:  CGFloat((rgb >>  8) & 0xFF) / 255,
                      alpha: CGFloat( rgb        & 0xFF) / 255)
        }
    }
}

// MARK: - Tap action storage

private var _hmTapActionKey: UInt8 = 0

// MARK: - HaomissyouScrollView

/// RTL（从右到左书写方向）感知的滚动视图包装器。
///
/// ## 设计原理
/// 在阿拉伯语等 RTL 语言环境下，`UIScrollView` 本身不会自动翻转内容方向。
/// 此类在 `layoutSubviews` 中检测 `effectiveUserInterfaceLayoutDirection`，
/// 当为 RTL 时，对自身及所有子视图施加 `scaleX(-1)` 变换，
/// 使内容水平镜像，实现正确的 RTL 布局方向。
open class HaomissyouScrollView: UIScrollView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let transform: CGAffineTransform = isRTL ? CGAffineTransform(scaleX: -1, y: 1) : .identity
        if self.transform != transform { self.transform = transform }
        subviews.forEach { view in
            if view.transform != transform { view.transform = transform }
        }
    }
}

// MARK: - HaomissyouBaseStackView

/// 核心 StackView 基类，提供类 Flexbox 的线性布局能力。
///
/// ## 整体架构
///
/// ```
/// HaomissyouBaseStackView
///   ├── axis              主轴方向（水平 / 垂直）
///   ├── alignment         交叉轴对齐（fill / start / center / end）
///   ├── justifyContent    主轴分布（fill / fillEqually / start / center / end /
///   │                              spaceBetween / spaceAround / spaceEvenly）
///   ├── insets            内边距（由 HaomissyouStackEdgeInsets 管理）
///   ├── spacing           全局默认间距（子视图未设置时回退到此值）
///   │
///   ├── allViews          所有已添加的视图（含隐藏视图）
///   ├── arrangedViews     参与布局的视图（过滤隐藏视图，并确保已 addSubview）
///   │
///   └── layoutManager     HaomissyouFlexManager（约束生成引擎）
/// ```
///
/// ## 布局更新时机
///
/// 采用 **脏标记 + updateConstraints 延迟更新** 机制，避免频繁重建约束：
///
/// 1. 任何影响布局的属性变化（axis / alignment / justifyContent / 视图增删）
///    → `markedDirty = true` + `setNeedsUpdateConstraints()`
/// 2. 系统在下一个 layout pass 调用 `updateConstraints()`
/// 3. `updateConstraints()` 检查 `markedDirty`，若为 true 则：
///    - `removeAllSpacing()` + `deactivateConstraints()` 清除旧状态
///    - `addHorizontalLayoutConstraints()` + `addVerticalLayoutConstraints()`（互斥执行）
///    - `activateConstraints()` 批量激活
///    - `markedDirty = false`
///
/// ## 动态局部更新（不触发全量重建）
///
/// 以下操作会尝试**直接修改约束 constant** 而非整体重建：
/// - `setCustomSpacing(_:afterView:)` → 找到 `.spacing` 类型约束直接改值
/// - `setCustomMinSpacing` / `setCustomMaxSpacing` → 同上
/// - `updateInsets(_:)` → 只更新 `HaomissyouMargeGuide` 的四条边约束
///
/// ## Chainable API 设计
///
/// 所有配置方法均返回 `Self`，支持链式调用：
/// ```swift
/// HaomissyouStackView.horizontal()
///     .justifySpaceBetween()
///     .alignCenter()
///     .inset(8, 16, 8, 16)
///     .addView(labelA)
///     .insertSpace(12)
///     .addView(labelB)
/// ```
///
/// ## wrapScrollView()
///
/// 一键将 StackView 嵌入 `HaomissyouScrollView`，并根据 `axis` 自动设置：
/// - 水平 StackView → 固定高度等于 ScrollView，宽度低优先级等于 ScrollView
/// - 垂直 StackView → 固定宽度等于 ScrollView，高度低优先级等于 ScrollView
open class HaomissyouBaseStackView: UIView {

    // MARK: - Public properties

    /// 水平排列还是垂直排列，默认水平排列
    public var axis: HaomissyouStackViewAxis = .horizontal {
        didSet {
            guard axis != oldValue else { return }
            // axis 变化时，重新调整所有 label 在新旧两个方向上的压缩阻力
            allViews.forEach { adjustLabelCompression($0, oldAxis: oldValue) }
            markedDirty = true
            setNeedsUpdateConstraints()
        }
    }

    /// 纵轴对齐方式
    public var alignment: HaomissyouAlign = .fill {
        didSet { guard alignment != oldValue else { return }; markedDirty = true; setNeedsUpdateConstraints() }
    }

    /// 主轴对齐方式
    public var justifyContent: HaomissyouJustify = .fill {
        didSet { guard justifyContent != oldValue else { return }; markedDirty = true; setNeedsUpdateConstraints() }
    }

    /// 内边距
    public var insets: UIEdgeInsets = .zero {
        didSet { guard insets != oldValue else { return }; layoutManager.updateInsets(insets) }
    }

    public var spacing: CGFloat = -1 {
        didSet { guard spacing != oldValue else { return }; markedDirty = true; setNeedsUpdateConstraints() }
    }

    public var arrangedViews: [UIView] {
        return allViews.filter { view in
            if view.superview !== self { addSubview(view) }
            return !view.isHidden
        }
    }

    // MARK: - Internal

    var layoutManager: HaomissyouFlexManager = HaomissyouFlexManager()
    var markedDirty: Bool = true
    private var allViews: [UIView] = []
    /// O(1) 成员判断，与 allViews 保持同步
    private var allViewsSet: Set<ObjectIdentifier> = []

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        markedDirty = true
        // Suppress zero-width constraint warnings when insets are set before layout
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        spacing = -1
        layoutMargins = .zero
        layoutManager.stackView = self
    }

    // MARK: - Arranging subviews

    public func addArrangedSubview(_ view: UIView) {
        guard !allViewsSet.contains(ObjectIdentifier(view)) else { return }
        view.hmFlex.stackView = self
        allViews.append(view)
        allViewsSet.insert(ObjectIdentifier(view))
        adjustLabelCompression(view)
        adjustNestedStackView(view)
        addSubview(view)
        guard !view.isHidden else { return }
        markedDirty = true
        setNeedsUpdateConstraints()
    }

    public func addArrangedSubview(_ view: UIView, layout: (UIView, HaomissyouFlexItem) -> Void) {
        addArrangedSubview(view)
        layout(view, view.hmFlex)
    }

    public func insertArrangedSubview(_ view: UIView, at index: Int) {
        guard !allViewsSet.contains(ObjectIdentifier(view)) else { return }
        adjustNestedStackView(view)
        addSubview(view)
        view.hmFlex.stackView = self
        allViews.insert(view, at: index)
        allViewsSet.insert(ObjectIdentifier(view))
        adjustLabelCompression(view)
        guard !view.isHidden else { return }
        markedDirty = true
        setNeedsUpdateConstraints()
    }

    public func removeArrangedSubview(_ view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        // 先从索引移除，再调用 removeFromSuperview，
        // 确保 willRemoveSubview 触发时 guard 提前返回，避免重复清理
        allViews.removeAll { $0 === view }
        allViewsSet.remove(ObjectIdentifier(view))
        view.removeFromSuperview()
        markedDirty = true
        setNeedsUpdateConstraints()
    }

    // MARK: - Custom spacing

    public func setCustomSpacing(_ spacing: CGFloat, afterView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        let cfg = view.hmFlex
        guard cfg.spacing != spacing else { return }
        cfg.setSpacingWithoutUpdate(spacing)
        guard !view.isHidden else { return }
        guard !layoutManager.constraints.isEmpty else { return }
        let arr = filterConstraints { $0.hmItem.view === view && $0.hmItem.type == .spacing }
        if arr.isEmpty {
            markedDirty = true; setNeedsUpdateConstraints()
        } else {
            arr.first?.constant = max(0, spacing)
        }
    }

    public func setCustomMinSpacing(_ minSpacing: CGFloat, afterView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        let cfg = view.hmFlex
        guard cfg.minSpacing != minSpacing else { return }
        cfg.setMinSpacingWithoutUpdate(minSpacing)
        guard !view.isHidden else { return }
        guard !layoutManager.constraints.isEmpty else { return }
        let arr = filterConstraints { $0.hmItem.view === view && $0.hmItem.type == .minSpacing }
        if arr.count > 0, minSpacing >= 0 {
            arr.first?.constant = minSpacing
            arr.last?.constant  = minSpacing
        } else {
            // 约束尚未创建，或负值表示"清除约束"，均需全量重建
            markedDirty = true; setNeedsUpdateConstraints()
        }
    }

    public func setCustomMaxSpacing(_ maxSpacing: CGFloat, afterView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        let cfg = view.hmFlex
        guard cfg.maxSpacing != maxSpacing else { return }
        cfg.setMaxSpacingWithoutUpdate(maxSpacing)
        guard !view.isHidden else { return }
        guard !layoutManager.constraints.isEmpty else { return }
        let arr = filterConstraints { $0.hmItem.view === view && $0.hmItem.type == .maxSpacing }
        if arr.count > 0, maxSpacing >= 0 {
            arr.first?.constant = maxSpacing
        } else {
            markedDirty = true; setNeedsUpdateConstraints()
        }
    }

    public func setFlex(_ flex: Int, forView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)), flex >= 0 else { return }
        let cfg = view.hmFlex
        guard cfg.flexValue != flex else { return }
        cfg.flexValue = flex
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setFlexibleSpacing(_ flexible: Bool, afterView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        guard flexible != view.hmFlex.isFlexSpace else { return }
        view.hmFlex.isFlexSpace = flexible
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setAlignment(_ alignment: HaomissyouAlign, forView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        let cfg = view.hmFlex
        guard alignment != cfg.alignSelf else { return }
        cfg.alignSelf = alignment
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setAlignmentStartSpacing(_ spacing: CGFloat, forView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        let cfg = view.hmFlex
        guard spacing != cfg.startSpacing else { return }
        cfg.startSpacing = spacing
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setAlignmentEndSpacing(_ spacing: CGFloat, forView view: UIView) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        let cfg = view.hmFlex
        guard cfg.endSpacing != spacing else { return }
        cfg.endSpacing = spacing
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    // MARK: - Layout

    open override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        let key = ObjectIdentifier(subview)
        // removeArrangedSubview 会先从 allViewsSet 移除再调 removeFromSuperview，
        // 所以此时 key 已不在 set 中，guard 会提前返回，避免重复清理。
        // 只有外部直接调用 view.removeFromSuperview() 才会执行以下逻辑。
        guard allViewsSet.contains(key) else { return }
        allViews.removeAll { $0 === subview }
        allViewsSet.remove(key)
        markedDirty = true
        setNeedsUpdateConstraints()
    }

    open override func updateConstraints() {
        guard markedDirty else { super.updateConstraints(); return }
        layoutManager.removeAllSpacing()
        layoutManager.deactivateConstraints()
        layoutManager.addHorizontalLayoutConstraints()
        layoutManager.addVerticalLayoutConstraints()
        layoutManager.activateConstraints()
        markedDirty = false
        super.updateConstraints()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        // 若直接嵌入 HaomissyouScrollView，施加反向 transform 以抵消父级镜像，
        // 使内容视觉保持正常方向（净效果：scaleX(-1) × scaleX(-1) = identity）。
        // 滚动指示器没有此逻辑，只经历父级一次翻转，方向正确。
        if let scrollView = superview as? HaomissyouScrollView {
            let isRTL = scrollView.effectiveUserInterfaceLayoutDirection == .rightToLeft
            let t: CGAffineTransform = isRTL ? CGAffineTransform(scaleX: -1, y: 1) : .identity
            if self.transform != t { self.transform = t }
        }
    }

    open override var intrinsicContentSize: CGSize { .zero }

    /// 计算 StackView 在给定尺寸约束下的最小合适尺寸。
    ///
    /// 利用 AutoLayout 引擎进行计算：主轴方向使用 `.fittingSizeLevel` 压缩，
    /// 交叉轴方向使用 `.required` 固定（等于传入的 size 分量，0 则用系统压缩值）。
    ///
    /// 常见用途：`UITableViewCell` 自动高度、`preferredContentSize` 计算等。
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 确保约束在计算前已建立
        if markedDirty {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
        let compressedW = size.width  > 0 ? size.width  : UIView.layoutFittingCompressedSize.width
        let compressedH = size.height > 0 ? size.height : UIView.layoutFittingCompressedSize.height
        if axis == .horizontal {
            return systemLayoutSizeFitting(
                CGSize(width: compressedW, height: compressedH),
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: size.height > 0 ? .required : .fittingSizeLevel
            )
        } else {
            return systemLayoutSizeFitting(
                CGSize(width: compressedW, height: compressedH),
                withHorizontalFittingPriority: size.width > 0 ? .required : .fittingSizeLevel,
                verticalFittingPriority: .fittingSizeLevel
            )
        }
    }

    // MARK: - Wrap in scroll view

    public func wrapScrollView() -> HaomissyouScrollView {
        // 若已在某个视图层级中，先移除，避免静默改变 superview 导致调用方困惑
        removeFromSuperview()
        let scrollView = HaomissyouScrollView()
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: scrollView.topAnchor),
            leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
        let axisLayout: NSLayoutConstraint
        if axis == .horizontal {
            axisLayout = heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            let eq = scrollView.widthAnchor.constraint(equalTo: widthAnchor)
            eq.priority = .defaultLow; eq.isActive = true
        } else {
            axisLayout = widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            let eq = scrollView.heightAnchor.constraint(equalTo: heightAnchor)
            eq.priority = .defaultLow; eq.isActive = true
        }
        axisLayout.isActive = true
        return scrollView
    }

    // MARK: - Private helpers

    private func adjustNestedStackView(_ view: UIView) {
        guard view is HaomissyouBaseStackView else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    /// - Parameter oldAxis: 传入非 nil 时，先将旧 axis 方向的压缩阻力恢复为 `.defaultHigh`，
    ///   再对新 axis 方向降低优先级，保证 axis 动态切换时两个方向都处于正确状态。
    private func adjustLabelCompression(_ view: UIView, oldAxis: HaomissyouStackViewAxis? = nil) {
        guard let label = view as? UILabel, label.numberOfLines != 1 else { return }
        if let old = oldAxis {
            let oldNSAxis: NSLayoutConstraint.Axis = old == .horizontal ? .horizontal : .vertical
            // 恢复旧方向为默认值，避免两个方向都被降低
            label.setContentCompressionResistancePriority(.defaultHigh, for: oldNSAxis)
        }
        let newNSAxis: NSLayoutConstraint.Axis = self.axis == .horizontal ? .horizontal : .vertical
        let priority = label.contentCompressionResistancePriority(for: newNSAxis)
        if priority == .defaultHigh {
            label.setContentCompressionResistancePriority(priority - 0.1, for: newNSAxis)
        }
    }

    private func filterConstraints(where predicate: (NSLayoutConstraint) -> Bool) -> [NSLayoutConstraint] {
        return layoutManager.constraints.filter(predicate)
    }

    // MARK: - Tap action

    private var _hmTapAction: ((HaomissyouBaseStackView) -> Void)? {
        get { objc_getAssociatedObject(self, &_hmTapActionKey) as? (HaomissyouBaseStackView) -> Void }
        set { objc_setAssociatedObject(self, &_hmTapActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    @objc private func _hmHandleTap(_ gesture: UITapGestureRecognizer) {
        _hmTapAction?(self)
    }

    // MARK: - Chainable factory methods

    public class func horizontal() -> Self {
        let sv = self.init()
        sv.axis = .horizontal
        return sv
    }

    public class func vertical() -> Self {
        let sv = self.init()
        sv.axis = .vertical
        return sv
    }

    // MARK: - Chainable instance methods

    @discardableResult public func horizontal() -> Self { axis = .horizontal; return self }
    @discardableResult public func vertical()   -> Self { axis = .vertical;   return self }

    @discardableResult public func alignStart()  -> Self { alignment = .start;  return self }
    @discardableResult public func alignCenter() -> Self { alignment = .center; return self }
    @discardableResult public func alignEnd()    -> Self { alignment = .end;    return self }
    @discardableResult public func alignFill()   -> Self { alignment = .fill;   return self }

    @discardableResult public func justifyStart()        -> Self { justifyContent = .start;        return self }
    @discardableResult public func justifyCenter()       -> Self { justifyContent = .center;       return self }
    @discardableResult public func justifyEnd()          -> Self { justifyContent = .end;          return self }
    @discardableResult public func justifyFill()         -> Self { justifyContent = .fill;         return self }
    @discardableResult public func justifyFillEqually()  -> Self { justifyContent = .fillEqually;  return self }
    @discardableResult public func justifySpaceBetween() -> Self { justifyContent = .spaceBetween; return self }
    @discardableResult public func justifySpaceAround()  -> Self { justifyContent = .spaceAround;  return self }
    @discardableResult public func justifySpaceEvenly()  -> Self { justifyContent = .spaceEvenly;  return self }

    @discardableResult
    public func inset(_ top: CGFloat, _ leading: CGFloat, _ bottom: CGFloat, _ trailing: CGFloat) -> Self {
        insets = UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
        return self
    }

    /// 水平方向内边距
    @discardableResult
    public func hInset(_ leading: CGFloat, _ trailing: CGFloat) -> Self {
        insets = UIEdgeInsets(top: insets.top, left: leading, bottom: insets.bottom, right: trailing)
        return self
    }

    /// 垂直方向内边距
    @discardableResult
    public func vInset(_ top: CGFloat, _ bottom: CGFloat) -> Self {
        insets = UIEdgeInsets(top: top, left: insets.left, bottom: bottom, right: insets.right)
        return self
    }

    @discardableResult public func space(_ s: CGFloat) -> Self { spacing = s; return self }

    /// 给最后添加的 view 设置间距
    @discardableResult
    public func insertSpace(_ s: CGFloat) -> Self { allViews.last?.hmFlex.spacing = s; return self }
    @discardableResult
    public func insertMinSpace(_ s: CGFloat) -> Self { allViews.last?.hmFlex.minSpacing = s; return self }
    @discardableResult
    public func insertMaxSpace(_ s: CGFloat) -> Self { allViews.last?.hmFlex.maxSpacing = s; return self }
    @discardableResult
    public func insertFlexSpace(_ flexible: Bool) -> Self { allViews.last?.hmFlex.isFlexSpace = flexible; return self }

    /// 条件间距：仅在 condition 为 true 时给最后添加的视图设置间距
    @discardableResult
    public func insertSpaceIf(_ condition: Bool, _ s: CGFloat) -> Self {
        if condition { allViews.last?.hmFlex.spacing = s }
        return self
    }

    // MARK: - Layout animation

    /// 在 changes 闭包内修改布局属性，并以动画方式过渡到新布局。
    /// - Parameters:
    ///   - duration: 动画时长
    ///   - changes:  在此闭包内执行布局变更（addView / removeView / spacing 修改等）
    @discardableResult
    public func animateLayoutChanges(duration: TimeInterval, _ changes: () -> Void) -> Self {
        changes()
        UIView.animate(withDuration: duration) { self.superview?.layoutIfNeeded() }
        return self
    }

    // MARK: - Separator

    public func moveArrangedSubview(_ view: UIView, to index: Int) {
        guard allViewsSet.contains(ObjectIdentifier(view)) else { return }
        let clamped = max(0, min(index, allViews.count - 1))
        allViews.removeAll { $0 === view }
        allViews.insert(view, at: clamped)
        guard !view.isHidden else { return }
        markedDirty = true
        setNeedsUpdateConstraints()
    }

    // MARK: - Separator

    /// 在当前末尾插入一条分隔线视图，交叉轴方向自动填满。
    /// - Parameters:
    ///   - color:     分隔线颜色，默认 12% 不透明黑色
    ///   - thickness: 主轴方向宽度/高度，默认 0.5pt（1px on @2x）
    @discardableResult
    public func addSeparator(color: UIColor = UIColor(white: 0, alpha: 0.12),
                             thickness: CGFloat = 0.5) -> Self {
        let sep = UIView()
        sep.backgroundColor = color
        addArrangedSubview(sep)
        if axis == .horizontal {
            sep.hmFlex.w(thickness).alignFill()
        } else {
            sep.hmFlex.h(thickness).alignFill()
        }
        return self
    }

    // MARK: - Add view chainable methods

    @discardableResult
    public func addView(_ view: UIView) -> Self { addArrangedSubview(view); return self }

    @discardableResult
    public func addViewIf(_ condition: Bool, _ view: UIView) -> Self {
        if condition { addArrangedSubview(view) }; return self
    }

    @discardableResult
    public func addViewMakeIf(_ condition: Bool, _ make: (HaomissyouBaseStackView) -> UIView?) -> Self {
        if condition, let v = make(self) { addArrangedSubview(v) }; return self
    }

    @discardableResult
    public func addViewMake(_ make: (HaomissyouBaseStackView) -> UIView?) -> Self {
        if let v = make(self) { addArrangedSubview(v) }; return self
    }

    @discardableResult
    public func addViewLayout(_ view: UIView, layout: (UIView, HaomissyouFlexItem) -> Void) -> Self {
        addArrangedSubview(view, layout: layout); return self
    }

    @discardableResult
    public func moveView(_ view: UIView, to index: Int) -> Self {
        moveArrangedSubview(view, to: index); return self
    }

    // MARK: - Per-view spacing chainable methods

    @discardableResult
    public func spacingAfter(_ spacing: CGFloat, view: UIView) -> Self {
        setCustomSpacing(spacing, afterView: view); return self
    }
    @discardableResult
    public func minSpacingAfter(_ minSpacing: CGFloat, view: UIView) -> Self {
        setCustomMinSpacing(minSpacing, afterView: view); return self
    }
    @discardableResult
    public func maxSpacingAfter(_ maxSpacing: CGFloat, view: UIView) -> Self {
        setCustomMaxSpacing(maxSpacing, afterView: view); return self
    }
    @discardableResult
    public func flexFor(_ flex: Int, view: UIView) -> Self { setFlex(flex, forView: view); return self }
    @discardableResult
    public func flexSpacingAfter(_ flexible: Bool, view: UIView) -> Self {
        setFlexibleSpacing(flexible, afterView: view); return self
    }
    @discardableResult
    public func alignFor(_ alignment: HaomissyouAlign, view: UIView) -> Self {
        setAlignment(alignment, forView: view); return self
    }
    @discardableResult
    public func alignStartSpacingFor(_ spacing: CGFloat, view: UIView) -> Self {
        setAlignmentStartSpacing(spacing, forView: view); return self
    }
    @discardableResult
    public func alignEndSpacingFor(_ spacing: CGFloat, view: UIView) -> Self {
        setAlignmentEndSpacing(spacing, forView: view); return self
    }

    // MARK: - Assign pointer

    @discardableResult
    public func assignToPtr(_ ptr: UnsafeMutablePointer<HaomissyouBaseStackView?>?) -> Self {
        ptr?.pointee = self; return self
    }

    /// 安全的 inout 版本，推荐优先使用此方法替代 `assignToPtr`
    @discardableResult
    public func assign(to ref: inout HaomissyouBaseStackView?) -> Self {
        ref = self; return self
    }

    // MARK: - Appearance / interaction

    @discardableResult
    public func tapAction(_ action: @escaping (HaomissyouBaseStackView) -> Void) -> Self {
        isUserInteractionEnabled = true
        _hmTapAction = action
        if gestureRecognizers?.contains(where: { $0 is UITapGestureRecognizer }) != true {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(_hmHandleTap(_:))))
        }
        return self
    }

    @discardableResult public func visibility(_ visible: Bool) -> Self { isHidden = !visible; return self }
    @discardableResult public func alphaValue(_ a: CGFloat)    -> Self { alpha = a;           return self }
    @discardableResult public func userActive(_ enabled: Bool) -> Self { isUserInteractionEnabled = enabled; return self }

    @discardableResult
    public func bgColor(_ colorOrHex: Any) -> Self {
        backgroundColor = _hmColorFromAny(colorOrHex); return self
    }

    @discardableResult
    public func bgColor(_ color: UIColor) -> Self {
        backgroundColor = color; return self
    }

    @discardableResult
    public func corner(_ radius: CGFloat) -> Self {
        layer.cornerRadius = radius; layer.masksToBounds = radius > 0; return self
    }

    @discardableResult
    public func corners(_ mask: CACornerMask) -> Self {
        layer.maskedCorners = mask; return self
    }

    @discardableResult
    public func borderColor(_ colorOrHex: Any) -> Self {
        layer.borderColor = _hmColorFromAny(colorOrHex)?.cgColor; return self
    }

    @discardableResult
    public func borderColor(_ color: UIColor) -> Self {
        layer.borderColor = color.cgColor; return self
    }

    @discardableResult
    public func borderWidth(_ width: CGFloat) -> Self { layer.borderWidth = width; return self }

    @discardableResult
    public func border(_ width: CGFloat, _ colorOrHex: Any) -> Self {
        borderWidth(width); borderColor(colorOrHex); return self
    }

    @discardableResult
    public func border(_ width: CGFloat, _ color: UIColor) -> Self {
        borderWidth(width); borderColor(color); return self
    }

    @discardableResult
    public func shColor(_ colorOrHex: Any) -> Self {
        layer.shadowColor   = _hmColorFromAny(colorOrHex)?.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius  = 8
        layer.shadowOffset  = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
        return self
    }

    @discardableResult
    public func shColor(_ color: UIColor) -> Self {
        layer.shadowColor   = color.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius  = 8
        layer.shadowOffset  = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
        return self
    }

    @discardableResult
    public func shOffset(_ width: CGFloat, _ height: CGFloat) -> Self {
        layer.shadowOffset = CGSize(width: width, height: height); return self
    }

    @discardableResult
    public func shRadius(_ radius: CGFloat) -> Self { layer.shadowRadius = radius; return self }

    @discardableResult
    public func shOpacity(_ opacity: CGFloat) -> Self {
        layer.shadowOpacity = Float(opacity); layer.masksToBounds = false; return self
    }

    @discardableResult
    public func masksToBounds(_ masks: Bool) -> Self { layer.masksToBounds = masks; return self }

    // MARK: - Layout constraints (self in superview)

    @discardableResult
    public func centerX(_ x: CGFloat) -> Self {
        guard let sv = superview else { return self }
        centerXAnchor.constraint(equalTo: sv.centerXAnchor, constant: x).isActive = true
        return self
    }

    @discardableResult
    public func centerY(_ y: CGFloat) -> Self {
        guard let sv = superview else { return self }
        centerYAnchor.constraint(equalTo: sv.centerYAnchor, constant: y).isActive = true
        return self
    }

    @discardableResult
    public func centerOffset(_ x: CGFloat, _ y: CGFloat) -> Self { centerX(x); centerY(y); return self }

    @discardableResult
    public func top(_ t: CGFloat) -> Self {
        guard let sv = superview else { return self }
        topAnchor.constraint(equalTo: sv.topAnchor, constant: t).isActive = true; return self
    }

    @discardableResult
    public func leading(_ l: CGFloat) -> Self {
        guard let sv = superview else { return self }
        leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: l).isActive = true; return self
    }

    @discardableResult
    public func bottom(_ b: CGFloat) -> Self {
        guard let sv = superview else { return self }
        bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: -b).isActive = true; return self
    }

    @discardableResult
    public func trailing(_ t: CGFloat) -> Self {
        guard let sv = superview else { return self }
        trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: -t).isActive = true; return self
    }

    @discardableResult
    public func height(_ h: CGFloat) -> Self { hmSetHeight(h); return self }

    @discardableResult
    public func width(_ w: CGFloat) -> Self { hmSetWidth(w); return self }

    @discardableResult
    public func size(_ w: CGFloat, _ h: CGFloat) -> Self { hmSetWidth(w); hmSetHeight(h); return self }

    @discardableResult
    public func square(_ s: CGFloat) -> Self { size(s, s); return self }

    @discardableResult
    public func edge(_ top: CGFloat, _ leading: CGFloat, _ bottom: CGFloat, _ trailing: CGFloat) -> Self {
        guard let sv = superview else { return self }
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: sv.topAnchor, constant: top),
            leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: leading),
            bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: -bottom),
            trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: -trailing)
        ])
        return self
    }

    @discardableResult
    public func edgesZero() -> Self { edge(0, 0, 0, 0); return self }

    @discardableResult
    public func addTo(_ superview: UIView) -> Self { superview.addSubview(self); return self }

    @discardableResult
    public func addToFull(_ superview: UIView) -> Self {
        superview.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        edgesZero()
        return self
    }
}

// MARK: - HaomissyouStackView

/// 具体 StackView 实现类，继承 `HaomissyouBaseStackView`，无额外扩展。
///
/// 所有功能均由基类提供，此类作为对外暴露的公开类型，
/// 方便子类化或在不影响基类的情况下添加自定义行为。
open class HaomissyouStackView: HaomissyouBaseStackView {}
