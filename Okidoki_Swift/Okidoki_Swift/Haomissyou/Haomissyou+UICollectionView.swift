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

private final class _HaomissyouCollectionViewHandler: NSObject,
    UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // DataSource blocks
    var numberOfSectionsBlock:              ((UICollectionView) -> Int)?
    var numberOfItemsInSectionBlock:        ((UICollectionView, Int) -> Int)?
    var cellForItemAtIndexPathBlock:        ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    var viewForSupplementaryElementBlock:   ((UICollectionView, String, IndexPath) -> UICollectionReusableView)?

    // Delegate blocks
    var didSelectItemAtIndexPathBlock:      ((UICollectionView, IndexPath) -> Void)?
    var didDeselectItemAtIndexPathBlock:    ((UICollectionView, IndexPath) -> Void)?
    var willDisplayCellBlock:               ((UICollectionView, UICollectionViewCell, IndexPath) -> Void)?
    var didEndDisplayingCellBlock:          ((UICollectionView, UICollectionViewCell, IndexPath) -> Void)?

    // FlowLayout blocks
    var sizeForItemAtIndexPathBlock:        ((UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize)?
    var insetForSectionAtIndexBlock:        ((UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets)?
    var minimumLineSpacingBlock:            ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?
    var minimumInteritemSpacingBlock:       ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        numberOfSectionsBlock?(collectionView) ?? 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        numberOfItemsInSectionBlock?(collectionView, section) ?? 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = cellForItemAtIndexPathBlock?(collectionView, indexPath) { return cell }
        let id = "HaomissyouDefaultCollectionCell"
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: id)
        return collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if let view = viewForSupplementaryElementBlock?(collectionView, kind, indexPath) { return view }
        let id = "HaomissyouDefaultSupplementaryView"
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: kind,
                                withReuseIdentifier: id)
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: id,
                                                               for: indexPath)
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAtIndexPathBlock?(collectionView, indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeselectItemAtIndexPathBlock?(collectionView, indexPath)
    }
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        willDisplayCellBlock?(collectionView, cell, indexPath)
    }
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        didEndDisplayingCellBlock?(collectionView, cell, indexPath)
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let block = sizeForItemAtIndexPathBlock {
            return block(collectionView, collectionViewLayout, indexPath)
        }
        if let fl = collectionViewLayout as? UICollectionViewFlowLayout { return fl.itemSize }
        return CGSize(width: 50, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if let block = insetForSectionAtIndexBlock {
            return block(collectionView, collectionViewLayout, section)
        }
        if let fl = collectionViewLayout as? UICollectionViewFlowLayout { return fl.sectionInset }
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let block = minimumLineSpacingBlock {
            return block(collectionView, collectionViewLayout, section)
        }
        if let fl = collectionViewLayout as? UICollectionViewFlowLayout { return fl.minimumLineSpacing }
        return 10
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let block = minimumInteritemSpacingBlock {
            return block(collectionView, collectionViewLayout, section)
        }
        if let fl = collectionViewLayout as? UICollectionViewFlowLayout { return fl.minimumInteritemSpacing }
        return 10
    }
}

// MARK: - Associated Object Key + Lazy Helper

private var _cvHandlerKey: UInt8 = 0

