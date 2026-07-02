//
//  MultiItemDemoViewController.swift
//  HaomissyouListKit – Demo
//
//  Created by Haomissyou on 7/2/26.
//
//  演示：
//    - 单个 section 内包含多种 cell 类型（Banner、标签列表、简介文字、操作按钮）
//    - 每种 cell 由独立的 HaomissyouItemController 子类负责
//    - 点击操作按钮后局部刷新简介区块
//

import UIKit

// MARK: - Model

private struct ArticleModel {
    var title: String
    var tags: [String]
    var summary: String
    var likeCount: Int
}

// MARK: - View Controller

final class MultiItemDemoViewController: UIViewController {

    private lazy var collectionView = HaomissyouCollectionView(frame: .zero)
    private var articleSC: ArticleSectionController?

    private var model = ArticleModel(
        title: "HaomissyouListKit MultiItem Demo",
        tags: ["Swift", "UICollectionView", "Section Controller", "Multi Cell"],
        summary: "MultiItemSectionController 允许在同一个 section 里组合任意多种 cell 类型。" +
                 "每种 cell 由独立的 ItemController 管理，数据分发通过 distributeObject(_:to:) 完成。",
        likeCount: 0
    )

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

extension MultiItemDemoViewController: HaomissyouCollectionViewDataSource {

    func sectionControllers(for collectionView: HaomissyouCollectionView) -> [HaomissyouSectionController] {
        // 头部间距 section（空白占位）
        let spacer = SpacerSectionController()

        // 核心：文章 section
        let sc = ArticleSectionController()
        sc.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        sc.minimumLineSpacing = 12
        sc.onLike = { [weak self] in
            guard let self else { return }
            self.model.likeCount += 1
            sc.didUpdate(to: self.model)
        }
        sc.didUpdate(to: model)
        articleSC = sc

        return [spacer, sc]
    }
}

// MARK: - SpacerSectionController

private final class SpacerSectionController: HaomissyouSingleSectionController {
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        dequeueReusableCell(SpacerCell.self, at: index)
    }
    override func sizeForItem(at index: Int) -> CGSize {
        CGSize(width: collectionView?.bounds.width ?? 0, height: 16)
    }
}

private final class SpacerCell: UICollectionViewCell {}

// MARK: - ArticleSectionController

private final class ArticleSectionController: HaomissyouMultiItemSectionController {

    var onLike: (() -> Void)?

    private let titleIC   = ArticleTitleItemController()
    private let tagsIC    = ArticleTagsItemController()
    private let summaryIC = ArticleSummaryItemController()
    private let actionIC  = ArticleActionItemController()

    override init() {
        super.init()
        itemControllers = [titleIC, tagsIC, summaryIC, actionIC]
        actionIC.onLike = { [weak self] in self?.onLike?() }
    }

    override func distributeObject(_ object: Any?, to itemController: HaomissyouItemController) {
        guard let model = object as? ArticleModel else { return }
        if itemController === titleIC   { titleIC.didUpdate(to: model.title) }
        if itemController === tagsIC    { tagsIC.didUpdate(to: model.tags) }
        if itemController === summaryIC { summaryIC.didUpdate(to: model.summary) }
        if itemController === actionIC  { actionIC.didUpdate(to: model.likeCount) }
    }
}

// MARK: - Title Item Controller

private final class ArticleTitleItemController: HaomissyouItemController {

    private var title: String = ""

    override func didUpdate(to object: Any?) { title = object as? String ?? "" }

    override func cellForCollectionView(_ cv: HaomissyouCollectionView,
                                        at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(ArticleTitleCell.self, at: indexPath)
        cell.configure(title: title)
        return cell
    }

    override func sizeForCollectionView(_ cv: HaomissyouCollectionView) -> CGSize {
        CGSize(width: columnWidth, height: 52)
    }
}

private final class ArticleTitleCell: HaomissyouCollectionViewCell {
    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.numberOfLines = 0
        return l
    }()
    override func setupViews() {
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }
    func configure(title: String) { label.text = title }
}

// MARK: - Tags Item Controller

private final class ArticleTagsItemController: HaomissyouItemController {

    private var tags: [String] = []

