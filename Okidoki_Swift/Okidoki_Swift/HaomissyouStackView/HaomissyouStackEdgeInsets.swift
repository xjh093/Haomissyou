//
//  HaomissyouStackEdgeInsets.swift
//
//  Created by HaoCold on 2026-06-30
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License

import UIKit

// MARK: - Private Guide Subclasses

private final class _HMTopGuide: HaomissyouLayoutGuide {}
private final class _HMLeadingGuide: HaomissyouLayoutGuide {}
private final class _HMBottomGuide: HaomissyouLayoutGuide {}
private final class _HMTrailingGuide: HaomissyouLayoutGuide {}

// MARK: - HaomissyouMargeGuide

final class HaomissyouMargeGuide: UILayoutGuide {

    weak var top: NSLayoutConstraint?
    weak var leading: NSLayoutConstraint?
    weak var bottom: NSLayoutConstraint?
    weak var trailing: NSLayoutConstraint?

    convenience init(view: UIView, insets: UIEdgeInsets) {
        self.init()
        view.addLayoutGuide(self)
        let topCons   = topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top)
        let leadCons  = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left)
        let botCons   = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        let trailCons = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right)
        NSLayoutConstraint.activate([topCons, leadCons, botCons, trailCons])
        self.top      = topCons
        self.leading  = leadCons
        self.bottom   = botCons
        self.trailing = trailCons
    }
}

// MARK: - HaomissyouStackEdgeInsets

final class HaomissyouStackEdgeInsets: NSObject {

    weak var stackView: HaomissyouBaseStackView?

    private var _topGuide: _HMTopGuide?
    private var _leadingGuide: _HMLeadingGuide?
    private var _bottomGuide: _HMBottomGuide?
    private var _trailingGuide: _HMTrailingGuide?
    private var _margeGuide: HaomissyouMargeGuide?

    var insets: UIEdgeInsets = .zero {
        didSet {
            guard let mg = _margeGuide, insets != oldValue else { return }
            mg.top?.constant      = insets.top
            mg.leading?.constant  = insets.left
            mg.bottom?.constant   = -insets.bottom
            mg.trailing?.constant = -insets.right
        }
    }

    // MARK: Justify-aware anchors

    var jLeadingAnchor: NSLayoutXAxisAnchor {
        guard let sv = stackView else { return margeGuide.leadingAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return leadingGuide.trailingAnchor
        default:
            return margeGuide.leadingAnchor
        }
    }

    var jTrailingAnchor: NSLayoutXAxisAnchor {
        guard let sv = stackView else { return margeGuide.trailingAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return trailingGuide.leadingAnchor
        default:
            return margeGuide.trailingAnchor
        }
    }

    var jTopAnchor: NSLayoutYAxisAnchor {
        guard let sv = stackView else { return margeGuide.topAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return topGuide.bottomAnchor
        default:
            return margeGuide.topAnchor
        }
    }

    var jBottomAnchor: NSLayoutYAxisAnchor {
        guard let sv = stackView else { return margeGuide.bottomAnchor }
        switch sv.justifyContent {
        case .center, .spaceAround, .spaceEvenly:
            return bottomGuide.topAnchor
        default:
            return margeGuide.bottomAnchor
        }
    }

    // MARK: Edge anchors

    var leadingAnchor:  NSLayoutXAxisAnchor { margeGuide.leadingAnchor  }
    var trailingAnchor: NSLayoutXAxisAnchor { margeGuide.trailingAnchor }
    var topAnchor:      NSLayoutYAxisAnchor { margeGuide.topAnchor      }
    var bottomAnchor:   NSLayoutYAxisAnchor { margeGuide.bottomAnchor   }
    var centerYAnchor:  NSLayoutYAxisAnchor { margeGuide.centerYAnchor  }
    var centerXAnchor:  NSLayoutXAxisAnchor { margeGuide.centerXAnchor  }

    var widthAnchors: [NSLayoutDimension] {
        [leadingGuide.widthAnchor, trailingGuide.widthAnchor]
    }

    var heightAnchors: [NSLayoutDimension] {
        [topGuide.heightAnchor, bottomGuide.heightAnchor]
    }

    // MARK: Cleanup

    func removeEdgeInsets() {
        _leadingGuide?.removeFromOwningView();  _leadingGuide  = nil
        _trailingGuide?.removeFromOwningView(); _trailingGuide = nil
        _topGuide?.removeFromOwningView();      _topGuide      = nil
        _bottomGuide?.removeFromOwningView();   _bottomGuide   = nil
    }

    // MARK: Lazy guides

    private var topGuide: _HMTopGuide {
        if let g = _topGuide { return g }
        let g = _HMTopGuide()
        stackView?.addLayoutGuide(g)
        g.topAnchor.constraint(equalTo: margeGuide.topAnchor).isActive = true
        _topGuide = g
        return g
    }

    private var leadingGuide: _HMLeadingGuide {
        if let g = _leadingGuide { return g }
        let g = _HMLeadingGuide()
        stackView?.addLayoutGuide(g)
        g.leadingAnchor.constraint(equalTo: margeGuide.leadingAnchor).isActive = true
        _leadingGuide = g
        return g
    }

    private var bottomGuide: _HMBottomGuide {
        if let g = _bottomGuide { return g }
        let g = _HMBottomGuide()
        stackView?.addLayoutGuide(g)
        g.bottomAnchor.constraint(equalTo: margeGuide.bottomAnchor).isActive = true
        _bottomGuide = g
        return g
    }

    private var trailingGuide: _HMTrailingGuide {
        if let g = _trailingGuide { return g }
        let g = _HMTrailingGuide()
        stackView?.addLayoutGuide(g)
        margeGuide.trailingAnchor.constraint(equalTo: g.trailingAnchor).isActive = true
        _trailingGuide = g
        return g
    }

    var margeGuide: HaomissyouMargeGuide {
        if let g = _margeGuide { return g }
        let g = HaomissyouMargeGuide(view: stackView!, insets: stackView!.insets)
        _margeGuide = g
        return g
    }
}
