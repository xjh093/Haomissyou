//
//  HaomissyouCollectionView.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//

import UIKit

// MARK: - Private: HaomissyouCompositionalLayout

/// UICollectionViewCompositionalLayout 子类，覆写 layoutAttributesForElements(in:)
/// 以将背景色注入 decoration view attributes。
@available(iOS 13.0, *)
private final class HaomissyouCompositionalLayout: UICollectionViewCompositionalLayout {

    /// section 索引 → UIColor
    var backgroundColors: [Int: UIColor] = [:]
    /// section 索引 → CGFloat (cornerRadius)
    var backgroundCornerRadii: [Int: CGFloat] = [:]

    override init(sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) {
        super.init(sectionProvider: sectionProvider)
        register(
            HaomissyouSectionBackgroundView.self,
            forDecorationViewOfKind: kHaomissyouSectionBackgroundKind)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var attrs = super.layoutAttributesForElements(in: rect) else { return nil }
        guard !backgroundColors.isEmpty else { return attrs }

        for i in 0 ..< attrs.count {
            let a = attrs[i]
            guard a.representedElementCategory == .decorationView,
                  a.representedElementKind == kHaomissyouSectionBackgroundKind else { continue }

            let section = a.indexPath.section
            guard let color = backgroundColors[section] else { continue }

            let custom = HaomissyouSectionBackgroundAttributes(
                forDecorationViewOfKind: kHaomissyouSectionBackgroundKind,
                with: a.indexPath)
            custom.frame = a.frame
            custom.zIndex = a.zIndex
            custom.alpha = a.alpha
            custom.sectionBackgroundColor = color
            custom.sectionBackgroundCornerRadius = backgroundCornerRadii[section] ?? 0
            attrs[i] = custom
        }
        return attrs
    }
}

// MARK: - HaomissyouCollectionView

private let kHaomissyouEmptySupplementaryIdentifier = "HaomissyouListKitEmptySupplementaryView"

/// HaomissyouListKit 的核心 CollectionView。
/// 自身作为 UICollectionViewDataSource/Delegate，把所有事件分发给对应的 SectionController。
/// 外部通过 listDataSource 提供 SectionControllers，通过 scrollDelegate 监听滚动。
public final class HaomissyouCollectionView: UICollectionView {

    /// 宿主 ViewController，注入后会自动同步给所有 SectionController
    public weak var viewController: UIViewController? {
        didSet { sectionControllers.forEach { $0.viewController = viewController } }
    }

    /// 列表数据源，提供 SectionControllers
    public weak var listDataSource: HaomissyouCollectionViewDataSource?

    /// 滚动代理，转发 UIScrollViewDelegate 事件（不能直接设置 UICollectionView 的 delegate）
    public weak var scrollDelegate: UIScrollViewDelegate?

    /// 当前所有 SectionControllers（只读，由 reloadData 刷新后更新）
    public private(set) var sectionControllers: [HaomissyouSectionController] = []

    private var registeredCellIdentifiers: Set<String> = []
    private var registeredSupplementaryIdentifiers: Set<String> = []
    private var emptyView: UIView?

    // MARK: - Init

