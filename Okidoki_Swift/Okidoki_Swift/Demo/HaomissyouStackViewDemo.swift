//
//  HaomissyouStackViewDemo.swift
//  HaomissyouStackView 完整接口演示
//
//  包含以下 Demo：
//  Demo 1  - 基础水平布局 + 枚举 axis / alignment / justifyContent
//  Demo 2  - 内边距 (insets) 与全局间距 (spacing)
//  Demo 3  - justifyContent 八种分布方式
//  Demo 4  - 主轴弹性权重 flex (flexValue)
//  Demo 5  - 弹性空间 flexSpace (JustifyFill 专属)
//  Demo 6  - 每个 view 的单独间距 spacing / minSpacing / maxSpacing
//  Demo 7  - 纵轴单独对齐 alignSelf + start/end 偏移
//  Demo 8  - HaomissyouFlexItem 链式尺寸约束
//  Demo 9  - 外观链式接口 (背景色/圆角/边框/阴影)
//  Demo 10 - 点击事件 tapAction / visibility / alphaValue / userActive
//  Demo 11 - 动态增删 arrangedSubview + setCustomSpacing 动态更新
//  Demo 12 - 嵌套 StackView + wrapScrollView 横向滚动
//  Demo 13 - 链式工厂方法 + addViewMake / addViewIf / assignToPtr
//  Demo 14 - 布局约束链式方法 (addTo / edge / size / center)
//  Demo 15 - HaomissyouScrollView RTL 演示容器
//

import UIKit

// MARK: - Demo 入口 ViewController

/// 将该 ViewController 设置为 rootViewController 即可运行所有 Demo
public final class HaomissyouDemoListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let demos: [(title: String, subtitle: String, make: () -> UIViewController)] = [
        ("Demo 1",  "基础 axis / alignment / justifyContent",      { HaomissyouDemo1ViewController() }),
        ("Demo 2",  "内边距 insets 与全局间距 spacing",               { HaomissyouDemo2ViewController() }),
        ("Demo 3",  "justifyContent 八种分布方式",                    { HaomissyouDemo3ViewController() }),
        ("Demo 4",  "弹性权重 flexValue",                            { HaomissyouDemo4ViewController() }),
        ("Demo 5",  "弹性空间 flexSpace (JustifyFill)",              { HaomissyouDemo5ViewController() }),
        ("Demo 6",  "每个 view 的单独间距 spacing / min / max",       { HaomissyouDemo6ViewController() }),
        ("Demo 7",  "纵轴单独对齐 alignSelf + start/end 偏移",        { HaomissyouDemo7ViewController() }),
        ("Demo 8",  "FlexItem 链式尺寸约束",                          { HaomissyouDemo8ViewController() }),
        ("Demo 9",  "外观链式接口 背景/圆角/边框/阴影",                  { HaomissyouDemo9ViewController() }),
        ("Demo 10", "tapAction / visibility / alpha / userActive",  { HaomissyouDemo10ViewController() }),
        ("Demo 11", "动态增删 + setCustomSpacing 动态更新",            { HaomissyouDemo11ViewController() }),
        ("Demo 12", "嵌套 StackView + wrapScrollView 横向滚动",       { HaomissyouDemo12ViewController() }),
        ("Demo 13", "链式工厂 addViewMake / addViewIf / assignToPtr", { HaomissyouDemo13ViewController() }),
        ("Demo 14", "布局约束链式 addTo / edge / size / center",      { HaomissyouDemo14ViewController() }),
        ("Demo 15", "HaomissyouScrollView LTR/RTL 对比演示",         { HaomissyouDemo15ViewController() }),
    ]

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "HaomissyouStackView Demos"
        view.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate   = self
        view.addSubview(tableView)
    }
}

extension HaomissyouDemoListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { demos.count }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = demos[indexPath.row].title
        cell.detailTextLabel?.text = demos[indexPath.row].subtitle
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = demos[indexPath.row].make()
        vc.title = demos[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 颜色快捷方式（仅 Demo 内部使用）

private extension UIColor {
    static let hmBlue   = UIColor(red: 0.20, green: 0.51, blue: 0.95, alpha: 1)
    static let hmGreen  = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)
    static let hmOrange = UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1)
    static let hmPink   = UIColor(red: 1.00, green: 0.17, blue: 0.33, alpha: 1)
    static let hmPurple = UIColor(red: 0.56, green: 0.27, blue: 0.68, alpha: 1)
    static let hmTeal   = UIColor(red: 0.00, green: 0.73, blue: 0.83, alpha: 1)
    static let hmYellow = UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1)
    static let hmGray   = UIColor.systemGray4
}

private func colorBox(_ color: UIColor, _ text: String = "", width: CGFloat = 60, height: CGFloat = 40) -> UIView {
    let v = UIView()
    v.backgroundColor = color
    v.layer.cornerRadius = 6
    if !text.isEmpty {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 11)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: v.topAnchor),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor),
        ])
    }
    if width > 0 { v.hmFlex.w(width) }
    if height > 0 { v.hmFlex.h(height) }
    return v
}

