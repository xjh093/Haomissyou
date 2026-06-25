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

private final class _HaomissyouTableViewHandler: NSObject,
    UITableViewDataSource, UITableViewDelegate {

    // DataSource blocks
    var numberOfSectionsBlock:          ((UITableView) -> Int)?
    var numberOfRowsInSectionBlock:     ((UITableView, Int) -> Int)?
    var cellForRowAtIndexPathBlock:     ((UITableView, IndexPath) -> UITableViewCell)?
    var titleForHeaderInSectionBlock:   ((UITableView, Int) -> String?)?
    var titleForFooterInSectionBlock:   ((UITableView, Int) -> String?)?
    var canEditRowAtIndexPathBlock:     ((UITableView, IndexPath) -> Bool)?
    var commitEditingStyleBlock:        ((UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void)?

    // Delegate blocks
    var heightForRowAtIndexPathBlock:       ((UITableView, IndexPath) -> CGFloat)?
    var heightForHeaderInSectionBlock:      ((UITableView, Int) -> CGFloat)?
    var heightForFooterInSectionBlock:      ((UITableView, Int) -> CGFloat)?
    var viewForHeaderInSectionBlock:        ((UITableView, Int) -> UIView?)?
    var viewForFooterInSectionBlock:        ((UITableView, Int) -> UIView?)?
    var didSelectRowAtIndexPathBlock:       ((UITableView, IndexPath) -> Void)?
    var didDeselectRowAtIndexPathBlock:     ((UITableView, IndexPath) -> Void)?
    var willDisplayCellBlock:               ((UITableView, UITableViewCell, IndexPath) -> Void)?
    var didEndDisplayingCellBlock:          ((UITableView, UITableViewCell, IndexPath) -> Void)?
    var editingStyleForRowAtIndexPathBlock: ((UITableView, IndexPath) -> UITableViewCell.EditingStyle)?

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSectionsBlock?(tableView) ?? 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRowsInSectionBlock?(tableView, section) ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = cellForRowAtIndexPathBlock?(tableView, indexPath) { return cell }
        let id = "HaomissyouDefaultCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id)
            ?? UITableViewCell(style: .default, reuseIdentifier: id)
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titleForHeaderInSectionBlock?(tableView, section)
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        titleForFooterInSectionBlock?(tableView, section)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        canEditRowAtIndexPathBlock?(tableView, indexPath) ?? false
    }
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        commitEditingStyleBlock?(tableView, editingStyle, indexPath)
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForRowAtIndexPathBlock?(tableView, indexPath) ?? UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        heightForHeaderInSectionBlock?(tableView, section) ?? 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        heightForFooterInSectionBlock?(tableView, section) ?? 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        viewForHeaderInSectionBlock?(tableView, section)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        viewForFooterInSectionBlock?(tableView, section)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAtIndexPathBlock?(tableView, indexPath)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        didDeselectRowAtIndexPathBlock?(tableView, indexPath)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayCellBlock?(tableView, cell, indexPath)
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        didEndDisplayingCellBlock?(tableView, cell, indexPath)
    }
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        editingStyleForRowAtIndexPathBlock?(tableView, indexPath) ?? .none
    }
}

// MARK: - Associated Object Key + Lazy Helper

private var _tvHandlerKey: UInt8 = 0

private func _tvHandler(for tv: UITableView) -> _HaomissyouTableViewHandler {
    if let h = objc_getAssociatedObject(tv, &_tvHandlerKey) as? _HaomissyouTableViewHandler { return h }
    let h = _HaomissyouTableViewHandler()
    objc_setAssociatedObject(tv, &_tvHandlerKey, h, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    tv.dataSource = h
    tv.delegate   = h
    return h
}

// MARK: - UITableView Register

public extension Haomissyou {

    /// registerCellClass — params: [CellClass, "identifier"]
    @discardableResult
    func registerCellClass(_ params: [Any]) -> Haomissyou {
        guard let tv = view as? UITableView,
              params.count >= 2,
              let cls = params[0] as? AnyClass,
              let id  = params[1] as? String else { return self }
        tv.register(cls, forCellReuseIdentifier: id)
        return self
    }

    /// registerCellNib — params: [UINib | nibName: String, "identifier"]
    @discardableResult
    func registerCellNib(_ params: [Any]) -> Haomissyou {
        guard let tv = view as? UITableView,
              params.count >= 2,
              let id = params[1] as? String else { return self }
        let nib: UINib?
        if let n = params[0] as? UINib { nib = n }
        else if let name = params[0] as? String { nib = UINib(nibName: name, bundle: nil) }
        else { nib = nil }
        if let nib { tv.register(nib, forCellReuseIdentifier: id) }
        return self
    }

    /// registerMultiCellClass — params: [[CellClass, "identifier"], ...]
    @discardableResult
    func registerMultiCellClass(_ params: [[Any]]) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        for item in params {
            guard item.count >= 2,
                  let cls = item[0] as? AnyClass,
                  let id  = item[1] as? String else { continue }
            tv.register(cls, forCellReuseIdentifier: id)
        }
        return self
    }
}