    /// 如果传入的是原生 UICollectionViewFlowLayout（而非子类），自动升级为 HaomissyouFlowLayout
    /// 以支持 sectionBackgroundColor 等扩展特性，同时保留 scrollDirection 设置
    public init(frame: CGRect, layout: UICollectionViewLayout? = nil) {
        let needsFlowLayout = layout == nil || type(of: layout!) == UICollectionViewFlowLayout.self
        let managedFlowLayout: HaomissyouFlowLayout?
        let resolvedLayout: UICollectionViewLayout

        if needsFlowLayout {
            let fl = HaomissyouFlowLayout()
            if let flowLayout = layout as? UICollectionViewFlowLayout {
                fl.scrollDirection = flowLayout.scrollDirection
            }
            managedFlowLayout = fl
            resolvedLayout = fl
        } else {
            managedFlowLayout = nil
            resolvedLayout = layout!
        }

        super.init(frame: frame, collectionViewLayout: resolvedLayout)
        // backgroundDelegate 在 self 完成初始化后设置，避免 unsafe 引用
        managedFlowLayout?.backgroundDelegate = self
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    /// 使用 Compositional Layout 初始化（iOS 13+）。
    /// 各 section 的布局由对应 SectionController 的 layoutSection(for:) 提供。
    @available(iOS 13.0, *)
    public static func compositional(frame: CGRect) -> HaomissyouCollectionView {
        // weak var 技巧：layout provider 在 self 初始化完成后才会被调用，
        // 因此 weakCV 赋值发生在首次 layout 前，不存在空指针风险。
        weak var weakCV: HaomissyouCollectionView?
        let layout = HaomissyouCompositionalLayout { sectionIndex, environment in
            guard let cv = weakCV else {
                return HaomissyouSectionController().layoutSection(for: environment)
            }
            return cv.sectionController(at: sectionIndex)?.layoutSection(for: environment)
                ?? HaomissyouSectionController().layoutSection(for: environment)
        }
        let cv = HaomissyouCollectionView(frame: frame, layout: layout)
        weakCV = cv
        return cv
    }

    /// 使用瀑布流 Layout 初始化。
    /// 各 section 对应的 SectionController 应为 HaomissyouWaterfallSectionController 子类。
    public static func waterfall(frame: CGRect) -> HaomissyouCollectionView {
        let layout = HaomissyouWaterfallLayout()
        let cv = HaomissyouCollectionView(frame: frame, layout: layout)
        layout.delegate = cv
        return cv
    }

    // MARK: - Setup

    private func setup() {
        sectionControllers = []
        registeredCellIdentifiers = []
        registeredSupplementaryIdentifiers = []
        // 直接调用父类 setter，绕过本类的保护性 override
        super.dataSource = self
        super.delegate = self
        backgroundColor = .clear
        alwaysBounceVertical = true
        // 预注册空白占位 supplementary view（防止 header/footer 返回 nil 时崩溃）
        super.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: kHaomissyouEmptySupplementaryIdentifier)
        super.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: kHaomissyouEmptySupplementaryIdentifier)
    }

    // MARK: - Overrides（保护内部 dataSource/delegate）

    public override var dataSource: UICollectionViewDataSource? {
        get { super.dataSource }
        set {
            guard newValue == nil || newValue === self else {
                assertionFailure("[HaomissyouListKit] 请使用 listDataSource，不要直接设置 dataSource")
                return
            }
            super.dataSource = newValue
        }
    }

    public override var delegate: UICollectionViewDelegate? {
        get { super.delegate }
        set {
            guard newValue == nil || newValue === self else {
                assertionFailure("[HaomissyouListKit] 请使用 scrollDelegate，不要直接设置 delegate")
                return
            }
            super.delegate = newValue
        }
    }

    // MARK: - Public

    /// 重新向 listDataSource 请求 SectionControllers 并刷新列表
    public override func reloadData() {
        rebuildSectionControllers()
        super.reloadData()
        updateEmptyView()
    }

    // MARK: - Internal (for HaomissyouSectionController)

    func reloadSectionController(
        _ sc: HaomissyouSectionController,
        animated: Bool,
        completion: ((Bool) -> Void)?
    ) {
        guard let idx = sectionControllers.firstIndex(of: sc) else { return }
        let indexSet = IndexSet(integer: idx)
        if animated {
            performBatchUpdates({ self.reloadSections(indexSet) }, completion: completion)
        } else {
            UIView.performWithoutAnimation { self.reloadSections(indexSet) }
            completion?(true)
        }
    }

    func dequeueReusableCell<T: UICollectionViewCell>(
        _ cellClass: T.Type,
        at indexPath: IndexPath
    ) -> T {
        let identifier = String(describing: cellClass)
        if !registeredCellIdentifiers.contains(identifier) {
            super.register(cellClass, forCellWithReuseIdentifier: identifier)
            registeredCellIdentifiers.insert(identifier)
        }
        // Force-cast is safe: we just registered this exact class for this identifier.
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        _ viewClass: T.Type,
        kind: String,
        at indexPath: IndexPath
    ) -> T {
        let identifier = "\(String(describing: viewClass))_\(kind)"
        if !registeredSupplementaryIdentifiers.contains(identifier) {
            super.register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
            registeredSupplementaryIdentifiers.insert(identifier)
        }
        return dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: identifier,
            for: indexPath) as! T
    }

    // MARK: - Private

    private func rebuildSectionControllers() {
        guard let controllers = listDataSource?.sectionControllers(for: self) else {
            sectionControllers = []
            return
        }
        sectionControllers = controllers
        for (idx, sc) in sectionControllers.enumerated() {
            sc.collectionView = self
            sc.viewController = viewController
            sc.section = idx
        }

        // Compositional Layout：同步 section 背景色字典（layout provider 在布局时读取）
        if #available(iOS 13.0, *) {
            if let cl = collectionViewLayout as? HaomissyouCompositionalLayout {
                cl.backgroundColors.removeAll()
                cl.backgroundCornerRadii.removeAll()
                for (s, sc) in sectionControllers.enumerated() {
                    guard let flowSC = sc as? HaomissyouFlowSectionController,
                          let color = flowSC.sectionBackgroundColor else { continue }
                    cl.backgroundColors[s] = color
                    if flowSC.sectionBackgroundCornerRadius > 0 {
                        cl.backgroundCornerRadii[s] = flowSC.sectionBackgroundCornerRadius
                    }
                }
            }
        }
    }

    private func updateEmptyView() {
        let totalItems = sectionControllers.reduce(0) { $0 + $1.numberOfItems() }
        emptyView?.removeFromSuperview()
        emptyView = nil

        guard totalItems == 0,
              let view = listDataSource?.emptyView(for: self) else { return }
        emptyView = view
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }

    func sectionController(at section: Int) -> HaomissyouSectionController? {
        guard section >= 0 && section < sectionControllers.count else { return nil }
        let sc = sectionControllers[section]
        // 保持 section 索引准确（防止外部复用同一 SC 实例时错乱）
        sc.section = section
        return sc
    }

    // MARK: - ScrollDelegate forwarding

    public override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || scrollDelegate?.responds(to: aSelector) == true
    }

    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if scrollDelegate?.responds(to: aSelector) == true { return scrollDelegate }
        return super.forwardingTarget(for: aSelector)
    }
}

