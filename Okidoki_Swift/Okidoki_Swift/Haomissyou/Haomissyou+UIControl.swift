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

// MARK: - Private control event target

/// 持有 block 并作为 UIControl target/action 的桥接对象。
/// 通过关联字典绑定到控件上，随控件一起释放。
private final class _HaomissyouControlTarget: NSObject {
    private let block: (UIControl) -> Void
    init(_ block: @escaping (UIControl) -> Void) { self.block = block }
    @objc func invoke(_ sender: UIControl) { block(sender) }
}

/// 存储所有 control event targets 的字典 key。
/// 字典结构：[NSNumber(rawValue) : NSMutableArray<_HaomissyouControlTarget>]
private var _controlTargetsKey: UInt8 = 0

private func _getControlTargets(_ control: UIControl) -> NSMutableDictionary {
    if let dict = objc_getAssociatedObject(control, &_controlTargetsKey) as? NSMutableDictionary {
        return dict
    }
    let dict = NSMutableDictionary()
    objc_setAssociatedObject(control, &_controlTargetsKey, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return dict
}

// MARK: - UIControl

public extension Haomissyou {

    // MARK: enabled

    /// UIControl.isEnabled — Bool / NSNumber / String
    @discardableResult
    func enabled(_ value: Any) -> Haomissyou {
        guard let ctrl = view as? UIControl else { return self }
        switch value {
        case let b as Bool:      ctrl.isEnabled = b
        case let n as NSNumber:  ctrl.isEnabled = n.boolValue
        case let s as String:    ctrl.isEnabled = (s as NSString).boolValue
        default: break
        }
        return self
    }

    // MARK: selected

    /// UIControl.isSelected — Bool / NSNumber / String
    @discardableResult
    func selected(_ value: Any) -> Haomissyou {
        guard let ctrl = view as? UIControl else { return self }
        switch value {
        case let b as Bool:      ctrl.isSelected = b
        case let n as NSNumber:  ctrl.isSelected = n.boolValue
        case let s as String:    ctrl.isSelected = (s as NSString).boolValue
        default: break
        }
        return self
    }

    // MARK: highlighted

    /// isHighlighted — UILabel / UIImageView / UIControl 及子类
    /// Bool / NSNumber / String
    @discardableResult
    func highlighted(_ value: Any) -> Haomissyou {
        let b: Bool
        switch value {
        case let bv as Bool:     b = bv
        case let n as NSNumber:  b = n.boolValue
        case let s as String:    b = (s as NSString).boolValue
        default: return self
        }
        if let v = view as? UILabel          { v.isHighlighted = b }
        else if let v = view as? UIImageView { v.isHighlighted = b }
        else if let v = view as? UIControl   { v.isHighlighted = b }
        return self
    }

    // MARK: contentVerticalAlignment

    /// UIControl.contentVerticalAlignment — NSNumber / String (0–3)
    @discardableResult
    func contentVerticalAlignment(_ value: Any) -> Haomissyou {
        guard let ctrl = view as? UIControl else { return self }
        let raw: Int
        switch value {
        case let n as NSNumber: raw = n.intValue
        case let s as String:   raw = Int(s) ?? 0
        default: return self
        }
        if let alignment = UIControl.ContentVerticalAlignment(rawValue: raw) {
            ctrl.contentVerticalAlignment = alignment
        }
        return self
    }

    // MARK: contentHorizontalAlignment

    /// UIControl.contentHorizontalAlignment — NSNumber / String (0–5)
    @discardableResult
    func contentHorizontalAlignment(_ value: Any) -> Haomissyou {
        guard let ctrl = view as? UIControl else { return self }
        let raw: Int
        switch value {
        case let n as NSNumber: raw = n.intValue
        case let s as String:   raw = Int(s) ?? 0
        default: return self
        }
        if let alignment = UIControl.ContentHorizontalAlignment(rawValue: raw) {
            ctrl.contentHorizontalAlignment = alignment
        }
        return self
    }

    // MARK: addControlEvent

    /// 为指定 controlEvents 添加 block 回调。
    /// 可多次调用同一 event，所有 block 均会被执行。
    @discardableResult
    func addControlEvent(_ controlEvents: UIControl.Event,
                         _ block: @escaping (_ sender: UIControl) -> Void) -> Haomissyou {
        guard let ctrl = view as? UIControl else { return self }
        let target = _HaomissyouControlTarget(block)
        ctrl.addTarget(target, action: #selector(_HaomissyouControlTarget.invoke(_:)),
                       for: controlEvents)
        // 用 NSNumber 包装 rawValue 作为字典 key，持有 target 保证生命周期
        let dict = _getControlTargets(ctrl)
        let key = NSNumber(value: controlEvents.rawValue)
        if let arr = dict[key] as? NSMutableArray {
            arr.add(target)
        } else {
            dict[key] = NSMutableArray(object: target)
        }
        return self
    }

    // MARK: removeControlEvent

    /// 移除指定 controlEvents 对应的所有 block 回调。
    @discardableResult
    func removeControlEvent(_ controlEvents: UIControl.Event) -> Haomissyou {
        guard let ctrl = view as? UIControl else { return self }
        let dict = _getControlTargets(ctrl)
        let key = NSNumber(value: controlEvents.rawValue)
        if let arr = dict[key] as? NSMutableArray {
            for case let target as _HaomissyouControlTarget in arr {
                ctrl.removeTarget(target,
                                  action: #selector(_HaomissyouControlTarget.invoke(_:)),
                                  for: controlEvents)
            }
            arr.removeAllObjects()
        }
        return self
    }

    // MARK: removeAllControlEvents

    /// 移除所有 target/action（包括非 block 方式添加的）并清空关联存储。
    @discardableResult
    func removeAllControlEvents() -> Haomissyou {
        guard let ctrl = view as? UIControl else { return self }
        ctrl.removeTarget(nil, action: nil, for: .allEvents)
        // 清空 block targets 字典
        if let dict = objc_getAssociatedObject(ctrl, &_controlTargetsKey) as? NSMutableDictionary {
            dict.removeAllObjects()
        }
        return self
    }
}
