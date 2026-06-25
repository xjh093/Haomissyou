//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-23
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit
import ObjectiveC

// MARK: - Private gesture target (mirrors _OkidokiGestureTarget)

/// 持有 block 并作为手势 target/action 的桥接对象。
/// 通过 objc_setAssociatedObject 绑定到手势识别器上，随手势一起释放。
private final class _HaomissyouGestureTarget: NSObject {
    private let block: (UIGestureRecognizer) -> Void
    init(_ block: @escaping (UIGestureRecognizer) -> Void) {
        self.block = block
    }
    @objc func invoke(_ gesture: UIGestureRecognizer) {
        block(gesture)
    }
}

/// Associated object key：每个手势识别器实例各自持有一个 target，key 相同无冲突。
private var _gestureTargetKey: UInt8 = 0

// MARK: - Gesture

public extension Haomissyou {

    // MARK: tapGesture

    /// 添加点击手势，对应 ObjC `.tapGesture(^(UITapGestureRecognizer *tap){...})`
    @discardableResult
    func tapGesture(_ block: @escaping (UITapGestureRecognizer) -> Void) -> Haomissyou {
        view.isUserInteractionEnabled = true
        let target = _HaomissyouGestureTarget { block($0 as! UITapGestureRecognizer) }
        let tap = UITapGestureRecognizer(target: target, action: #selector(_HaomissyouGestureTarget.invoke(_:)))
        view.addGestureRecognizer(tap)
        objc_setAssociatedObject(tap, &_gestureTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    // MARK: longPressGesture

    /// 添加长按手势，对应 ObjC `.longPressGesture(^(UILongPressGestureRecognizer *longPress){...})`
    @discardableResult
    func longPressGesture(_ block: @escaping (UILongPressGestureRecognizer) -> Void) -> Haomissyou {
        view.isUserInteractionEnabled = true
        let target = _HaomissyouGestureTarget { block($0 as! UILongPressGestureRecognizer) }
        let longPress = UILongPressGestureRecognizer(target: target, action: #selector(_HaomissyouGestureTarget.invoke(_:)))
        view.addGestureRecognizer(longPress)
        objc_setAssociatedObject(longPress, &_gestureTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    // MARK: swipeGesture

    /// 添加滑动手势。添加后让已有的 Pan 手势等待 Swipe 失败再触发（与 ObjC 一致）。
    @discardableResult
    func swipeGesture(_ direction: UISwipeGestureRecognizer.Direction,
                      _ block: @escaping (UISwipeGestureRecognizer) -> Void) -> Haomissyou {
        view.isUserInteractionEnabled = true
        let target = _HaomissyouGestureTarget { block($0 as! UISwipeGestureRecognizer) }
        let swipe = UISwipeGestureRecognizer(target: target, action: #selector(_HaomissyouGestureTarget.invoke(_:)))
        swipe.direction = direction
        view.addGestureRecognizer(swipe)
        objc_setAssociatedObject(swipe, &_gestureTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 让已有的 Pan 手势在 Swipe 失败后再触发
        for gesture in view.gestureRecognizers ?? [] {
            if gesture is UIPanGestureRecognizer {
                gesture.require(toFail: swipe)
            }
        }
        return self
    }

    // MARK: panGesture

    /// 添加拖拽手势。添加后让 Pan 手势等待已有的 Swipe 手势失败再触发（与 ObjC 一致）。
    @discardableResult
    func panGesture(_ block: @escaping (UIPanGestureRecognizer) -> Void) -> Haomissyou {
        view.isUserInteractionEnabled = true
        let target = _HaomissyouGestureTarget { block($0 as! UIPanGestureRecognizer) }
        let pan = UIPanGestureRecognizer(target: target, action: #selector(_HaomissyouGestureTarget.invoke(_:)))
        view.addGestureRecognizer(pan)
        objc_setAssociatedObject(pan, &_gestureTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 让 Pan 在已有的 Swipe 手势失败后再触发
        for gesture in view.gestureRecognizers ?? [] {
            if gesture is UISwipeGestureRecognizer {
                pan.require(toFail: gesture)
            }
        }
        return self
    }

    // MARK: pinchGesture

    /// 添加捏合手势，对应 ObjC `.pinchGesture(^(UIPinchGestureRecognizer *pinch){...})`
    @discardableResult
    func pinchGesture(_ block: @escaping (UIPinchGestureRecognizer) -> Void) -> Haomissyou {
        view.isUserInteractionEnabled = true
        let target = _HaomissyouGestureTarget { block($0 as! UIPinchGestureRecognizer) }
        let pinch = UIPinchGestureRecognizer(target: target, action: #selector(_HaomissyouGestureTarget.invoke(_:)))
        view.addGestureRecognizer(pinch)
        objc_setAssociatedObject(pinch, &_gestureTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    // MARK: rotationGesture

    /// 添加旋转手势，对应 ObjC `.rotationGesture(^(UIRotationGestureRecognizer *rotation){...})`
    @discardableResult
    func rotationGesture(_ block: @escaping (UIRotationGestureRecognizer) -> Void) -> Haomissyou {
        view.isUserInteractionEnabled = true
        let target = _HaomissyouGestureTarget { block($0 as! UIRotationGestureRecognizer) }
        let rotation = UIRotationGestureRecognizer(target: target, action: #selector(_HaomissyouGestureTarget.invoke(_:)))
        view.addGestureRecognizer(rotation)
        objc_setAssociatedObject(rotation, &_gestureTargetKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return self
    }

    // MARK: removeGesture

    /// 移除第一个匹配类型的手势，对应 ObjC `.removeGesture([UITapGestureRecognizer class])`
    @discardableResult
    func removeGesture(_ gestureClass: AnyClass) -> Haomissyou {
        if let gesture = view.gestureRecognizers?.first(where: { type(of: $0) == gestureClass }) {
            view.removeGestureRecognizer(gesture)
        }
        return self
    }

    /// 移除指定的手势实例
    /// 用法：`tap.view?.haomissyou.removeGesture(tap)`
    @discardableResult
    func removeGesture(_ gesture: UIGestureRecognizer) -> Haomissyou {
        view.removeGestureRecognizer(gesture)
        return self
    }

    // MARK: removeAllGestures

    /// 移除所有手势，对应 ObjC `.removeAllGestures()`
    @discardableResult
    func removeAllGestures() -> Haomissyou {
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }
        return self
    }
}