// MARK: - UICollectionViewDataSource

extension HaomissyouCollectionView: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionControllers.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        sectionController(at: section)?.numberOfItems() ?? 0
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        sectionController(at: indexPath.section)?.cellForItem(at: indexPath.item)
            ?? UICollectionViewCell()
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if let flowSC = sectionController(at: indexPath.section) as? HaomissyouFlowSectionController,
           let view = flowSC.viewForSupplementaryElement(ofKind: kind, at: indexPath.item) {
            return view
        }
        // 兜底：返回空白 view 防止崩溃
        return dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: kHaomissyouEmptySupplementaryIdentifier,
            for: indexPath)
    }
}

// MARK: - UICollectionViewDelegate

extension HaomissyouCollectionView: UICollectionViewDelegate {

    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        sectionController(at: indexPath.section)?.didSelectItem(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HaomissyouCollectionView: UICollectionViewDelegateFlowLayout {

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        sectionController(at: indexPath.section)?.sizeForItem(at: indexPath.item) ?? .zero
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.sectionInset ?? .zero
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.minimumLineSpacing ?? 0
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.minimumInteritemSpacing ?? 0
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let flowSC = sectionController(at: section) as? HaomissyouFlowSectionController,
              flowSC.headerHeight > 0 else { return .zero }
        return CGSize(width: bounds.width, height: flowSC.headerHeight)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard let flowSC = sectionController(at: section) as? HaomissyouFlowSectionController,
              flowSC.footerHeight > 0 else { return .zero }
        return CGSize(width: bounds.width, height: flowSC.footerHeight)
    }
}

// MARK: - HaomissyouFlowLayoutBackgroundDelegate

extension HaomissyouCollectionView: HaomissyouFlowLayoutBackgroundDelegate {

    public func collectionView(
        _ collectionView: UICollectionView,
        backgroundColorForSection section: Int
    ) -> UIColor? {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.sectionBackgroundColor
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        backgroundCornerRadiusForSection section: Int
    ) -> CGFloat {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?
            .sectionBackgroundCornerRadius ?? 0
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        backgroundInsetForSection section: Int
    ) -> UIEdgeInsets {
        guard let flowSC = sectionController(at: section) as? HaomissyouFlowSectionController else {
            return .zero
        }
        let d = flowSC.sectionBackgroundInset
        // NSDirectionalEdgeInsets → UIEdgeInsets（LTR 布局 leading=left, trailing=right）
        return UIEdgeInsets(top: d.top, left: d.leading, bottom: d.bottom, right: d.trailing)
    }
}

// MARK: - HaomissyouWaterfallLayoutDelegate

extension HaomissyouCollectionView: HaomissyouWaterfallLayoutDelegate {

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        heightForItemAt indexPath: IndexPath,
        itemWidth width: CGFloat
    ) -> CGFloat {
        guard let sc = sectionController(at: indexPath.section) as? HaomissyouWaterfallSectionController
        else { return 100 }
        return sc.heightForItem(at: indexPath.item, width: width)
    }

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        columnCountForSection section: Int
    ) -> Int {
        max(1, (sectionController(at: section) as? HaomissyouFlowSectionController)?.columnCount ?? 1)
    }

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        insetForSection section: Int
    ) -> UIEdgeInsets {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.sectionInset ?? .zero
    }

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        lineSpacingForSection section: Int
    ) -> CGFloat {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.minimumLineSpacing ?? 0
    }

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        columnSpacingForSection section: Int
    ) -> CGFloat {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.minimumInteritemSpacing ?? 0
    }

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        backgroundColorForSection section: Int
    ) -> UIColor? {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?.sectionBackgroundColor
    }

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        backgroundCornerRadiusForSection section: Int
    ) -> CGFloat {
        (sectionController(at: section) as? HaomissyouFlowSectionController)?
            .sectionBackgroundCornerRadius ?? 0
    }

    public func waterfallLayout(
        _ layout: HaomissyouWaterfallLayout,
        backgroundInsetForSection section: Int
    ) -> UIEdgeInsets {
        guard let flowSC = sectionController(at: section) as? HaomissyouFlowSectionController else {
            return .zero
        }
        let d = flowSC.sectionBackgroundInset
        return UIEdgeInsets(top: d.top, left: d.leading, bottom: d.bottom, right: d.trailing)
    }
}