private func section(title: String) -> UILabel {
    let l = UILabel()
    l.text = "▌ " + title
    l.font = .boldSystemFont(ofSize: 13)
    l.textColor = .secondaryLabel
    return l
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 1  基础 axis / alignment / justifyContent（枚举值直接赋值）
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo1ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 使用枚举属性赋值
        let row1 = HaomissyouStackView()
        row1.axis           = .horizontal          // HaomissyouStackViewAxis
        row1.alignment      = .center              // HaomissyouAlign
        row1.justifyContent = .start               // HaomissyouJustify
        row1.spacing        = 8
        row1.insets         = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        [UIColor.hmBlue, .hmGreen, .hmOrange, .hmPink].forEach {
            row1.addArrangedSubview(colorBox($0))
        }

        // 使用链式方法（工厂方法 + 方法链）
        let row2 = HaomissyouStackView.horizontal()
            .alignCenter()
            .justifyCenter()
            .space(12)
            .inset(8, 8, 8, 8)
        [UIColor.hmPurple, .hmTeal, .hmYellow].forEach {
            row2.addArrangedSubview(colorBox($0))
        }

        // 垂直布局
        let col = HaomissyouStackView.vertical()
            .alignFill()
            .justifyStart()
            .space(6)
            .inset(8, 8, 8, 8)
        [UIColor.hmBlue, .hmGreen, .hmOrange].forEach {
            col.addArrangedSubview(colorBox($0, width: 0, height: 36))
        }

        let root = HaomissyouStackView.vertical()
            .space(16)
            .inset(20, 16, 20, 16)
        root.addArrangedSubview(section(title: "axis=horizontal, alignment=center, justifyContent=start"))
        root.addArrangedSubview(row1)
        root.addArrangedSubview(section(title: "axis=horizontal, alignCenter(), justifyCenter()"))
        root.addArrangedSubview(row2)
        root.addArrangedSubview(section(title: "axis=vertical, alignFill(), justifyStart()"))
        root.addArrangedSubview(col)
        root.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        row1.backgroundColor =  UIColor.lightGray.withAlphaComponent(0.5)
        row2.backgroundColor =  UIColor.lightGray.withAlphaComponent(0.5)
        col.backgroundColor =  UIColor.lightGray.withAlphaComponent(0.5)
        
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 2  内边距 insets 与全局间距 spacing
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo2ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // inset(top, leading, bottom, trailing)
        let row1 = HaomissyouStackView.horizontal()
            .inset(12, 20, 12, 20)
            .space(16)
            .bgColor(.hmGray)
            .corner(8)
        [UIColor.hmBlue, .hmGreen, .hmOrange].forEach { row1.addArrangedSubview(colorBox($0)) }

        // hInset(leading, trailing) — 只设置水平内边距
        let row2 = HaomissyouStackView.horizontal()
            .hInset(30, 30)
            .space(8)
            .bgColor(.hmGray)
            .corner(8)
        [UIColor.hmPink, .hmPurple].forEach { row2.addArrangedSubview(colorBox($0)) }

        // vInset(top, bottom) — 只设置垂直内边距
        let row3 = HaomissyouStackView.vertical()
            .vInset(16, 16)
            .space(8)
            .bgColor(.hmGray)
            .corner(8)
        [UIColor.hmTeal, .hmYellow, .hmBlue].forEach { row3.addArrangedSubview(colorBox($0, width: 0, height: 30)) }

        let root = HaomissyouStackView.vertical()
            .space(20)
            .inset(20, 16, 20, 16)
        root.addArrangedSubview(section(title: "inset(top:12 leading:20 bottom:12 trailing:20) space:16"))
        root.addArrangedSubview(row1)
        root.addArrangedSubview(section(title: "hInset(30, 30)"))
        root.addArrangedSubview(row2)
        root.addArrangedSubview(section(title: "vInset(16, 16) — 垂直布局"))
        root.addArrangedSubview(row3)

        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 3  justifyContent 八种分布方式
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo3ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let justifies: [(HaomissyouJustify, String)] = [
            (.start,         "start"),
            (.center,        "center"),
            (.end,           "end"),
            (.fill,          "fill"),
            (.fillEqually,   "fillEqually"),
            (.spaceBetween,  "spaceBetween"),
            (.spaceAround,   "spaceAround"),
            (.spaceEvenly,   "spaceEvenly"),
        ]

        let colors: [UIColor] = [.hmBlue, .hmGreen, .hmOrange]

        let root = HaomissyouStackView.vertical()
            .space(12)
            .inset(16, 16, 16, 16)

        justifies.forEach { (justify, name) in
            root.addArrangedSubview(section(title: "justifyContent = .\(name)"))

            let row = HaomissyouStackView.horizontal()
                .bgColor(UIColor.hmGray)
                .corner(8)
                .inset(4, 4, 4, 4)
            row.justifyContent = justify
            row.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)

            let boxWidth: CGFloat = justify == .fill ? 0 : 50
            colors.forEach { row.addArrangedSubview(colorBox($0, width: boxWidth)) }
            root.addArrangedSubview(row)
        }

        let scroll = root.wrapScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 4  弹性权重 flexValue
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo4ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // ---------- 水平方向 flex 权重 ----------
        // 1:2:3 分配宽度
        let hRow = HaomissyouStackView.horizontal().justifyFill().space(4).inset(4, 8, 4, 8)
        let hBox1 = colorBox(.hmBlue,   "flex 1")
        let hBox2 = colorBox(.hmGreen,  "flex 2")
        let hBox3 = colorBox(.hmOrange, "flex 3")
        // 通过 FlexItem 链式
        hBox1.hmFlex.flex(1)
        hBox2.hmFlex.flex(2)
        hBox3.hmFlex.flex(3)
        [hBox1, hBox2, hBox3].forEach { hRow.addArrangedSubview($0) }

        // ---------- 通过 stackView 接口设置 flex ----------
        let hRow2 = HaomissyouStackView.horizontal().justifyFill().space(4).inset(4, 8, 4, 8)
        let a = colorBox(.hmPink,   "1"); let b = colorBox(.hmPurple, "3")
        [a, b].forEach { hRow2.addArrangedSubview($0) }
        hRow2.setFlex(1, forView: a)   // setFlex(_:forView:)
        hRow2.setFlex(3, forView: b)

        // ---------- flexFor 链式 ----------
        let hRow3 = HaomissyouStackView.horizontal()
            .justifyFill()
            .space(4)
            .inset(4, 8, 4, 8)
        let c = colorBox(.hmTeal);  let d = colorBox(.hmYellow)
        hRow3
            .addView(c).insertSpace(4)
            .addView(d)
            .flexFor(2, view: c)     // flexFor(_:view:)
            .flexFor(1, view: d)

        // ---------- 垂直方向 flex 权重 ----------
        let vCol = HaomissyouStackView.vertical().justifyFill().space(4).inset(4, 8, 4, 8)
        let vBox1 = colorBox(.hmBlue,   "flex 1", width: 0, height: 0)
        let vBox2 = colorBox(.hmGreen,  "flex 2", width: 0, height: 0)
        vBox1.hmFlex.flex(1)
        vBox2.hmFlex.flex(2)
        [vBox1, vBox2].forEach { vCol.addArrangedSubview($0) }

        let root = HaomissyouStackView.vertical().space(16).inset(20, 16, 20, 16)
        root.addArrangedSubview(section(title: "水平 flex 1:2:3（FlexItem 链式）"))
        root.addArrangedSubview(hRow)
        root.addArrangedSubview(section(title: "水平 flex 1:3（setFlex 方法）"))
        root.addArrangedSubview(hRow2)
        root.addArrangedSubview(section(title: "水平 flex 2:1（flexFor 链式）"))
        root.addArrangedSubview(hRow3)
        root.addArrangedSubview(section(title: "垂直 flex 1:2（总高 120pt）"))
        let vWrap = HaomissyouStackView.horizontal().inset(0, 8, 0, 8)
        vCol.hmFlex.h(120)
        vWrap.addArrangedSubview(vCol)
        root.addArrangedSubview(vWrap)

        hRow.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        hRow2.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        hRow3.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        vWrap.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 5  弹性空间 flexSpace (JustifyFill 专属)
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo5ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 左对齐：第二个 view 后面放弹性空间，把剩余内容推到右边
        // "左"  [弹性空间]  "右"
        let row1 = HaomissyouStackView.horizontal().justifyFill().inset(0, 8, 0, 8)
        let left  = colorBox(.hmBlue, "Left")
        let right = colorBox(.hmOrange, "Right")
        row1.addArrangedSubview(left)
        row1.addArrangedSubview(right)
        row1.setFlexibleSpacing(true, afterView: left)  // setFlexibleSpacing(_:afterView:)

        // flexSpacingAfter 链式
        let row2 = HaomissyouStackView.horizontal().justifyFill().inset(0, 8, 0, 8)
        let l2 = colorBox(.hmGreen, "L"); let m2 = colorBox(.hmPurple, "M"); let r2 = colorBox(.hmPink, "R")
        row2.addArrangedSubview(l2)
        row2.addArrangedSubview(m2)
        row2.addArrangedSubview(r2)
        row2.flexSpacingAfter(true, view: l2)   // 左侧弹性
        row2.flexSpacingAfter(true, view: m2)   // 中间也弹性 → 均匀分布

        // insertFlexSpace 链式（addView 之后立刻插入弹性）
        let row3 = HaomissyouStackView.horizontal().justifyFill().inset(0, 8, 0, 8)
        row3
            .addView(colorBox(.hmTeal,   "A"))
            .insertFlexSpace(true)             // A 后面弹性
            .addView(colorBox(.hmYellow, "B"))
            .insertFlexSpace(true)             // B 后面弹性
            .addView(colorBox(.hmBlue,   "C"))

        let root = HaomissyouStackView.vertical().space(16).inset(20, 16, 20, 16)
        root.addArrangedSubview(section(title: "setFlexibleSpacing — 左右分布"))
        root.addArrangedSubview(row1)
        root.addArrangedSubview(section(title: "flexSpacingAfter — 两个弹性空间"))
        root.addArrangedSubview(row2)
        root.addArrangedSubview(section(title: "insertFlexSpace — 链式插入弹性"))
        root.addArrangedSubview(row3)

        row1.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        row2.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        row3.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 6  每个 view 的单独间距 spacing / minSpacing / maxSpacing
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo6ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // setCustomSpacing / spacingAfter
        let row1 = HaomissyouStackView.horizontal().inset(4, 8, 4, 8)
        let b1 = colorBox(.hmBlue,   "A")
        let b2 = colorBox(.hmGreen,  "B")
        let b3 = colorBox(.hmOrange, "C")
        [b1, b2, b3].forEach { row1.addArrangedSubview($0) }
        row1.setCustomSpacing(4,  afterView: b1)   // A→B: 4
        row1.setCustomSpacing(24, afterView: b2)   // B→C: 24

        // spacingAfter 链式
        let row2 = HaomissyouStackView.horizontal().inset(4, 8, 4, 8)
        let c1 = colorBox(.hmPink,   "X")
        let c2 = colorBox(.hmPurple, "Y")
        let c3 = colorBox(.hmTeal,   "Z")
        [c1, c2, c3].forEach { row2.addArrangedSubview($0) }
        row2.spacingAfter(32, view: c1).spacingAfter(8, view: c2)

        // insertSpace / insertMinSpace / insertMaxSpace
        let row3 = HaomissyouStackView.horizontal().inset(4, 8, 4, 8)
        row3
            .addView(colorBox(.hmBlue,   "P"))
            .insertSpace(20)         // P 后固定 20
            .addView(colorBox(.hmGreen,  "Q"))
            .insertMinSpace(10)      // Q 后最小 10
            .insertMaxSpace(40)      // Q 后最大 40
            .addView(colorBox(.hmOrange, "R"))

        // FlexItem 链式：space / minSpace / maxSpace
        let row4 = HaomissyouStackView.horizontal().inset(4, 8, 4, 8)
        let d1 = colorBox(.hmYellow, "M")
        let d2 = colorBox(.hmPink,   "N")
        d1.hmFlex.space(30)         // M 后面固定 30
        d2.hmFlex.minSpace(5).maxSpace(50)
        [d1, d2, colorBox(.hmPurple, "O")].forEach { row4.addArrangedSubview($0) }

        let root = HaomissyouStackView.vertical().space(16).inset(20, 16, 20, 16)
        root.addArrangedSubview(section(title: "setCustomSpacing(4/24)"))
        root.addArrangedSubview(row1)
        root.addArrangedSubview(section(title: "spacingAfter 链式(32/8)"))
        root.addArrangedSubview(row2)
        root.addArrangedSubview(section(title: "insertSpace / insertMinSpace / insertMaxSpace"))
        root.addArrangedSubview(row3)
        root.addArrangedSubview(section(title: "FlexItem .space(30) / .minSpace(5).maxSpace(50)"))
        root.addArrangedSubview(row4)

        row1.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        row2.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        row3.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        row4.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 7  纵轴单独对齐 alignSelf + start/end 偏移
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo7ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 整行高度固定 70，每个 view 用不同 alignSelf
        func makeRow(title: String, setup: (UIView, UIView, UIView, UIView) -> Void) -> UIView {
            let wrapper = HaomissyouStackView.vertical().space(2)
            wrapper.addArrangedSubview(section(title: title))

            let row = HaomissyouStackView.horizontal()
                .justifySpaceEvenly()
                .bgColor(.hmGray)
                .corner(8)
            row.hmFlex.h(70)

            let views: [UIView] = [
                colorBox(.hmBlue,   ".start",  width: 60, height: 24),
                colorBox(.hmGreen,  ".center", width: 60, height: 24),
                colorBox(.hmOrange, ".end",    width: 60, height: 24),
                colorBox(.hmPink,   ".fill",   width: 60, height: 0),
            ]
            views.forEach { row.addArrangedSubview($0) }
            setup(views[0], views[1], views[2], views[3])
            wrapper.addArrangedSubview(row)
            return wrapper
        }

        // 方式1：FlexItem 链式 .align(_:)
        let w1 = makeRow(title: "FlexItem .align(.start/.center/.end/.fill)") { s, c, e, f in
            s.hmFlex.align(.start)
            c.hmFlex.align(.center)
            e.hmFlex.align(.end)
            f.hmFlex.align(.fill)
        }

        // 方式2：FlexItem 实例方法 .alignStart() 等
        let w2 = makeRow(title: "FlexItem .alignStart() / .alignCenter() 等") { s, c, e, f in
            s.hmFlex.alignStart()
            c.hmFlex.alignCenter()
            e.hmFlex.alignEnd()
            f.hmFlex.alignFill()
        }

        // 方式3：StackView.setAlignment(_:forView:) + alignFor 链式
        let w3 = makeRow(title: "setAlignment / alignFor + start/end 偏移") { s, c, e, f in
            // 设置 start(顶部)偏移 8，end(底部)偏移 4
            s.hmFlex.alignStart().start(8)
            c.hmFlex.alignCenter().start(4).end(4)
            e.hmFlex.alignEnd().end(8)
            f.hmFlex.alignFill().start(4).end(4)
        }

        // 方式4：alignStartSpacingFor / alignEndSpacingFor
        let row4 = HaomissyouStackView.horizontal()
            .justifySpaceEvenly()
            .bgColor(.hmGray)
            .corner(8)
        row4.hmFlex.h(70)
        let v0 = colorBox(.hmTeal,   "top+8",  width: 60, height: 24)
        let v1 = colorBox(.hmPurple, "btm+8",  width: 60, height: 24)
        [v0, v1].forEach { row4.addArrangedSubview($0) }
        row4.setAlignment(.start, forView: v0)
        row4.setAlignmentStartSpacing(8, forView: v0)  // setAlignmentStartSpacing
        row4.setAlignment(.end, forView: v1)
        row4.setAlignmentEndSpacing(8, forView: v1)    // setAlignmentEndSpacing
        // alignStartSpacingFor / alignEndSpacingFor 链式等价
        // row4.alignStartSpacingFor(8, view: v0).alignEndSpacingFor(8, view: v1)

        let root = HaomissyouStackView.vertical().space(12).inset(20, 16, 20, 16)
        root.addArrangedSubview(w1)
        root.addArrangedSubview(w2)
        root.addArrangedSubview(w3)
        root.addArrangedSubview(section(title: "setAlignmentStartSpacing / setAlignmentEndSpacing"))
        root.addArrangedSubview(row4)

        let scroll = root.wrapScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 8  FlexItem 链式尺寸约束
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo8ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let row = HaomissyouStackView.horizontal()
            .justifySpaceEvenly()
            .alignCenter()
            .inset(8, 8, 8, 8)

        // .w(_:) / .h(_:)
        let wh = UIView(); wh.backgroundColor = .hmBlue; wh.layer.cornerRadius = 6
        wh.hmFlex.w(60).h(40)
        addLabel(wh, "w:60 h:40")

        // .square(_:)
        let sq = UIView(); sq.backgroundColor = .hmGreen; sq.layer.cornerRadius = 6
        sq.hmFlex.square(50)
        addLabel(sq, "square:50")

        // .minW / .maxW
        let mw = UIView(); mw.backgroundColor = .hmOrange; mw.layer.cornerRadius = 6
        mw.hmFlex.minW(40).maxW(80).h(36)
        addLabel(mw, "min:40 max:80")

        // .minH / .maxH
        let mh = UIView(); mh.backgroundColor = .hmPink; mh.layer.cornerRadius = 6
        mh.hmFlex.w(50).minH(30).maxH(70)
        addLabel(mh, "w:50 minH:30 maxH:70")

        // .size (width + height 同时)
        // 注意：这里演示通过 UIView extension 的 hmSetWidth/hmSetHeight
        let sz = UIView(); sz.backgroundColor = .hmPurple; sz.layer.cornerRadius = 6
        sz.hmFlex.size = CGSize(width: 55, height: 45)
        addLabel(sz, "size(55,45)")

        [wh, sq, mw, mh, sz].forEach { row.addArrangedSubview($0) }

        let root = HaomissyouStackView.vertical().space(16).inset(20, 16, 20, 16)
        root.addArrangedSubview(section(title: "FlexItem 链式尺寸：w/h/square/minW/maxW/minH/maxH/size"))
        root.addArrangedSubview(row)
        row.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func addLabel(_ view: UIView, _ text: String) {
        let l = UILabel(); l.text = text; l.textColor = .white
        l.font = .systemFont(ofSize: 9); l.textAlignment = .center; l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: view.topAnchor),
            l.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            l.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            l.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 9  外观链式接口
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo9ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // bgColor (UIColor / hex 字符串)
        let r1 = HaomissyouStackView.horizontal()
            .space(8).inset(8, 8, 8, 8)
            .bgColor(UIColor.hmBlue)       // UIColor
        let r2 = HaomissyouStackView.horizontal()
            .space(8).inset(8, 8, 8, 8)
            .bgColor("#FF5733")            // hex 字符串
        [r1, r2].forEach { $0.addArrangedSubview(colorBox(.white, "text", width: 60)) }

        // corner / corners
        let r3 = HaomissyouStackView.horizontal()
            .space(8).inset(8, 8, 8, 8)
            .bgColor(.hmGray)
            .corner(16)                    // 全圆角
        let r4 = HaomissyouStackView.horizontal()
            .space(8).inset(8, 8, 8, 8)
            .bgColor(.hmGray)
            .corner(0)
            .corners([.layerMinXMinYCorner, .layerMaxXMinYCorner])  // 只有上方两角
        [r3, r4].forEach { $0.addArrangedSubview(colorBox(.hmBlue)) }

        // border / borderColor / borderWidth
        let r5 = HaomissyouStackView.horizontal()
            .space(8).inset(8, 8, 8, 8)
            .border(2, UIColor.hmOrange)    // border(width, color)
            .corner(8)
        let r6 = HaomissyouStackView.horizontal()
            .space(8).inset(8, 8, 8, 8)
            .borderColor("#007AFF")         // hex
            .borderWidth(1.5)
            .corner(4)
        [r5, r6].forEach { $0.addArrangedSubview(colorBox(.hmPink)) }

        // shadow: shColor / shOffset / shRadius / shOpacity / masksToBounds
        let r7 = HaomissyouStackView.horizontal()
            .space(8).inset(12, 12, 12, 12)
            .bgColor(.white)
            .corner(10)
            .shColor(UIColor.black)        // 自动设置 opacity:0.2 radius:8 offset:(0,2)
            .masksToBounds(false)
        let r8 = HaomissyouStackView.horizontal()
            .space(8).inset(12, 12, 12, 12)
            .bgColor(.white)
            .corner(10)
            .shColor(UIColor.hmBlue)
            .shOffset(0, 4)               // shOffset
            .shRadius(12)                 // shRadius
            .shOpacity(0.4)               // shOpacity
        [r7, r8].forEach { $0.addArrangedSubview(colorBox(.hmTeal)) }

        let root = HaomissyouStackView.vertical().space(20).inset(24, 16, 24, 16)
        let pairs: [(String, UIView)] = [
            ("bgColor(UIColor) / bgColor(\"#hex\")", makeRow([r1, r2])),
            ("corner(16) / corners(上半部分)",       makeRow([r3, r4])),
            ("border(2,orange) / borderColor+Width", makeRow([r5, r6])),
            ("shColor / shOffset / shRadius / shOpacity", makeRow([r7, r8])),
        ]
        pairs.forEach { (title, row) in
            root.addArrangedSubview(section(title: title))
            root.addArrangedSubview(row)
        }

        let scroll = root.wrapScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func makeRow(_ subviews: [UIView]) -> UIView {
        let row = HaomissyouStackView.horizontal().justifySpaceEvenly().alignCenter()
        subviews.forEach { row.addArrangedSubview($0) }
        return row
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 10  tapAction / visibility / alphaValue / userActive
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo10ViewController: UIViewController {

    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        statusLabel.text = "点击下方任意方块"
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 14)

        // tapAction
        var tapCount = 0
        let tapBox = HaomissyouStackView.horizontal()
            .bgColor(.hmBlue)
            .corner(10)
            .inset(12, 20, 12, 20)
            .tapAction { [weak self] _ in
                tapCount += 1
                self?.statusLabel.text = "tapAction 触发第 \(tapCount) 次"
            }
        tapBox.addArrangedSubview(colorBox(.lightGray.withAlphaComponent(0.5), "点我", width: 60))

        // visibility
        let visBox = HaomissyouStackView.horizontal()
            .bgColor(.hmGreen)
            .corner(10)
            .inset(12, 20, 12, 20)
        let hidden = colorBox(.white, "hidden", width: 60)
        visBox.addArrangedSubview(colorBox(.lightGray.withAlphaComponent(0.5), "visible", width: 60))
        visBox.addArrangedSubview(hidden)
        visBox.addArrangedSubview(colorBox(.lightGray.withAlphaComponent(0.5), "visible", width: 60))
        hidden.isHidden = true   // 初始隐藏，通过 KVO 触发布局更新

        // toggle visibility
        var isVisible = false
        let toggleVis = HaomissyouStackView.horizontal()
            .bgColor(.hmOrange)
            .corner(10)
            .inset(12, 20, 12, 20)
            .tapAction { [weak self] _ in
                isVisible.toggle()
                hidden.isHidden = !isVisible
                self?.statusLabel.text = "中间方块 isHidden = \(!isVisible)"
            }
        toggleVis.addArrangedSubview(colorBox(.lightGray.withAlphaComponent(0.5), "切换 hidden", width: 80))

        // alphaValue
        let alphaBox = HaomissyouStackView.horizontal()
            .bgColor(.hmPurple)
            .corner(10)
            .inset(12, 20, 12, 20)
            .alphaValue(0.4)    // alpha = 0.4
        alphaBox.addArrangedSubview(colorBox(.lightGray.withAlphaComponent(0.5), "alpha 0.4", width: 80))

        // userActive(false)
        let disabledBox = HaomissyouStackView.horizontal()
            .bgColor(.hmPink)
            .corner(10)
            .inset(12, 20, 12, 20)
            .userActive(false)  // 禁止交互
        disabledBox.addArrangedSubview(colorBox(.lightGray.withAlphaComponent(0.5), "userActive OFF", width: 100))

        let root = HaomissyouStackView.vertical().space(16).inset(20, 16, 20, 16)
        root.addArrangedSubview(statusLabel)
        root.addArrangedSubview(section(title: "tapAction"))
        root.addArrangedSubview(tapBox)
        root.addArrangedSubview(section(title: "visibility（点击 orange 切换中间方块）"))
        root.addArrangedSubview(visBox)
        root.addArrangedSubview(toggleVis)
        root.addArrangedSubview(section(title: "alphaValue(0.4)"))
        root.addArrangedSubview(alphaBox)
        root.addArrangedSubview(section(title: "userActive(false)"))
        root.addArrangedSubview(disabledBox)

        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 11  动态增删 + setCustomSpacing 动态更新
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo11ViewController: UIViewController {

    private let stack = HaomissyouStackView.horizontal()
        .justifySpaceEvenly()
        .alignCenter()
        .bgColor(UIColor.systemGray5)
        .corner(10)
        .inset(8, 8, 8, 8)

    private var colorQueue: [UIColor] = [.hmBlue, .hmGreen, .hmOrange, .hmPink, .hmPurple, .hmTeal]
    private var addedViews: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        stack.hmFlex.h(80)

        let addBtn   = makeButton("＋ 添加",  color: .hmBlue)
        let removeBtn = makeButton("－ 移除", color: .hmPink)
        let insertBtn = makeButton("⤵ 插入@0", color: .hmGreen)
        let spacingBtn = makeButton("⟷ 大间距", color: .hmOrange)

        addBtn.addTarget(self, action: #selector(addView),  for: .touchUpInside)
        removeBtn.addTarget(self, action: #selector(removeView), for: .touchUpInside)
        insertBtn.addTarget(self, action: #selector(insertView), for: .touchUpInside)
        spacingBtn.addTarget(self, action: #selector(toggleSpacing), for: .touchUpInside)

        let btnRow = HaomissyouStackView.horizontal()
            .justifySpaceEvenly()
            .space(8)
            .inset(0, 8, 0, 8)
        [addBtn, removeBtn, insertBtn, spacingBtn].forEach { btnRow.addArrangedSubview($0) }

        let root = HaomissyouStackView.vertical().space(16).inset(20, 16, 20, 16)
        root.addArrangedSubview(section(title: "动态 addArrangedSubview / removeArrangedSubview / insert"))
        root.addArrangedSubview(stack)
        root.addArrangedSubview(btnRow)

        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func addView() {
        guard addedViews.count < colorQueue.count else { return }
        let v = colorBox(colorQueue[addedViews.count], "\(addedViews.count+1)", width: 0)
        addedViews.append(v)
        stack.addArrangedSubview(v)                // addArrangedSubview
    }
    @objc private func removeView() {
        guard let last = addedViews.last else { return }
        stack.removeArrangedSubview(last)          // removeArrangedSubview
        addedViews.removeLast()
    }
    @objc private func insertView() {
        let color = colorQueue[addedViews.count % colorQueue.count]
        let v = colorBox(color, "INS", width: 0)
        addedViews.insert(v, at: 0)
        stack.insertArrangedSubview(v, at: 0)     // insertArrangedSubview(_:at:)
    }
    private var spacingLarge = false
    @objc private func toggleSpacing() {
        spacingLarge.toggle()
        guard let first = addedViews.first else { return }
        stack.setCustomSpacing(spacingLarge ? 40 : 0, afterView: first) // setCustomSpacing 动态更新
    }
    private func makeButton(_ title: String, color: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = color
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = .boldSystemFont(ofSize: 12)
        btn.hmFlex.h(36)
        return btn
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 12  嵌套 StackView + wrapScrollView 横向滚动
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo12ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 水平滚动：StackView 内嵌卡片
        let hStack = HaomissyouStackView.horizontal()
            .justifyStart()
            .alignCenter()
            .space(12)
            .inset(8, 16, 8, 16)

        let cardColors: [UIColor] = [.hmBlue, .hmGreen, .hmOrange, .hmPink, .hmPurple, .hmTeal, .hmYellow, .hmBlue]
        cardColors.enumerated().forEach { (i, color) in
            // 每个卡片自身是一个垂直 StackView（嵌套）
            let card = HaomissyouStackView.vertical()
                .alignCenter()
                .space(4)
                .inset(8, 8, 8, 8)
                .bgColor(color)
                .corner(12)
            card.hmFlex.w(90).h(120)

            let icon = UIView()
            icon.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            icon.layer.cornerRadius = 20
            icon.hmFlex.square(40)

            let label = UILabel()
            label.text = "Card \(i + 1)"
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 12)

            card.addArrangedSubview(icon)
            card.addArrangedSubview(label)
            hStack.addArrangedSubview(card)
        }

        let scrollView = hStack.wrapScrollView()    // wrapScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.hmFlex.h(140)

        // 垂直滚动：多行嵌套
        let vStack = HaomissyouStackView.vertical().space(8).inset(8, 16, 8, 16)
        (1...12).forEach { i in
            let row = HaomissyouStackView.horizontal()
                .justifySpaceBetween()
                .alignCenter()
                .bgColor(.hmGray)
                .corner(8)
                .inset(8, 12, 8, 12)
            let left  = UILabel(); left.text = "Row \(i)"; left.font = .systemFont(ofSize: 14)
            let right = colorBox(cardColors[i % cardColors.count], width: 30, height: 24)
            row.addArrangedSubview(left)
            row.addArrangedSubview(right)
            vStack.addArrangedSubview(row)
        }
        let vScroll = vStack.wrapScrollView()       // 再次演示 wrapScrollView()

        let root = HaomissyouStackView.vertical().space(16).inset(16, 0, 16, 0)
        root.addArrangedSubview(section(title: "水平滚动 wrapScrollView() — 横向卡片列表"))
        root.addArrangedSubview(scrollView)
        root.addArrangedSubview(section(title: "垂直滚动 wrapScrollView() — 多行列表"))

        root.translatesAutoresizingMaskIntoConstraints = false
        vScroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        view.addSubview(vScroll)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            root.bottomAnchor.constraint(equalTo: vScroll.topAnchor),
            vScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vScroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 13  链式工厂 addViewMake / addViewIf / assignToPtr
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo13ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let showExtra = true

        // assignToPtr — 把 stackView 本身赋值给外部指针
        var capturedStack: HaomissyouBaseStackView?

        let mainStack = HaomissyouStackView.vertical()
            .space(12)
            .inset(20, 16, 20, 16)
            .assignToPtr(&capturedStack)              // assignToPtr

        // addViewMake — 在 block 内创建并返回 view
        mainStack.addViewMake { stack in              // addViewMake
            let row = HaomissyouStackView.horizontal().justifySpaceEvenly()
            [UIColor.hmBlue, .hmGreen, .hmOrange].forEach {
                row.addArrangedSubview(colorBox($0, width: 60))
            }
            return row
        }

        // addViewIf — 条件为 true 才添加
        mainStack.addArrangedSubview(section(title: "addViewIf(true) 的行（显示），addViewIf(false) 的行（不显示）"))
        mainStack.addViewIf(true,  colorBox(.hmPink,   "if=true",  width: 0))   // 会添加
        mainStack.addViewIf(false, colorBox(.hmGray,   "if=false", width: 0))   // 不添加

        // addViewMakeIf — 条件 + block 创建
        mainStack.addArrangedSubview(section(title: "addViewMakeIf"))
        mainStack.addViewMakeIf(showExtra) { _ in
            colorBox(.hmPurple, "makeIf=true", width: 0)
        }
        mainStack.addViewMakeIf(!showExtra) { _ in
            colorBox(.hmGray, "makeIf=false", width: 0)
        }

        // addViewLayout — 添加时同步配置 FlexItem
        mainStack.addArrangedSubview(section(title: "addViewLayout — 添加时配置 FlexItem"))
        mainStack.addArrangedSubview(UILabel()) { view, flex in     // addArrangedSubview(_:layout:)
            (view as? UILabel)?.text = "addArrangedSubview(_:layout:) — h:30"
            (view as? UILabel)?.font = .systemFont(ofSize: 13)
            flex.h(30)
        }

        // addViewLayout 链式版本
        let inlineBox = UIView()
        mainStack.addViewLayout(inlineBox) { view, flex in          // addViewLayout
            view.backgroundColor = .hmTeal
            view.layer.cornerRadius = 8
            flex.h(40)
        }

        // 验证 assignToPtr
        let info = UILabel()
        info.numberOfLines = 0
        info.font = .systemFont(ofSize: 12)
        info.textColor = .secondaryLabel
        info.text = "capturedStack === mainStack: \(capturedStack === mainStack)"
        mainStack.addArrangedSubview(info)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 14  布局约束链式方法 addTo / edge / size / center
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo14ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // addTo + size + corner
        let box1 = HaomissyouStackView.horizontal()
            .bgColor(.hmBlue)
            .corner(10)
            .addTo(view)                   // addTo(_:)
        box1.hmFlex.w(120).h(50)
        box1.translatesAutoresizingMaskIntoConstraints = false
        box1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        box1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true

        // addToFull — 铺满父视图（用容器限制范围）
        let container = UIView()
        container.backgroundColor = UIColor.hmGray
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: box1.bottomAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 80),
        ])

        HaomissyouStackView.horizontal()
            .bgColor(.hmGreen.withAlphaComponent(0.5))
            .corner(10)
            .addToFull(container)          // addToFull(_:) — 自动 edgesZero()

        // edge(top, leading, bottom, trailing) — 显式四边贴合
        let container2 = UIView()
        container2.backgroundColor = UIColor.hmGray
        container2.layer.cornerRadius = 10
        container2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container2)
        NSLayoutConstraint.activate([
            container2.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 16),
            container2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container2.heightAnchor.constraint(equalToConstant: 80),
        ])

        let inner2 = HaomissyouStackView.horizontal()
            .bgColor(.hmOrange.withAlphaComponent(0.5))
            .corner(10)
        container2.addSubview(inner2)
        inner2.translatesAutoresizingMaskIntoConstraints = false
        inner2.edge(8, 8, 8, 8)           // edge(top, leading, bottom, trailing)

        // width / height / size / square（直接在布局中使用）
        let row = HaomissyouStackView.horizontal()
            .justifySpaceEvenly()
            .alignCenter()
        let a = HaomissyouStackView.horizontal().bgColor(.hmPink).corner(8)
        let b = HaomissyouStackView.horizontal().bgColor(.hmPurple).corner(8)
        let c = HaomissyouStackView.horizontal().bgColor(.hmTeal).corner(8)
        a.width(60); a.height(40)          // width / height
        b.size(50, 50)                     // size(w, h)
        c.square(45)                       // square

        [a, b, c].forEach { row.addArrangedSubview($0) }

        row.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container2.bottomAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        // edgesZero() — 明确贴满父视图
        let container3 = UIView()
        container3.backgroundColor = .hmGray
        container3.layer.cornerRadius = 10
        container3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container3)
        NSLayoutConstraint.activate([
            container3.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 16),
            container3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container3.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container3.heightAnchor.constraint(equalToConstant: 60),
        ])
        let inner3 = HaomissyouStackView.horizontal().bgColor(.hmYellow.withAlphaComponent(0.6)).corner(10)
        container3.addSubview(inner3)
        inner3.translatesAutoresizingMaskIntoConstraints = false
        inner3.edgesZero()                 // edgesZero()

        let lbl = makeInfoLabel("① addTo\n② addToFull(container)\n③ edge(8,8,8,8)\n④ width/height/size/square\n⑤ edgesZero()")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: container3.bottomAnchor, constant: 16),
            lbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            lbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func makeInfoLabel(_ text: String) -> UILabel {
        let l = UILabel(); l.text = text; l.numberOfLines = 0
        l.font = .systemFont(ofSize: 12); l.textColor = .secondaryLabel
        return l
    }
}


