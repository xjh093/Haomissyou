//
//  Demo2.swift
//  Okidoki_Swift
//
//  Created by Haomissyou on 6/25/26.
//

import UIKit

class Demo2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "UICollectionView"
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout()).haomissyou
            .addToSuperview(view)
            .alwaysBounceVertical(true)
            .bgColor(UIColor.systemGray4)
            .cvRegisterCellClass([Demo2Cell.self, "cellID"])
            .cvNumberOfSections { cv in
                return 2
            }
            .cvNumberOfItemsInSection { cv, section in
                return 5
            }
            .cvCellForItemAtIndexPath { cv, indexPath in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! Demo2Cell
                cell.backgroundColor = UIColor.systemOrange
                cell.text = "\(indexPath.section) - \(indexPath.row)"
                cell.layer.cornerRadius = 10
                return cell
            }
            .cvSizeForItemAtIndexPath { cv, flowLayout, indexPath in
                return CGSize(width: self.view.bounds.width * 0.45,
                              height: self.view.bounds.width * 0.25)
            }
            .cvInsetForSectionAtIndex { cv, flowLayout, section in
                return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            }
    }

}

class Demo2Cell: UICollectionViewCell {
    
    private var label: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.label = UILabel().haomissyou
            .addToSuperview(self.contentView)
            .edgeToSuperView()
            .align(1)
            .font(20)
            .getView()
    }
    
    var text: String {
        set {
            self.label?.text = newValue
        }
        get {
            self.label?.text ?? "default"
        }
    }
}