    override func didUpdate(to object: Any?) { tags = object as? [String] ?? [] }

    override func cellForCollectionView(_ cv: HaomissyouCollectionView,
                                        at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(ArticleTagsCell.self, at: indexPath)
        cell.configure(tags: tags)
        return cell
    }

    override func sizeForCollectionView(_ cv: HaomissyouCollectionView) -> CGSize {
        CGSize(width: columnWidth, height: 32)
    }
}

private final class ArticleTagsCell: HaomissyouCollectionViewCell {
    private let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    override func setupViews() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(tags: [String]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in tags {
            let pill = makePill(tag)
            stack.addArrangedSubview(pill)
        }
    }

    private func makePill(_ text: String) -> UIView {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = .systemBlue
        l.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        l.textAlignment = .center
        l.layer.cornerRadius = 4
        l.layer.masksToBounds = true
        // padding via intrinsic size trick
        l.setContentHuggingPriority(.required, for: .horizontal)
        let wrapper = UIView()
        l.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 3),
            l.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -3),
            l.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 6),
            l.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -6),
        ])
        return wrapper
    }
}

// MARK: - Summary Item Controller

private final class ArticleSummaryItemController: HaomissyouItemController {

    private var summary: String = ""
    private var cachedWidth: CGFloat = 0
    private var cachedSize: CGSize = .zero

    override func didUpdate(to object: Any?) {
        summary = object as? String ?? ""
        cachedWidth = 0   // 内容变化，使缓存失效
    }

    override func cellForCollectionView(_ cv: HaomissyouCollectionView,
                                        at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(ArticleSummaryCell.self, at: indexPath)
        cell.configure(text: summary)
        return cell
    }

    override func sizeForCollectionView(_ cv: HaomissyouCollectionView) -> CGSize {
        let width = columnWidth
        guard width != cachedWidth else { return cachedSize }
        cachedWidth = width
        // bg 内边距各 12pt，左右合计 24pt
        let textWidth = width - 12 * 2
        let h = ceil(summary.boundingRect(
            with: CGSize(width: textWidth, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 14)],
            context: nil).height)
        // top(12) + text + bottom(12)
        cachedSize = CGSize(width: width, height: h + 12 + 12)
        return cachedSize
    }
}

private final class ArticleSummaryCell: HaomissyouCollectionViewCell {
    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    private let bg = UIView()

    override func setupViews() {
        bg.backgroundColor = .secondarySystemGroupedBackground
        bg.layer.cornerRadius = 8
        bg.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bg)
        bg.addSubview(label)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: contentView.topAnchor),
            bg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            label.topAnchor.constraint(equalTo: bg.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -12),
        ])
    }
    func configure(text: String) { label.text = text }
}

// MARK: - Action Item Controller

private final class ArticleActionItemController: HaomissyouItemController {

    var onLike: (() -> Void)?
    private var likeCount: Int = 0
    private weak var likeButton: UIButton?

    override func didUpdate(to object: Any?) {
        likeCount = object as? Int ?? 0
        likeButton?.setTitle("👍  点赞 \(likeCount)", for: .normal)
    }

    override func cellForCollectionView(_ cv: HaomissyouCollectionView,
                                        at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(ArticleActionCell.self, at: indexPath)
        cell.configure(likeCount: likeCount, onLike: { [weak self] in self?.onLike?() })
        likeButton = cell.likeButton
        return cell
    }

    override func sizeForCollectionView(_ cv: HaomissyouCollectionView) -> CGSize {
        CGSize(width: columnWidth, height: 44)
    }
}

private final class ArticleActionCell: HaomissyouCollectionViewCell {

    private(set) var likeButton: UIButton!
    private var onLike: (() -> Void)?

    override func setupViews() {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.baseBackgroundColor = .systemPink
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            btn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            btn.heightAnchor.constraint(equalToConstant: 36),
            btn.widthAnchor.constraint(equalToConstant: 120),
        ])
        likeButton = btn
    }

    func configure(likeCount: Int, onLike: @escaping () -> Void) {
        likeButton.setTitle("👍  点赞 \(likeCount)", for: .normal)
        self.onLike = onLike
    }

    @objc private func didTapLike() { onLike?() }
}
