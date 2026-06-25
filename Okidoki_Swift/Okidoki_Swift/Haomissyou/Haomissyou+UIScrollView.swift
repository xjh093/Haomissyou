//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-24
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit
import ObjectiveC

// MARK: - Delegate Handler

/// 代理转发对象，存储所有 UIScrollViewDelegate 回调 block。
/// 通过 associated object 挂载到 UIScrollView 上，保持 strong 引用。
private final class _HaomissyouScrollViewDelegate: NSObject, UIScrollViewDelegate {

    var didScrollBlock:                    ((UIScrollView) -> Void)?
    var didZoomBlock:                      ((UIScrollView) -> Void)?
    var willBeginDraggingBlock:            ((UIScrollView) -> Void)?
    var willEndDraggingBlock:              ((UIScrollView, CGPoint) -> Void)?
    var didEndDraggingBlock:               ((UIScrollView, Bool) -> Void)?
    var willBeginDeceleratingBlock:        ((UIScrollView) -> Void)?
    var didEndDeceleratingBlock:           ((UIScrollView) -> Void)?
    var didEndScrollingAnimationBlock:     ((UIScrollView) -> Void)?
    var viewForZoomingBlock:               ((UIScrollView) -> UIView?)?
    var willBeginZoomingBlock:             ((UIScrollView, UIView?) -> Void)?
    var didEndZoomingBlock:                ((UIScrollView, UIView?, CGFloat) -> Void)?
    var shouldScrollToTopBlock:            ((UIScrollView) -> Bool)?
    var didScrollToTopBlock:               ((UIScrollView) -> Void)?
    var didChangeAdjustedContentInsetBlock:((UIScrollView) -> Void)?

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollBlock?(scrollView)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        didZoomBlock?(scrollView)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        willBeginDraggingBlock?(scrollView)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        willEndDraggingBlock?(scrollView, velocity)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDraggingBlock?(scrollView, decelerate)
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        willBeginDeceleratingBlock?(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDeceleratingBlock?(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didEndScrollingAnimationBlock?(scrollView)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        viewForZoomingBlock?(scrollView)
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        willBeginZoomingBlock?(scrollView, view)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        didEndZoomingBlock?(scrollView, view, scale)
    }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        shouldScrollToTopBlock?(scrollView) ?? true
    }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        didScrollToTopBlock?(scrollView)
    }
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        didChangeAdjustedContentInsetBlock?(scrollView)
    }
}

// MARK: - Associated Object Key

private var _scrollViewDelegateKey: UInt8 = 0

// MARK: - Private helper

