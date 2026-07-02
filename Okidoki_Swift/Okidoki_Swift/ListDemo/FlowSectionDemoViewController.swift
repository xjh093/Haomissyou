//
//  FlowSectionDemoViewController.swift
//  HaomissyouListKit – Demo
//
//  Created by Haomissyou on 7/2/26.
//
//  演示：
//    - 多个 FlowSectionController，每个 section 有不同列数（1、2、3列）
//    - Section 背景色 + 圆角
//    - Header / Footer 视图
//    - 顶部有一个"点击刷新"按钮，演示局部 section reload
//

import UIKit

// MARK: - View Controller

final class FlowSectionDemoViewController: UIViewController {

    private lazy var collectionView = HaomissyouCollectionView(frame: .zero)

    // 3 个 section，列数分别为 1、2、3
    private var sectionControllers: [ColorGridSectionController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "局部刷新",
            style: .plain,
            target: self,
            action: #selector(partialReload))

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        collectionView.listDataSource = self
        collectionView.viewController = self

        buildSectionControllers()
        collectionView.reloadData()
    }

    private func buildSectionControllers() {
        let configs: [(columns: Int, color: UIColor, radius: CGFloat)] = [
            (1, UIColor.systemBlue.withAlphaComponent(0.12),   12),
            (2, UIColor.systemGreen.withAlphaComponent(0.12),  12),
            (3, UIColor.systemOrange.withAlphaComponent(0.12), 12),
        ]
        sectionControllers = configs.map { cfg in
            let sc = ColorGridSectionController()
            sc.columnCount = cfg.columns
            sc.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            sc.minimumInteritemSpacing = 8
            sc.minimumLineSpacing = 8
            sc.headerHeight = 36
            sc.sectionBackgroundColor = cfg.color
            sc.sectionBackgroundCornerRadius = cfg.radius
            sc.sectionBackgroundInset = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            return sc
        }
    }

    @objc private func partialReload() {
        // 随机刷新中间那个 section，演示局部刷新
        sectionControllers[1].reload()
    }
}

extension FlowSectionDemoViewController: HaomissyouCollectionViewDataSource {

    func sectionControllers(for collectionView: HaomissyouCollectionView) -> [HaomissyouSectionController] {
        sectionControllers
    }
}

// MARK: - Section Controller

private final class ColorGridSectionController: HaomissyouFlowSectionController {

    private static let palette: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow,
        .systemGreen, .systemTeal, .systemBlue,
        .systemIndigo, .systemPurple, .systemPink,
    ]

    // 每次 reload 时随机打乱顺序，方便观察局部刷新效果
    private var colors: [UIColor] = []

    override init() {
        super.init()
        shuffle()
    }

    private func shuffle() {
        colors = Self.palette.shuffled()
    }

    override func numberOfItems() -> Int { colors.count }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(ColorCell.self, at: index)
        cell.configure(color: colors[index], text: "\(index + 1)")
        return cell
    }

    override func sizeForItem(at index: Int) -> CGSize {
        CGSize(width: columnWidth, height: columnWidth)
    }

    override func didSelectItem(at index: Int) {
        print("[FlowDemo] tapped section=\(section) index=\(index) color=\(colors[index])")
    }

    // reload 时重新打乱
    override func reload() {
        shuffle()
        super.reload()
    }

    // MARK: Header
    override func viewForHeader() -> UICollectionReusableView? {
        let v = dequeueReusableSupplementaryView(SectionHeaderView.self,
                                                  kind: UICollectionView.elementKindSectionHeader,
                                                  at: 0)
        v.configure(title: "\(columnCount) 列布局  ×  \(colors.count) 个色块")
        return v
    }
}

// MARK: - Color Cell

private final class ColorCell: HaomissyouCollectionViewCell {

    private let label = UILabel()

    override func setupViews() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(color: UIColor, text: String) {
        contentView.backgroundColor = color
        label.text = text
    }
}

// MARK: - Section Header View

private final class SectionHeaderView: UICollectionReusableView {

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) {
        label.text = title
    }
}