// ────────────────────────────────────────────────────────────────────
// MARK: - Demo 15  HaomissyouScrollView RTL 对比演示
// ────────────────────────────────────────────────────────────────────

final class HaomissyouDemo15ViewController: UIViewController {

    private let ltrScrollView = HaomissyouScrollView()
    private let rtlScrollView = HaomissyouScrollView()
    private var ltrStack: HaomissyouStackView?
    
    private let toggleBtn = UIButton(type: .system)
    private var isRTL = false
    private weak var statusLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // ── 卡片内容构建器 ────────────────────────────────────
        func makeCardStack() -> HaomissyouStackView {
            let stack = HaomissyouStackView.horizontal().justifyStart().space(10).inset(8, 12, 8, 12)
            let colors: [UIColor] = [.hmBlue, .hmGreen, .hmOrange, .hmPink, .hmPurple, .hmTeal, .hmYellow]
            colors.enumerated().forEach { (i, color) in
                let card = UIView()
                card.backgroundColor = color
                card.layer.cornerRadius = 10
                card.hmFlex.w(80).h(80)
                let label = UILabel()
                label.text = "\(i + 1)"
                label.textColor = .white
                label.font = .boldSystemFont(ofSize: 26)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                card.addSubview(label)
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                ])
                stack.addArrangedSubview(card)
            }
            return stack
        }

        // ── LTR 行（默认） ────────────────────────────────────
        let ltrStack = makeCardStack()
        self.ltrStack = ltrStack
        ltrScrollView.semanticContentAttribute = .unspecified   // 默认 LTR
        ltrScrollView.showsHorizontalScrollIndicator = true
        ltrScrollView.translatesAutoresizingMaskIntoConstraints = false
        ltrStack.translatesAutoresizingMaskIntoConstraints = false
        ltrScrollView.addSubview(ltrStack)
        NSLayoutConstraint.activate([
            ltrStack.topAnchor.constraint(equalTo: ltrScrollView.topAnchor),
            ltrStack.leadingAnchor.constraint(equalTo: ltrScrollView.leadingAnchor),
            ltrStack.bottomAnchor.constraint(equalTo: ltrScrollView.bottomAnchor),
            ltrStack.trailingAnchor.constraint(equalTo: ltrScrollView.trailingAnchor),
            ltrStack.heightAnchor.constraint(equalTo: ltrScrollView.heightAnchor),
        ])

        // ── RTL 行（forceRightToLeft） ────────────────────────
        let rtlStack = makeCardStack()
        rtlScrollView.semanticContentAttribute = .forceRightToLeft  // 强制 RTL
        rtlScrollView.showsHorizontalScrollIndicator = true
        rtlScrollView.translatesAutoresizingMaskIntoConstraints = false
        rtlStack.translatesAutoresizingMaskIntoConstraints = false
        rtlScrollView.addSubview(rtlStack)
        NSLayoutConstraint.activate([
            rtlStack.topAnchor.constraint(equalTo: rtlScrollView.topAnchor),
            rtlStack.leadingAnchor.constraint(equalTo: rtlScrollView.leadingAnchor),
            rtlStack.bottomAnchor.constraint(equalTo: rtlScrollView.bottomAnchor),
            rtlStack.trailingAnchor.constraint(equalTo: rtlScrollView.trailingAnchor),
            rtlStack.heightAnchor.constraint(equalTo: rtlScrollView.heightAnchor),
        ])

        // ── 切换按钮 ──────────────────────────────────────────
        toggleBtn.setTitle("切换上行 LTR ↔ RTL", for: .normal)
        toggleBtn.titleLabel?.font = .boldSystemFont(ofSize: 15)
        toggleBtn.backgroundColor = .hmBlue
        toggleBtn.setTitleColor(.white, for: .normal)
        toggleBtn.layer.cornerRadius = 10
        toggleBtn.hmFlex.h(46)
        toggleBtn.addTarget(self, action: #selector(toggleDirection), for: .touchUpInside)

        let sl = UILabel()
        sl.text = "上行当前：LTR（卡片 1 在左侧，向右滑动）"
        sl.textAlignment = .center
        sl.font = .systemFont(ofSize: 12)
        sl.textColor = .secondaryLabel
        sl.numberOfLines = 2
        statusLabel = sl

        // ── 说明文本 ──────────────────────────────────────────
        let desc = UILabel()
        desc.numberOfLines = 0
        desc.font = .systemFont(ofSize: 13)
        desc.textColor = .secondaryLabel
        desc.text = "原理：HaomissyouScrollView 在 layoutSubviews 中检测 effectiveUserInterfaceLayoutDirection，RTL 时对自身和每个子视图都应用 CGAffineTransform(scaleX: -1, y: 1)。子视图被二次镜像，所以数字仍正向显示，但整体滚动方向翻转。"

        // ── 布局 ──────────────────────────────────────────────
        let root = HaomissyouStackView.vertical().space(16).inset(24, 16, 24, 16)
        root.addArrangedSubview(desc)
        root.addArrangedSubview(section(title: "LTR（默认）：卡片 1 在左侧 → 向右滑动"))
        root.addArrangedSubview(ltrScrollView)
        ltrScrollView.hmFlex.h(100)
        root.addArrangedSubview(section(title: "RTL（forceRightToLeft）：卡片 1 在右侧 → 向左滑动"))
        root.addArrangedSubview(rtlScrollView)
        rtlScrollView.hmFlex.h(100)
        root.addArrangedSubview(toggleBtn)
        root.addArrangedSubview(sl)

        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func toggleDirection() {
        isRTL.toggle()
        ltrScrollView.semanticContentAttribute = isRTL ? .forceRightToLeft : .unspecified
        self.ltrStack?.semanticContentAttribute = isRTL ? .forceRightToLeft : .unspecified
        // 强制立刻重新计算 effectiveUserInterfaceLayoutDirection 并镜像
        ltrScrollView.setNeedsLayout()
        ltrScrollView.layoutIfNeeded()
        statusLabel?.text = isRTL
            ? "上行当前：RTL（卡片 1 在右侧，向左滑动）"
            : "上行当前：LTR（卡片 1 在左侧，向右滑动）"
        toggleBtn.backgroundColor = isRTL ? .hmOrange : .hmBlue
    }
}

