//
//  SingleSectionDemoViewController.swift
//  HaomissyouListKit – Demo
//
//  Created by Haomissyou on 7/2/26.
//
//  演示：多个 SingleSectionController 拼合成一屏，每个 section 只有一个 cell。
//  cell 内容为多行文字，高度由 Auto Layout 自动计算。
//

import UIKit

// MARK: - View Controller

final class SingleSectionDemoViewController: UIViewController {

    private lazy var collectionView: HaomissyouCollectionView = {
        let cv = HaomissyouCollectionView(frame: .zero)
        cv.listDataSource = self
        cv.viewController = self
        return cv
    }()

    private lazy var textCardSectionControllers: [TextCardSectionController] = items.map { item in
        let sc = TextCardSectionController()
        sc.didUpdate(to: item)
        sc.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
        return sc
    }

    private let items: [(title: String, body: String)] = [
        ("欢迎使用 HaomissyouListKit",
         "这是一个轻量级 UICollectionView 框架，基于 Section Controller 架构。"),
        ("SingleSectionController",
         "每个 SectionController 负责独立的 section，只需重写 cellForItem(at:) 和 sizeForItem(at:)。\n\n" +
         "自动高度场景：contentView 建立完整约束链，无需手动计算高度。"),
        ("自动高度",
         "开启 FlowLayout.estimatedItemSize = .automaticSize 后，\n" +
         "HaomissyouCollectionViewCell 已覆写 preferredLayoutAttributesFitting(_:)，\n" +
         "Auto Layout 会自动撑开 cell 高度。\n\n" +
         "这段文字故意写长一点，用来展示多行自动高度效果。".repeated(3)),
        ("数据更新",
         "调用 collectionView.reloadData() 可整体刷新。\n" +
         "调用 sectionController.reload() 可仅刷新本 section。"),
        ("滚动代理",
         "设置 cv.scrollDelegate 即可监听 UIScrollViewDelegate 事件，\n" +
         "无需破坏内部 dataSource / delegate 绑定。"),
        ("欢迎使用 HaomissyouListKit",
         "这是一个轻量级 UICollectionView 框架，基于 Section Controller 架构。"),
        ("SingleSectionController",
         "每个 SectionController 负责独立的 section，只需重写 cellForItem(at:) 和 sizeForItem(at:)。\n\n" +
         "自动高度场景：contentView 建立完整约束链，无需手动计算高度。"),
        ("自动高度",
         "开启 FlowLayout.estimatedItemSize = .automaticSize 后，\n" +
         "HaomissyouCollectionViewCell 已覆写 preferredLayoutAttributesFitting(_:)，\n" +
         "Auto Layout 会自动撑开 cell 高度。\n\n" +
         "这段文字故意写长一点，用来展示多行自动高度效果。".repeated(3)),
        ("数据更新",
         "调用 collectionView.reloadData() 可整体刷新。\n" +
         "调用 sectionController.reload() 可仅刷新本 section。"),
        ("滚动代理",
         "设置 cv.scrollDelegate 即可监听 UIScrollViewDelegate 事件，\n" +
         "无需破坏内部 dataSource / delegate 绑定。"),
    ]

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
        collectionView.reloadData()
    }
}

extension SingleSectionDemoViewController: HaomissyouCollectionViewDataSource {

    func sectionControllers(for collectionView: HaomissyouCollectionView) -> [HaomissyouSectionController] {
        textCardSectionControllers
    }
}

// MARK: - Section Controller

private final class TextCardSectionController: HaomissyouSingleSectionController {

    private var title: String = ""
    private var body: String = ""
    /// 按 columnWidth 缓存，宽度变化（旋转等）时自动重算
    private var cachedWidth: CGFloat = 0
    private var cachedSize: CGSize = .zero

    override func didUpdate(to object: Any?) {
        if let item = object as? (title: String, body: String) {
            title = item.title
            body  = item.body
            cachedWidth = 0   // 内容变化，使缓存失效
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = dequeueReusableCell(TextCardCell.self, at: index)
        cell.configure(title: title, body: body)
        return cell
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let width = columnWidth
        guard width != cachedWidth else {
            print("使用缓存\(cachedSize)")
            return cachedSize
        }
        cachedWidth = width
        let textWidth = width - 14 * 2
        let bound = CGSize(width: textWidth, height: .infinity)
        let titleH = ceil(title.boundingRect(with: bound, options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .semibold)], context: nil).height)
        let bodyH  = ceil(body .boundingRect(with: bound, options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 13)], context: nil).height)
        cachedSize = CGSize(width: width, height: titleH + bodyH + 14 + 6 + 14)
        print("使用\(cachedSize)")
        
        return cachedSize
    }
}

// MARK: - Cell

private final class TextCardCell: HaomissyouCollectionViewCell {

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.numberOfLines = 0
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    override func setupViews() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        [titleLabel, bodyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])
    }

    func configure(title: String, body: String) {
        titleLabel.text = title
        bodyLabel.text = body
    }
}

// MARK: - Helpers

private extension String {
    func repeated(_ count: Int) -> String {
        Array(repeating: self, count: count).joined(separator: "\n")
    }
}
