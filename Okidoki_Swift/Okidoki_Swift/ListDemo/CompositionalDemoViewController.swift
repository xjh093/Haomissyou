//
//  CompositionalDemoViewController.swift
//  HaomissyouListKit – Demo
//
//  Created by Haomissyou on 7/2/26.
//
//  演示（iOS 13+）：
//    - 纵向主列表中嵌套横向滚动 section（orthogonalScrollingBehavior = .continuousGroupLeadingBoundary）
//    - 固定高度 section（itemHeightDimension 返回 .absolute）
//    - 自动高度 section（itemHeightDimension 返回 .estimated）
//    - section 背景色通过 NSCollectionLayoutDecorationItem 实现
//

import UIKit

// MARK: - View Controller

@available(iOS 13.0, *)
final class CompositionalDemoViewController: UIViewController {

    private lazy var collectionView = HaomissyouCollectionView.compositional(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

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
        collectionView.reloadData()
    }
}

@available(iOS 13.0, *)
extension CompositionalDemoViewController: HaomissyouCollectionViewDataSource {

    func sectionControllers(for collectionView: HaomissyouCollectionView) -> [HaomissyouSectionController] {
        [
            makeHorizontalScrollSection(),
            makeFixedHeightGridSection(),
            makeAutoHeightSection(),
        ]
    }

    // ① 横向滚动卡片
    private func makeHorizontalScrollSection() -> HaomissyouSectionController {
        let sc = HorizontalCardSectionController()
        sc.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        sc.minimumInteritemSpacing = 10
        sc.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        sc.sectionBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        sc.sectionBackgroundCornerRadius = 14
        sc.sectionBackgroundInset = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        return sc
    }

    // ② 3 列固定高度网格
    private func makeFixedHeightGridSection() -> HaomissyouSectionController {
        let sc = FixedGridSectionController()
        sc.columnCount = 3
        sc.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        sc.minimumInteritemSpacing = 8
        sc.minimumLineSpacing = 8
        sc.sectionBackgroundColor = UIColor.systemGreen.withAlphaComponent(0.08)
        sc.sectionBackgroundCornerRadius = 14
        sc.sectionBackgroundInset = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        return sc
    }

    // ③ 自动高度（estimated）文本列表
    private func makeAutoHeightSection() -> HaomissyouSectionController {
        let sc = AutoHeightTextSectionController()
        sc.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 20, right: 16)
        sc.minimumLineSpacing = 8
        sc.sectionBackgroundColor = UIColor.systemOrange.withAlphaComponent(0.08)
        sc.sectionBackgroundCornerRadius = 14
        sc.sectionBackgroundInset = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        return sc
    }
}

// MARK: - ① 横向滚动卡片 Section

@available(iOS 13.0, *)
private final class HorizontalCardSectionController: HaomissyouFlowSectionController {

    private let cards: [(String, UIColor)] = [
        ("Swift",      .systemBlue),
        ("UIKit",      .systemIndigo),
        ("SwiftUI",    .systemPurple),
        ("Combine",    .systemTeal),
        ("Async/Await",.systemCyan),
        ("XCTest",     .systemGreen),
    ]

    override func numberOfItems() -> Int { cards.count }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(HorizontalCardCell.self, at: index)
        cell.configure(text: cards[index].0, color: cards[index].1)
        return cell
    }

    // Compositional Layout 下 sizeForItem 不起作用，由 itemHeightDimension 控制高度
    override func sizeForItem(at index: Int) -> CGSize { .zero }

    override func itemHeightDimension(
        for environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutDimension {
        .absolute(110)
    }

    // 覆写以固定卡片宽度为 130pt
    override func layoutSection(
        for environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(130),
            heightDimension: .absolute(110))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(130),
            heightDimension: .absolute(110))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: sectionInset.top, leading: sectionInset.left,
            bottom: sectionInset.bottom, trailing: sectionInset.right)
        section.interGroupSpacing = minimumInteritemSpacing
        section.orthogonalScrollingBehavior = orthogonalScrollingBehavior

        if sectionBackgroundColor != nil {
            let bg = NSCollectionLayoutDecorationItem.background(
                elementKind: kHaomissyouSectionBackgroundKind)
            bg.contentInsets = sectionBackgroundInset
            section.decorationItems = [bg]
        }
        return section
    }
}

@available(iOS 13.0, *)
private final class HorizontalCardCell: HaomissyouCollectionViewCell {
    private let label = UILabel()

    override func setupViews() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
        ])
    }

    func configure(text: String, color: UIColor) {
        contentView.backgroundColor = color
        label.text = text
    }
}

// MARK: - ② 固定高度网格 Section

@available(iOS 13.0, *)
private final class FixedGridSectionController: HaomissyouFlowSectionController {

    private let items = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]

    override func numberOfItems() -> Int { items.count }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(GridCell.self, at: index)
        cell.configure(text: items[index])
        return cell
    }

    override func sizeForItem(at index: Int) -> CGSize { .zero }

    override func itemHeightDimension(
        for environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutDimension {
        .absolute(70)
    }
}

@available(iOS 13.0, *)
private final class GridCell: HaomissyouCollectionViewCell {
    private let label = UILabel()
    override func setupViews() {
        contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.6)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    func configure(text: String) { label.text = text }
}

// MARK: - ③ 自动高度文本 Section

@available(iOS 13.0, *)
private final class AutoHeightTextSectionController: HaomissyouFlowSectionController {

    private let texts = [
        "Compositional Layout 的 estimated 高度模式会在首次显示时测量真实高度。",
        "这一行文字比较短。",
        "通过覆写 itemHeightDimension(for:) 返回 .estimated(44)，\n" +
        "框架会自动使用 Auto Layout 计算真实高度，\n" +
        "不需要手动指定每个 cell 的精确高度，非常方便。",
        "第四条：简短内容。",
        "第五条：这里放一段稍微长一点的内容，展示多行自动换行后高度自适应的效果。" +
        "HaomissyouListKit 封装了 preferredLayoutAttributesFitting 的实现，子类零配置即可享受。",
    ]

    override func numberOfItems() -> Int { texts.count }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(TextRowCell.self, at: index)
        cell.configure(text: texts[index], index: index)
        return cell
    }

    override func sizeForItem(at index: Int) -> CGSize { .zero }

    // 默认已是 .estimated(44)，此处显式写出以作说明
    override func itemHeightDimension(
        for environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutDimension {
        .estimated(44)
    }
}

@available(iOS 13.0, *)
private final class TextRowCell: HaomissyouCollectionViewCell {
    private let indexLabel = UILabel()
    private let bodyLabel  = UILabel()

    override func setupViews() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        indexLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        indexLabel.textColor = .tertiaryLabel
        indexLabel.setContentHuggingPriority(.required, for: .horizontal)
        indexLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.textColor = .label
        bodyLabel.numberOfLines = 0

        [indexLabel, bodyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            indexLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            indexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            bodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(text: String, index: Int) {
        indexLabel.text = "\(index + 1)."
        bodyLabel.text = text
    }
}