// MARK: - UITableView DataSource Blocks

public extension Haomissyou {

    /// numberOfSectionsInTableView:
    @discardableResult
    func numberOfSections(_ block: @escaping (UITableView) -> Int) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).numberOfSectionsBlock = block
        return self
    }

    /// tableView:numberOfRowsInSection:
    @discardableResult
    func numberOfRowsInSection(_ block: @escaping (UITableView, Int) -> Int) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).numberOfRowsInSectionBlock = block
        return self
    }

    /// tableView:cellForRowAtIndexPath:
    @discardableResult
    func cellForRowAtIndexPath(_ block: @escaping (UITableView, IndexPath) -> UITableViewCell) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).cellForRowAtIndexPathBlock = block
        return self
    }

    /// tableView:titleForHeaderInSection:
    @discardableResult
    func titleForHeaderInSection(_ block: @escaping (UITableView, Int) -> String?) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).titleForHeaderInSectionBlock = block
        return self
    }

    /// tableView:titleForFooterInSection:
    @discardableResult
    func titleForFooterInSection(_ block: @escaping (UITableView, Int) -> String?) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).titleForFooterInSectionBlock = block
        return self
    }

    /// tableView:canEditRowAtIndexPath:
    @discardableResult
    func canEditRowAtIndexPath(_ block: @escaping (UITableView, IndexPath) -> Bool) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).canEditRowAtIndexPathBlock = block
        return self
    }

    /// tableView:commitEditingStyle:forRowAtIndexPath:
    @discardableResult
    func commitEditingStyle(_ block: @escaping (UITableView, UITableViewCell.EditingStyle, IndexPath) -> Void) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).commitEditingStyleBlock = block
        return self
    }
}

// MARK: - UITableView Delegate Blocks

public extension Haomissyou {

    /// tableView:heightForRowAtIndexPath:
    @discardableResult
    func heightForRowAtIndexPath(_ block: @escaping (UITableView, IndexPath) -> CGFloat) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).heightForRowAtIndexPathBlock = block
        return self
    }

    /// tableView:heightForHeaderInSection:
    @discardableResult
    func heightForHeaderInSection(_ block: @escaping (UITableView, Int) -> CGFloat) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).heightForHeaderInSectionBlock = block
        return self
    }

    /// tableView:heightForFooterInSection:
    @discardableResult
    func heightForFooterInSection(_ block: @escaping (UITableView, Int) -> CGFloat) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).heightForFooterInSectionBlock = block
        return self
    }

    /// tableView:viewForHeaderInSection:
    @discardableResult
    func viewForHeaderInSection(_ block: @escaping (UITableView, Int) -> UIView?) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).viewForHeaderInSectionBlock = block
        return self
    }

    /// tableView:viewForFooterInSection:
    @discardableResult
    func viewForFooterInSection(_ block: @escaping (UITableView, Int) -> UIView?) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).viewForFooterInSectionBlock = block
        return self
    }

    /// tableView:didSelectRowAtIndexPath:
    @discardableResult
    func didSelectRowAtIndexPath(_ block: @escaping (UITableView, IndexPath) -> Void) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).didSelectRowAtIndexPathBlock = block
        return self
    }

    /// tableView:didDeselectRowAtIndexPath:
    @discardableResult
    func didDeselectRowAtIndexPath(_ block: @escaping (UITableView, IndexPath) -> Void) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).didDeselectRowAtIndexPathBlock = block
        return self
    }

    /// tableView:willDisplayCell:forRowAtIndexPath:
    @discardableResult
    func willDisplayCell(_ block: @escaping (UITableView, UITableViewCell, IndexPath) -> Void) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).willDisplayCellBlock = block
        return self
    }

    /// tableView:didEndDisplayingCell:forRowAtIndexPath:
    @discardableResult
    func didEndDisplayingCell(_ block: @escaping (UITableView, UITableViewCell, IndexPath) -> Void) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).didEndDisplayingCellBlock = block
        return self
    }

    /// tableView:editingStyleForRowAtIndexPath:
    @discardableResult
    func editingStyleForRowAtIndexPath(_ block: @escaping (UITableView, IndexPath) -> UITableViewCell.EditingStyle) -> Haomissyou {
        guard let tv = view as? UITableView else { return self }
        _tvHandler(for: tv).editingStyleForRowAtIndexPathBlock = block
        return self
    }
}
