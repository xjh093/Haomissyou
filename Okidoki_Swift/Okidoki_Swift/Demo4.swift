//
//  Demo4.swift
//  Okidoki_Swift
//
//  Created by Haomissyou on 6/25/26.
//

import UIKit

class Demo4: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "AutoLayout"
        view.backgroundColor = .systemBackground
        
        setupViews()
    }
    
    private func setupViews() {
        // 头发
        let view1 = UIView().haomissyou
            .addToSuperview(view)
            .bgColor(UIColor.systemRed)
            .cnRadius(10)
            .batch({ hm in
                hm.topAnchor([self.view.safeAreaLayoutGuide.topAnchor, 20])
                    .leadingAnchor([self.view.leadingAnchor, 30])
                    .trailingAnchor([self.view.trailingAnchor, -30])
                    .heightAnchor(50)
            })
            .getView()
        
        // 左眼
        let view2 = UIView().haomissyou
            .addToSuperview(view)
            .bgColor(UIColor.systemGreen)
            .cnRadius(15)
            .batch({ hm in
                hm.topAnchor([view1.bottomAnchor, 20])
                    .leadingAnchor(view1)
                    .trailingAnchor([view1.centerXAnchor, -5])
                    .heightAnchor(40)
            })
            .addSubviewWithConfig(UIView(), { hm, superView in
                hm.centerXAnchor(superView)
                    .centerYAnchor(superView)
                    .widthAnchor(30)
                    .heightAnchor(30)
                    .cnRadius(15)
                    .bgColor(UIColor.black)
                    .addSubviewWithConfig(UIView(), { hm, superView in
                        hm.centerXAnchor([superView, 8])
                            .centerYAnchor([superView, -8])
                            .widthAnchor(6)
                            .heightAnchor(6)
                            .cnRadius(3)
                            .bgColor(UIColor.white)
                    })
            })
            .getView()
        
        // 右眼
        let view3 = UIView().haomissyou
            .addToSuperview(view)
            .bgColor(UIColor.systemBlue)
            .cnRadius(15)
            .batch({ hm in
                hm.topAnchor(view2)
                    .leadingAnchor([view2.trailingAnchor, 20])
                    .trailingAnchor(view1)
                    .heightAnchor(view2)
            })
            .addSubviewWithConfig(UIView(), { hm, superView in
                hm.centerXAnchor(superView)
                    .centerYAnchor(superView)
                    .widthAnchor(30)
                    .heightAnchor(30)
                    .cnRadius(15)
                    .bgColor(UIColor.black)
                    .addSubviewWithConfig(UIView(), { hm, superView in
                        hm.centerXAnchor([superView, 8])
                            .centerYAnchor([superView, -8])
                            .widthAnchor(6)
                            .heightAnchor(6)
                            .cnRadius(3)
                            .bgColor(UIColor.white)
                    })
            })
            .getView()
        
        // 鼻子
        let view4 = UIView().haomissyou
            .addToSuperview(view)
            .bgColor(UIColor.systemOrange)
            .cnRadius(10)
            .batch({ hm in
                hm.topAnchor([view2.bottomAnchor, 20])
                    .leadingAnchor([view2.trailingAnchor, -20])
                    .trailingAnchor([view3.leadingAnchor, 20])
                    .heightAnchor(view1)
            })
            .getView()
        
        // 嘴巴
        let view5 = UIView().haomissyou
            .addToSuperview(view)
            .bgColor(UIColor.gray)
            .cnRadius(10)
            .batch({ hm in
                hm.topAnchor([view4.bottomAnchor, 20])
                    .leadingAnchor([view2.centerXAnchor, -20])
                    .trailingAnchor([view3.centerXAnchor, 20])
                    .heightAnchor(view2)
            })
            .getView()
    }
}