private func _scrollViewDelegate(for sv: UIScrollView) -> _HaomissyouScrollViewDelegate {
    if let existing = objc_getAssociatedObject(sv, &_scrollViewDelegateKey)
        as? _HaomissyouScrollViewDelegate {
        return existing
    }
    let handler = _HaomissyouScrollViewDelegate()
    objc_setAssociatedObject(sv, &_scrollViewDelegateKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    sv.delegate = handler
    return handler
}

// MARK: - UIScrollView Properties

public extension Haomissyou {

    // MARK: contentOffset

    /// contentOffset — NSValue(CGPoint) / String("{{x,y}}")
    @discardableResult
    func contentOffset(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        if let v = value as? NSValue {
            sv.contentOffset = v.cgPointValue
        } else if let s = value as? String {
            sv.contentOffset = NSCoder.cgPoint(for: s)
        }
        return self
    }

    // MARK: contentSize

    /// contentSize — NSValue(CGSize) / String("{w,h}")
    @discardableResult
    func contentSize(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        if let v = value as? NSValue {
            sv.contentSize = v.cgSizeValue
        } else if let s = value as? String {
            sv.contentSize = NSCoder.cgSize(for: s)
        }
        return self
    }

    // MARK: contentInset

    /// contentInset — NSValue(UIEdgeInsets) / String("{t,l,b,r}")
    @discardableResult
    func contentInset(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        if let v = value as? NSValue {
            sv.contentInset = v.uiEdgeInsetsValue
        } else if let s = value as? String {
            sv.contentInset = NSCoder.uiEdgeInsets(for: s)
        }
        return self
    }

    // MARK: directionalLockEnabled

    /// directionalLockEnabled — Bool / NSNumber / String
    @discardableResult
    func directionalLockEnabled(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.isDirectionalLockEnabled = _boolValue(value)
        return self
    }

    // MARK: alwaysBounceVertical

    /// alwaysBounceVertical — Bool / NSNumber / String
    @discardableResult
    func alwaysBounceVertical(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.alwaysBounceVertical = _boolValue(value)
        return self
    }

    // MARK: alwaysBounceHorizontal

    /// alwaysBounceHorizontal — Bool / NSNumber / String
    @discardableResult
    func alwaysBounceHorizontal(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.alwaysBounceHorizontal = _boolValue(value)
        return self
    }

    // MARK: scrollEnabled

    /// scrollEnabled — Bool / NSNumber / String
    @discardableResult
    func scrollEnabled(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.isScrollEnabled = _boolValue(value)
        return self
    }

    // MARK: indicatorStyle

    /// indicatorStyle — NSNumber / String (0=default,1=black,2=white)
    @discardableResult
    func indicatorStyle(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        let raw: Int
        switch value {
        case let n as NSNumber: raw = n.intValue
        case let s as String:   raw = Int(s) ?? 0
        default: return self
        }
        sv.indicatorStyle = UIScrollView.IndicatorStyle(rawValue: raw) ?? .default
        return self
    }

    // MARK: delaysContentTouches

    /// delaysContentTouches — Bool / NSNumber / String
    @discardableResult
    func delaysContentTouches(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.delaysContentTouches = _boolValue(value)
        return self
    }

    // MARK: canCancelContentTouches

    /// canCancelContentTouches — Bool / NSNumber / String
    @discardableResult
    func canCancelContentTouches(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.canCancelContentTouches = _boolValue(value)
        return self
    }

    // MARK: minimumZoomScale

    /// minimumZoomScale — NSNumber / String
    @discardableResult
    func minimumZoomScale(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        switch value {
        case let n as NSNumber: sv.minimumZoomScale = CGFloat(n.doubleValue)
        case let s as String:   if let d = Double(s) { sv.minimumZoomScale = CGFloat(d) }
        default: break
        }
        return self
    }

    // MARK: maximumZoomScale

    /// maximumZoomScale — NSNumber / String
    @discardableResult
    func maximumZoomScale(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        switch value {
        case let n as NSNumber: sv.maximumZoomScale = CGFloat(n.doubleValue)
        case let s as String:   if let d = Double(s) { sv.maximumZoomScale = CGFloat(d) }
        default: break
        }
        return self
    }

    // MARK: bouncesZoom

    /// bouncesZoom — Bool / NSNumber / String
    @discardableResult
    func bouncesZoom(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.bouncesZoom = _boolValue(value)
        return self
    }

    // MARK: scrollsToTop

    /// scrollsToTop — Bool / NSNumber / String
    @discardableResult
    func scrollsToTop(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.scrollsToTop = _boolValue(value)
        return self
    }

    // MARK: decelerationRate

    /// decelerationRate — NSNumber / String (raw float value)
    @discardableResult
    func decelerationRate(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        switch value {
        case let n as NSNumber: sv.decelerationRate = UIScrollView.DecelerationRate(rawValue: CGFloat(n.doubleValue))
        case let s as String:   if let d = Double(s) { sv.decelerationRate = UIScrollView.DecelerationRate(rawValue: CGFloat(d)) }
        default: break
        }
        return self
    }

    // MARK: zoomScale

    /// zoomScale — NSNumber / String
    @discardableResult
    func zoomScale(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        switch value {
        case let n as NSNumber: sv.zoomScale = CGFloat(n.doubleValue)
        case let s as String:   if let d = Double(s) { sv.zoomScale = CGFloat(d) }
        default: break
        }
        return self
    }

    // MARK: keyboardDismissMode

    /// keyboardDismissMode — NSNumber / String (0=none,1=onDrag,2=interactive)
    @discardableResult
    func keyboardDismissMode(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        let raw: Int
        switch value {
        case let n as NSNumber: raw = n.intValue
        case let s as String:   raw = Int(s) ?? 0
        default: return self
        }
        sv.keyboardDismissMode = UIScrollView.KeyboardDismissMode(rawValue: raw) ?? .none
        return self
    }

    // MARK: contentInsetAdjustmentBehavior

    /// contentInsetAdjustmentBehavior — NSNumber / String (iOS 11+)
    /// 0=automatic,1=scrollableAxes,2=never,3=always
    @discardableResult
    func contentInsetAdjustmentBehavior(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        let raw: Int
        switch value {
        case let n as NSNumber: raw = n.intValue
        case let s as String:   raw = Int(s) ?? 0
        default: return self
        }
        sv.contentInsetAdjustmentBehavior =
            UIScrollView.ContentInsetAdjustmentBehavior(rawValue: raw) ?? .automatic
        return self
    }

    // MARK: verticalScrollIndicatorInsets

    /// verticalScrollIndicatorInsets — NSValue(UIEdgeInsets) / String (iOS 11.1+)
    @discardableResult
    func verticalScrollIndicatorInsets(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        if let v = value as? NSValue {
            sv.verticalScrollIndicatorInsets = v.uiEdgeInsetsValue
        } else if let s = value as? String {
            sv.verticalScrollIndicatorInsets = NSCoder.uiEdgeInsets(for: s)
        }
        return self
    }

    // MARK: horizontalScrollIndicatorInsets

    /// horizontalScrollIndicatorInsets — NSValue(UIEdgeInsets) / String (iOS 11.1+)
    @discardableResult
    func horizontalScrollIndicatorInsets(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        if let v = value as? NSValue {
            sv.horizontalScrollIndicatorInsets = v.uiEdgeInsetsValue
        } else if let s = value as? String {
            sv.horizontalScrollIndicatorInsets = NSCoder.uiEdgeInsets(for: s)
        }
        return self
    }

    // MARK: verInd

    /// showsVerticalScrollIndicator — Bool / NSNumber / String
    @discardableResult
    func verInd(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.showsVerticalScrollIndicator = _boolValue(value)
        return self
    }

    // MARK: horInd

    /// showsHorizontalScrollIndicator — Bool / NSNumber / String
    @discardableResult
    func horInd(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.showsHorizontalScrollIndicator = _boolValue(value)
        return self
    }

    // MARK: paging

    /// pagingEnabled — Bool / NSNumber / String
    @discardableResult
    func paging(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.isPagingEnabled = _boolValue(value)
        return self
    }

    // MARK: bounces

    /// bounces — Bool / NSNumber / String
    @discardableResult
    func bounces(_ value: Any) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        sv.bounces = _boolValue(value)
        return self
    }
}

