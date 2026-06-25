//
//  DemoDefault.swift
//  Okidoki_Swift
//
//  Created by Haomissyou on 6/25/26.
//

import UIKit

class DemoDefault: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Default Page"
        view.backgroundColor = .systemBackground
        
        setupViews()
    }
    
    private func setupViews() {
        UILabel().haomissyou
            .addToSuperview(view)
            .edgeToSuperView()
            .text("Default Page")
            .align(1)
            .font(32)
            .bgColor(UIColor.systemGray6)
    }
    
}