private func _cvHandler(for cv: UICollectionView) -> _HaomissyouCollectionViewHandler {
    if let h = objc_getAssociatedObject(cv, &_cvHandlerKey) as? _HaomissyouCollectionViewHandler { return h }
    let h = _HaomissyouCollectionViewHandler()
    objc_setAssociatedObject(cv, &_cvHandlerKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    cv.dataSource = h
    cv.delegate   = h
    return h
}

// MARK: - UICollectionView Register

public extension Haomissyou {

    /// cvRegisterCellClass — params: [CellClass, "identifier"]
    @discardableResult
    func cvRegisterCellClass(_ params: [Any]) -> Haomissyou {
        guard let cv = view as? UICollectionView,
              params.count >= 2,
              let cls = params[0] as? AnyClass,
              let id  = params[1] as? String else { return self }
        cv.register(cls, forCellWithReuseIdentifier: id)
        return self
    }

    /// cvRegisterCellNib — params: [UINib | nibName: String, "identifier"]
    @discardableResult
    func cvRegisterCellNib(_ params: [Any]) -> Haomissyou {
        guard let cv = view as? UICollectionView,
              params.count >= 2,
              let id = params[1] as? String else { return self }
        let nib: UINib?
        if let n = params[0] as? UINib { nib = n }
        else if let name = params[0] as? String { nib = UINib(nibName: name, bundle: nil) }
        else { nib = nil }
        if let nib { cv.register(nib, forCellWithReuseIdentifier: id) }
        return self
    }

    /// cvRegisterSupplementaryViewClass — params: [ViewClass, "kind", "identifier"]
    @discardableResult
    func cvRegisterSupplementaryViewClass(_ params: [Any]) -> Haomissyou {
        guard let cv = view as? UICollectionView,
              params.count >= 3,
              let cls  = params[0] as? AnyClass,
              let kind = params[1] as? String,
              let id   = params[2] as? String else { return self }
        cv.register(cls, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
        return self
    }

    /// cvRegisterSupplementaryViewNib — params: [UINib | nibName: String, "kind", "identifier"]
    @discardableResult
    func cvRegisterSupplementaryViewNib(_ params: [Any]) -> Haomissyou {
        guard let cv = view as? UICollectionView,
              params.count >= 3,
              let kind = params[1] as? String,
              let id   = params[2] as? String else { return self }
        let nib: UINib?
        if let n = params[0] as? UINib { nib = n }
        else if let name = params[0] as? String { nib = UINib(nibName: name, bundle: nil) }
        else { nib = nil }
        if let nib { cv.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: id) }
        return self
    }
}

// MARK: - UICollectionView DataSource Blocks

public extension Haomissyou {

    /// numberOfSectionsInCollectionView:
    @discardableResult
    func cvNumberOfSections(_ block: @escaping (UICollectionView) -> Int) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).numberOfSectionsBlock = block
        return self
    }

    /// collectionView:numberOfItemsInSection:
    @discardableResult
    func cvNumberOfItemsInSection(_ block: @escaping (UICollectionView, Int) -> Int) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).numberOfItemsInSectionBlock = block
        return self
    }

    /// collectionView:cellForItemAtIndexPath:
    @discardableResult
    func cvCellForItemAtIndexPath(_ block: @escaping (UICollectionView, IndexPath) -> UICollectionViewCell) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).cellForItemAtIndexPathBlock = block
        return self
    }

    /// collectionView:viewForSupplementaryElementOfKind:atIndexPath:
    @discardableResult
    func cvViewForSupplementaryElement(_ block: @escaping (UICollectionView, String, IndexPath) -> UICollectionReusableView) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).viewForSupplementaryElementBlock = block
        return self
    }
}

// MARK: - UICollectionView Delegate Blocks

public extension Haomissyou {

    /// collectionView:didSelectItemAtIndexPath:
    @discardableResult
    func cvDidSelectItemAtIndexPath(_ block: @escaping (UICollectionView, IndexPath) -> Void) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).didSelectItemAtIndexPathBlock = block
        return self
    }

    /// collectionView:didDeselectItemAtIndexPath:
    @discardableResult
    func cvDidDeselectItemAtIndexPath(_ block: @escaping (UICollectionView, IndexPath) -> Void) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).didDeselectItemAtIndexPathBlock = block
        return self
    }

    /// collectionView:willDisplayCell:forItemAtIndexPath:
    @discardableResult
    func cvWillDisplayCell(_ block: @escaping (UICollectionView, UICollectionViewCell, IndexPath) -> Void) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).willDisplayCellBlock = block
        return self
    }

    /// collectionView:didEndDisplayingCell:forItemAtIndexPath:
    @discardableResult
    func cvDidEndDisplayingCell(_ block: @escaping (UICollectionView, UICollectionViewCell, IndexPath) -> Void) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).didEndDisplayingCellBlock = block
        return self
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Blocks

public extension Haomissyou {

    /// collectionView:layout:sizeForItemAtIndexPath:
    @discardableResult
    func cvSizeForItemAtIndexPath(_ block: @escaping (UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).sizeForItemAtIndexPathBlock = block
        return self
    }

    /// collectionView:layout:insetForSectionAtIndex:
    @discardableResult
    func cvInsetForSectionAtIndex(_ block: @escaping (UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).insetForSectionAtIndexBlock = block
        return self
    }

    /// collectionView:layout:minimumLineSpacingForSectionAtIndex:
    @discardableResult
    func cvMinimumLineSpacing(_ block: @escaping (UICollectionView, UICollectionViewLayout, Int) -> CGFloat) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).minimumLineSpacingBlock = block
        return self
    }

    /// collectionView:layout:minimumInteritemSpacingForSectionAtIndex:
    @discardableResult
    func cvMinimumInteritemSpacing(_ block: @escaping (UICollectionView, UICollectionViewLayout, Int) -> CGFloat) -> Haomissyou {
        guard let cv = view as? UICollectionView else { return self }
        _cvHandler(for: cv).minimumInteritemSpacingBlock = block
        return self
    }
}
