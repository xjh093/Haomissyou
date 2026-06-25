//
//  Demo1.swift
//  Okidoki_Swift
//
//  Created by Haomissyou on 6/25/26.
//

import UIKit

class Demo1: UIViewController {

    private var view3: UIView?
    private var label1: HaomissyouLabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = "Base Example"
                
        setupViews()

        setupLabels()

        setupButtons()
    }
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView().haomissyou
            .addToSuperview(view)
            .batch({ hm in
                hm.edgeToSuperView()
            })
            .bgColor(UIColor.systemGray6)
            .verInd(true)
            .alwaysBounceVertical(true)
            .didScroll({ sv in
                print("didScroll", sv.contentOffset.x, sv.contentOffset.y)
            })
            .willBeginDragging({ sv in
                print("willBeginDragging")
            })
            .willBeginDecelerating({ sv in
                print("willBeginDecelerating")
            })
            .willEndDragging({ sv, point in
                print("willEndDragging", point)
            })
            .didEndDecelerating({ sv in
                print("didEndDecelerating")
            })
            .didEndDragging({ sv, end in
                print("didEndDragging")
            })
            .getView()
        return sv as! UIScrollView
    }()

    private func setupViews() {
        
        HaomissyouLabel().haomissyou
            .addToSuperview(scrollView)
            .textInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            .batch { hm in
                hm.topAnchor([scrollView])
                    .leadingAnchor([scrollView])
                    .widthAnchor([scrollView])
                    .heightAnchor(80)
            }
            .bgColor(UIColor.systemOrange)
            .lines(0)
            .text("Example for UIScrollView / UIView / Gesture / UILabel / UIButton / HaomissyouLabel")
        
        let view1 = UIView().haomissyou
            .tag("123")
            .frame("{{20,90},{100,100}}")
            .addSubviewWithConfig(UILabel(), { hm in
                hm.text("Border")
                    .align(1)
                    .edgeToSuperView()
            })
            .alpha(0.8)
            .bgColor(UIColor.systemOrange)
            .bdColor(UIColor.black)
            .bdWidth(2)
            .cnRadius(6)
            .mtBounds(true)
            .getView();
        scrollView.addSubview(view1)
        
        UIView().haomissyou
            .addToSuperview(scrollView)
            //.frame("{{140, 90}, {200, 100}}")
            .batch({ hm in
                hm.widthAnchor(200)
                  .heightAnchor(100)
                  .topAnchor([view1.topAnchor])
                  .leadingAnchor([view1.trailingAnchor, 20])
            })
            .addSubviewWithConfig(UILabel(), { hm in
                hm.text("Shadow")
                    .align(1)
                    .edgeToSuperView()
            })
            .bgColor("#FFFFFF")
            .cnRadius(8)
            .shadowColor("#333333")
            .shadowOpacity(0.15)
            .shadowOffset("{0, 4}")
            .shadowRadius(12);
        
        let shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 150, height: 100), cornerRadius:10)

        let view3 = UIView().haomissyou
        .addToSuperview(scrollView)
        //.frame("{{20, 210}, {150, 100}}")
        .batch({ hm in
            hm.widthAnchor(150)
              .heightAnchor(100)
              .topAnchor([view1.bottomAnchor, 20])
              .leadingAnchor([view1])
        })
        .bgColor("#4ECDC4")
        .cnRadius(10)
        .addSubviewWithConfig(UILabel(), { hm in
            hm.text("ShadowPath")
                .align(1)
                .edgeToSuperView()
        })
        //.mtBounds(1)
        .shadowColor("#000000")
        .shadowOpacity(0.25)
        .shadowOffset("{0, 3}")
        .shadowRadius(6)
        .shadowPath(shadowPath)
        .getView();
        self.view3 = view3
        
                
        UIView().haomissyou
        .addToSuperview(scrollView)
        .addSubviewWithConfig(UILabel(), { hm in
            hm.text("Gesture")
                .align(1)
                .edgeToSuperView()
        })
        //.frame("{{190, 210}, {150, 100}}")
        .batch({ hm in
            hm.widthAnchor(150)
              .heightAnchor(100)
              .topAnchor([view3])
              .leadingAnchor([view3.trailingAnchor, 20])
        })
        .bgColor("#4ECD00")
        .cnRadius(10)
        .shadowColor("#000000")
        .shadowOpacity(0.25)
        .shadowOffset("{0, 3}")
        .shadowRadius(6)
        .shadowPath(shadowPath)
        .tapGesture { tap in
            print("点击了视图")
            tap.view?.haomissyou.removeGesture(tap)
            print("移除点击事件")
        }
        .longPressGesture { longPress in
            if longPress.state == .began {
                print("长按开始")
            } else if longPress.state == .ended {
                print("长按结束")
            }
        }
        .swipeGesture(.right) { swipe in
            print("向右滑动")
        }
        .panGesture { pan in
            print("拖动视图")
            
            let translation = pan.translation(in: pan.view?.superview)
            pan.view?.center = CGPoint(x: (pan.view?.center.x)! + translation.x,
                                       y: (pan.view?.center.y)! + translation.y)
            
            pan.setTranslation(CGPointZero, in: pan.view?.superview)
        }
        .pinchGesture { pinch in
            print("缩放视图")
            
            pinch.view?.transform = CGAffineTransformScale(pinch.view!.transform,
                                                           pinch.scale, pinch.scale)
            pinch.scale = 1.0
        }
        .rotationGesture { rotation in
            print("旋转视图")
            
            rotation.view?.transform = CGAffineTransformRotate(rotation.view!.transform, rotation.rotation)
            rotation.rotation = 0
        };
    }
    
    private func setupLabels() {
        self.label1 = HaomissyouLabel().haomissyou
            .addToSuperview(scrollView)
            //.frame("{{20, 340}, {360, 85}}")
            .batch({ hm in
                hm.leadingAnchor([scrollView.leadingAnchor, 20])
                    .topAnchor([self.view3!.bottomAnchor, 20])
                    .widthAnchor(360)
                    //.heightAnchor(85)
            })
            .textInsets(UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0))
            .cnRadius(8)
            //.mtBounds(1)
            .shadowColor("#111111")
            .shadowOpacity(0.55)
            .shadowOffset("{0, 4}")
            .shadowRadius(12)
            .shadowPath(UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 360, height: 65),
                                         cornerRadius: 8))
            .text("明天是个好日子！\n明天的事明天再说~点击改变颜色")
            .font("18")
            .color(UIColor.systemOrange)
            .bgColor(UIColor.systemGray6)
            .align(1)
            .lines(0)
            .lineSpace(5)
            //.autoWidth(0)
            .autoHeight(0)
            .attributedSubstring("明天", UIColor.systemGreen)
            .attributedSubstring("明天", UIFont.haomissyouFont("b22"))
            .attributedSubstringInRange("好日子", UIColor.systemRed,
                                        NSValue(range: NSRange(location: 4, length: 3)))
            .attributedSubstringKeyValue("明天再说", NSAttributedString.Key.underlineStyle,
                                         NSUnderlineStyle.single.rawValue)
            .highlightedTextColor(UIColor.black)
            .tapGesture { tap in
                let label = tap.view as! UILabel
                label.isHighlighted = !label.isHighlighted
            }
            .getView();
    }
    
    private func setupButtons() {
        let btn1 = UIButton.init(type: .custom).haomissyou
            .addToSuperview(scrollView)
            //.frame("{{20, 350}, {360, 40}}")
            .batch({ hm in
                hm.leadingAnchor([scrollView.leadingAnchor, 20])
                    .topAnchor([self.label1!.bottomAnchor, 20])
                    .widthAnchor(360)
                    .heightAnchor(40)
            })
            .bgColor(UIColor.systemGray6)
            .cnRadius(20)
            //.mtBounds(1)
            .mkCorners([1,3])
            .shadowColor("#111111")
            .shadowOpacity(0.55)
            .shadowOffset("{0, 4}")
            .shadowRadius(12)
        
            .title("介是一个按钮~点击改变颜色")
            .color(UIColor.black)
            .font(20)
            .attributedSubstringForState("介是", UIColor.systemGreen, UIControl.State.normal)
            .attributedSubstringForState("介是", UIColor.systemRed, UIControl.State.selected)
            .attributedSubstringForState("介是", UIFont.boldSystemFont(ofSize: 24), UIControl.State.selected)
        
            .titleForState("按钮被点击了", UIControl.State.selected)
            .addControlEvent(.touchUpInside) { sender in
                print("按钮被点击了")
                sender.isSelected = !sender.isSelected
            }
            .getView();
        
        let label1 = HaomissyouLabel().haomissyou
            .addToSuperview(scrollView)
            .bgColor(UIColor.lightGray)
            .text("UILabel：textInsets")
            .textInsets(UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 20))
            .batch { hm in
                hm.leadingAnchor([btn1])
                    .topAnchor([btn1.bottomAnchor, 20])
            }
            .getView();
        
        let label2 = HaomissyouLabel().haomissyou
            .addToSuperview(scrollView)
            .bgColor(UIColor.systemGray3)
            .text("今天是个好日子！")
            .textInsets(UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15))
            .batch({ hm in
                hm.leadingAnchor([label1.trailingAnchor, 20])
                    .topAnchor([label1])
                    .trailingAnchor([btn1])
            })
            .getView();
    }
}
