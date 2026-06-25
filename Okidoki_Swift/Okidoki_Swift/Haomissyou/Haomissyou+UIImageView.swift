//
//  Haomissyou.swift
//  Swift version of Okidoki
//
//  Created by HaoCold on 2026-06-24
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

public extension Haomissyou {

    // MARK: image

    /// UIImageView: image — UIImage / String (imageNamed)
    /// UIButton: setImage for .normal state
    @discardableResult
    func image(_ value: Any) -> Haomissyou {
        if let iv = view as? UIImageView {
            if let img = value as? UIImage {
                iv.image = img
            } else if let name = value as? String {
                iv.image = UIImage(named: name)
            }
        } else if let btn = view as? UIButton {
            if let img = value as? UIImage {
                btn.setImage(img, for: .normal)
            } else if let name = value as? String {
                btn.setImage(UIImage(named: name), for: .normal)
            }
        }
        return self
    }

    // MARK: highlightedImage

    /// UIImageView: highlightedImage — UIImage / String (imageNamed)
    /// UIButton: setImage for .highlighted state
    @discardableResult
    func highlightedImage(_ value: Any) -> Haomissyou {
        if let iv = view as? UIImageView {
            if let img = value as? UIImage {
                iv.highlightedImage = img
            } else if let name = value as? String {
                iv.highlightedImage = UIImage(named: name)
            }
        } else if let btn = view as? UIButton {
            if let img = value as? UIImage {
                btn.setImage(img, for: .highlighted)
            } else if let name = value as? String {
                btn.setImage(UIImage(named: name), for: .highlighted)
            }
        }
        return self
    }

    // MARK: imageForTintColor

    /// UIImageView: image(渲染模式 alwaysTemplate) + tintColor
    /// image: UIImage / String, color: UIColor / hex String
    @discardableResult
    func imageForTintColor(_ image: Any, _ color: Any) -> Haomissyou {
        guard let iv = view as? UIImageView else { return self }
        if let c = UIColor.haomissyouColor(color) {
            iv.tintColor = c
        }
        if let img = image as? UIImage {
            iv.image = img.withRenderingMode(.alwaysTemplate)
        } else if let name = image as? String,
                  let img = UIImage(named: name) {
            iv.image = img.withRenderingMode(.alwaysTemplate)
        }
        return self
    }
}
