//
//  Demo3.swift
//  Okidoki_Swift
//
//  Created by Haomissyou on 6/25/26.
//

import UIKit

class Demo3: UIViewController {

    private var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "UITextField"
        view.backgroundColor = .systemBackground
        
        setupTextField()
    }
    
    private func setupTextField() {
        UITextField().haomissyou
            .addToSuperview(view)
            .bgColor(UIColor.systemGray6)
            .batch { hm in
                hm.topAnchor([self.view.safeAreaLayoutGuide.topAnchor, 10])
                    .leadingAnchor([self.view.leadingAnchor, 20])
                    .trailingAnchor([self.view.trailingAnchor, -20])
                    .heightAnchor(40)
            }
            .pHolder("> 在这里输入：字母和数字，长度10")
            .pHFont(20)
            .pHColor(UIColor.systemRed.withAlphaComponent(0.8))
            .bdStyle(3)
            .lfView(UIView().haomissyou
                .bgColor(UIColor.systemOrange)
                .batch({ hm in
                    hm.widthAnchor(30)
                        .heightAnchor(30)
                })
                .getView()
            )
            .lvMode(3)
            .rtView(UIView().haomissyou
                .bgColor(UIColor.systemCyan)
                .batch({ hm in
                    hm.widthAnchor(30)
                        .heightAnchor(20)
                })
                .getView()
            )
            .rvMode(3)
            .tfShouldBeginEditing({ tf in
                print("tfShouldBeginEditing")
                return true
            })
            .tfDidBeginEditing { tf in
                print("tfDidBeginEditing")
            }
            .tfShouldEndEditing({ tf in
                print("tfShouldEndEditing")
                return true
            })
            .tfDidEndEditing { tf in
                print("tfDidEndEditing")
            }
            .tfShouldChangeCharacters({ tf, range, text in
                print("tfShouldChangeCharacters: \(range), \(text)")
                return true
            })
            .tfShouldClear({ tf in
                print("tfShouldClear")
                return true
            })
            .tfShouldReturn { tf in
                print("tfShouldReturn")
                return true
            }
            .tfInputLimit([.alphabet, .digital], 10) { original, matched in
                print("输入：\(original) → 过滤后：\(matched)")
            }
            .keyboardHandler { [weak self] name, _, endFrame, duration, curve in
                guard let self else { return }
                print("keyboardHandler name: \(name)")
                
                let isShow = (name == UIResponder.keyboardDidShowNotification)
                let offset = isShow ? -endFrame.height : 0
                UIView.animate(withDuration: duration) {
                    print("offset: \(offset)")
                     
                    self.label?.isHidden = !isShow
                }
             }
        
        
        self.label = UILabel().haomissyou
            .addToSuperview(view)
            .hidden(1)
            .text("键盘出现~")
            .batch({ hm in
                hm.topAnchor([self.view.safeAreaLayoutGuide.topAnchor, 60])
                    .leadingAnchor([self.view.leadingAnchor, 20])
                    .trailingAnchor([self.view.trailingAnchor, -20])
                    .heightAnchor(40)
            })
            .getView()
    }

}
