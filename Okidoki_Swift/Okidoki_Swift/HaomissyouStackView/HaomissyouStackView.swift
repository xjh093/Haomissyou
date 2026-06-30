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

// MARK: - Color helper

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

/// RTL-aware scroll view wrapper
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

/// Base stack view
open class HaomissyouBaseStackView: UIView {

    // MARK: - Public properties

    /// 水平排列还是垂直排列，默认水平排列
    public var axis: HaomissyouStackViewAxis = .horizontal {
        didSet { guard axis != oldValue else { return }; markedDirty = true; setNeedsUpdateConstraints() }
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
        guard !allViews.contains(view) else { return }
        view.hmFlex.stackView = self
        allViews.append(view)
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
        guard !allViews.contains(view) else { return }
        adjustNestedStackView(view)
        addSubview(view)
        view.hmFlex.stackView = self
        allViews.insert(view, at: index)
        adjustLabelCompression(view)
        guard !view.isHidden else { return }
        markedDirty = true
        setNeedsUpdateConstraints()
    }

    public func removeArrangedSubview(_ view: UIView) {
        guard allViews.contains(view) else { return }
        view.removeFromSuperview()
        allViews.removeAll { $0 === view }
        markedDirty = true
        setNeedsUpdateConstraints()
    }

    // MARK: - Custom spacing

    public func setCustomSpacing(_ spacing: CGFloat, afterView view: UIView) {
        guard allViews.contains(view) else { return }
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
        guard allViews.contains(view) else { return }
        let cfg = view.hmFlex
        guard cfg.minSpacing != minSpacing else { return }
        cfg.setMinSpacingWithoutUpdate(minSpacing)
        guard !view.isHidden else { return }
        guard !layoutManager.constraints.isEmpty else { return }
        let arr = filterConstraints { $0.hmItem.view === view && $0.hmItem.type == .minSpacing }
        if arr.count > 0 {
            arr.first?.constant = max(0, minSpacing)
            arr.last?.constant  = max(0, minSpacing)
        } else {
            markedDirty = true; setNeedsUpdateConstraints()
        }
    }

    public func setCustomMaxSpacing(_ maxSpacing: CGFloat, afterView view: UIView) {
        guard allViews.contains(view) else { return }
        let cfg = view.hmFlex
        guard cfg.maxSpacing != maxSpacing else { return }
        cfg.setMaxSpacingWithoutUpdate(maxSpacing)
        guard !view.isHidden else { return }
        guard !layoutManager.constraints.isEmpty else { return }
        let arr = filterConstraints { $0.hmItem.view === view && $0.hmItem.type == .maxSpacing }
        if arr.count > 0 {
            arr.first?.constant = max(0, maxSpacing)
        } else {
            markedDirty = true; setNeedsUpdateConstraints()
        }
    }

    public func setFlex(_ flex: Int, forView view: UIView) {
        guard allViews.contains(view), flex >= 0 else { return }
        let cfg = view.hmFlex
        guard cfg.flexValue != flex else { return }
        cfg.flexValue = flex
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setFlexibleSpacing(_ flexible: Bool, afterView view: UIView) {
        guard allViews.contains(view) else { return }
        guard flexible != view.hmFlex.isFlexSpace else { return }
        view.hmFlex.isFlexSpace = flexible
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setAlignment(_ alignment: HaomissyouAlign, forView view: UIView) {
        guard allViews.contains(view) else { return }
        let cfg = view.hmFlex
        guard alignment != cfg.alignSelf else { return }
        cfg.alignSelf = alignment
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setAlignmentStartSpacing(_ spacing: CGFloat, forView view: UIView) {
        guard allViews.contains(view) else { return }
        let cfg = view.hmFlex
        guard spacing != cfg.startSpacing else { return }
        cfg.startSpacing = spacing
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    public func setAlignmentEndSpacing(_ spacing: CGFloat, forView view: UIView) {
        guard allViews.contains(view) else { return }
        let cfg = view.hmFlex
        guard cfg.endSpacing != spacing else { return }
        cfg.endSpacing = spacing
        guard !view.isHidden else { return }
        markedDirty = true; setNeedsUpdateConstraints()
    }

    // MARK: - Layout

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
    }

    open override var intrinsicContentSize: CGSize { .zero }

    // MARK: - Wrap in scroll view

    public func wrapScrollView() -> HaomissyouScrollView {
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

    private func adjustLabelCompression(_ view: UIView) {
        guard let label = view as? UILabel, label.numberOfLines != 1 else { return }
        let axis: NSLayoutConstraint.Axis = self.axis == .horizontal ? .horizontal : .vertical
        let priority = label.contentCompressionResistancePriority(for: axis)
        if priority == .defaultHigh {
            label.setContentCompressionResistancePriority(priority - 0.1, for: axis)
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

/// Concrete stack view
open class HaomissyouStackView: HaomissyouBaseStackView {}
