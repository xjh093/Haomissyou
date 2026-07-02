//
//  DemoListViewController.swift
//  HaomissyouListKit – Demo
//
//  Created by Haomissyou on 7/2/26.
//
//  入口页：用一个普通 UITableView 列出所有 Demo，点击后 push 对应 Demo 控制器。
//

import UIKit

final class DemoListViewController: UITableViewController {

    private struct DemoEntry {
        let title: String
        let subtitle: String
        let make: () -> UIViewController
    }

    private lazy var entries: [DemoEntry] = [
        DemoEntry(
            title: "SingleSection Demo",
            subtitle: "一个 section，单 cell，自动高度",
            make: { SingleSectionDemoViewController() }
        ),
        DemoEntry(
            title: "FlowSection Demo",
            subtitle: "多列固定高度，section 背景色 + 圆角",
            make: { FlowSectionDemoViewController() }
        ),
        DemoEntry(
            title: "Waterfall Demo",
            subtitle: "瀑布流，动态高度，section 背景",
            make: { WaterfallDemoViewController() }
        ),
        DemoEntry(
            title: "MultiItem Demo",
            subtitle: "单 section 内多种 cell 类型",
            make: { MultiItemDemoViewController() }
        ),
        DemoEntry(
            title: "Compositional Demo",
            subtitle: "iOS 13+ Compositional Layout，横向滚动",
            make: { CompositionalDemoViewController() }
        ),
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HaomissyouListKit Demos"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let entry = entries[indexPath.row]
        cell.textLabel?.text = entry.title
        cell.detailTextLabel?.text = entry.subtitle
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "共 \(entries.count) 个 Demo"
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = entries[indexPath.row].make()
        vc.title = entries[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }
}