// MARK: - UIScrollView Delegate Blocks

public extension Haomissyou {

    /// scrollViewDidScroll delegate block
    @discardableResult
    func didScroll(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didScrollBlock = block
        return self
    }

    /// scrollViewDidZoom delegate block
    @discardableResult
    func didZoom(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didZoomBlock = block
        return self
    }

    /// scrollViewWillBeginDragging delegate block
    @discardableResult
    func willBeginDragging(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).willBeginDraggingBlock = block
        return self
    }

    /// scrollViewWillEndDragging:withVelocity: delegate block
    @discardableResult
    func willEndDragging(_ block: @escaping (UIScrollView, CGPoint) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).willEndDraggingBlock = block
        return self
    }

    /// scrollViewDidEndDragging:willDecelerate: delegate block
    @discardableResult
    func didEndDragging(_ block: @escaping (UIScrollView, Bool) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didEndDraggingBlock = block
        return self
    }

    /// scrollViewWillBeginDecelerating delegate block
    @discardableResult
    func willBeginDecelerating(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).willBeginDeceleratingBlock = block
        return self
    }

    /// scrollViewDidEndDecelerating delegate block
    @discardableResult
    func didEndDecelerating(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didEndDeceleratingBlock = block
        return self
    }

    /// scrollViewDidEndScrollingAnimation delegate block
    @discardableResult
    func didEndScrollingAnimation(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didEndScrollingAnimationBlock = block
        return self
    }

    /// viewForZoomingInScrollView delegate block
    @discardableResult
    func viewForZooming(_ block: @escaping (UIScrollView) -> UIView?) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).viewForZoomingBlock = block
        return self
    }

    /// scrollViewWillBeginZooming:withView: delegate block
    @discardableResult
    func willBeginZooming(_ block: @escaping (UIScrollView, UIView?) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).willBeginZoomingBlock = block
        return self
    }

    /// scrollViewDidEndZooming:withView:atScale: delegate block
    @discardableResult
    func didEndZooming(_ block: @escaping (UIScrollView, UIView?, CGFloat) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didEndZoomingBlock = block
        return self
    }

    /// scrollViewShouldScrollToTop delegate block
    @discardableResult
    func shouldScrollToTop(_ block: @escaping (UIScrollView) -> Bool) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).shouldScrollToTopBlock = block
        return self
    }

    /// scrollViewDidScrollToTop delegate block
    @discardableResult
    func didScrollToTop(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didScrollToTopBlock = block
        return self
    }

    /// scrollViewDidChangeAdjustedContentInset delegate block (iOS 11+)
    @discardableResult
    func didChangeAdjustedContentInset(_ block: @escaping (UIScrollView) -> Void) -> Haomissyou {
        guard let sv = view as? UIScrollView else { return self }
        _scrollViewDelegate(for: sv).didChangeAdjustedContentInsetBlock = block
        return self
    }
}

// MARK: - Private Bool helper

/// 统一从 Bool / NSNumber / String 取 boolValue
private func _boolValue(_ value: Any) -> Bool {
    switch value {
    case let b as Bool:     return b
    case let n as NSNumber: return n.boolValue
    case let s as String:   return (s as NSString).boolValue
    default: return false
    }
}
