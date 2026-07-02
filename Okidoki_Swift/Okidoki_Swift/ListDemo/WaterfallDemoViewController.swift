//
//  WaterfallDemoViewController.swift
//  HaomissyouListKit – Demo
//
//  Created by Haomissyou on 7/2/26.
//
//  演示：
//    - 两个瀑布流 section，列数分别为 2、3
//    - 每个 item 高度随机，充分展示瀑布流效果
//    - section 背景色与圆角
//    - 右上角按钮重新生成随机数据并整体 reloadData
//

import UIKit

// MARK: - View Controller

final class WaterfallDemoViewController: UIViewController {

    private lazy var collectionView = HaomissyouCollectionView.waterfall(frame: .zero)

    private var sectionControllers: [PhotoWaterfallSectionController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "换一批",
            style: .plain,
            target: self,
            action: #selector(refreshData))

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

        buildData()
        collectionView.reloadData()
    }

    private func buildData() {
        let configs: [(columns: Int, color: UIColor)] = [
            (2, UIColor.systemTeal.withAlphaComponent(0.10)),
            (3, UIColor.systemPurple.withAlphaComponent(0.10)),
        ]
        sectionControllers = configs.map { cfg in
            let sc = PhotoWaterfallSectionController()
            sc.columnCount = cfg.columns
            sc.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            sc.minimumLineSpacing = 8
            sc.minimumInteritemSpacing = 8
            sc.sectionBackgroundColor = cfg.color
            sc.sectionBackgroundCornerRadius = 14
            sc.sectionBackgroundInset = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            sc.generateItems(count: Int.random(in: 8...14))
            return sc
        }
    }

    @objc private func refreshData() {
        buildData()
        collectionView.reloadData()
    }
}

extension WaterfallDemoViewController: HaomissyouCollectionViewDataSource {

    func sectionControllers(for collectionView: HaomissyouCollectionView) -> [HaomissyouSectionController] {
        sectionControllers
    }
}

// MARK: - Section Controller

private final class PhotoWaterfallSectionController: HaomissyouWaterfallSectionController {

    private struct Item {
        let color: UIColor
        let height: CGFloat   // 对应 item 本体高度（不含宽度）
        let label: String
    }

    private var items: [Item] = []

    private static let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen,
        .systemTeal, .systemBlue, .systemIndigo, .systemPurple,
        .systemPink, .systemBrown, .systemCyan, .systemMint,
    ]

    func generateItems(count: Int) {
        items = (0..<count).map { i in
            Item(
                color: Self.colors[i % Self.colors.count].withAlphaComponent(0.75),
                height: CGFloat.random(in: 80...200),
                label: "#\(i + 1)"
            )
        }
    }

    override func numberOfItems() -> Int { items.count }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(WaterfallCell.self, at: index)
        cell.configure(color: items[index].color, label: items[index].label)
        return cell
    }

    override func heightForItem(at index: Int, width: CGFloat) -> CGFloat {
        items[index].height
    }

    override func didSelectItem(at index: Int) {
        print("[WaterfallDemo] tapped section=\(section) index=\(index)")
    }
}

// MARK: - Cell

private final class WaterfallCell: HaomissyouCollectionViewCell {

    private let label = UILabel()

    override func setupViews() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(color: UIColor, label text: String) {
        contentView.backgroundColor = color
        label.text = text
    }
}
