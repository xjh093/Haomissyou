//
//  ViewController.swift
//  Okidoki_Swift
//
//  Created by Haomissyou on 6/23/26.
//

import UIKit
//import Okidoki

class ViewController: UIViewController {
    
    private let dataArray = [
        "基础示例",
        "UICollectionView",
        "UITextField",
        "AutoLayout",
        "Default",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = "Okidoki Swift Version"
        
        setupTableView()

    }
    
    private func setupTableView() {
        UITableView(frame: view.bounds, style: .insetGrouped).haomissyou
            .addToSuperview(view)
            .registerCellClass([UITableViewCell.self, "cellID"])
            .numberOfSections({ tableView in
                return 2
            })
            .numberOfRowsInSection { tableView, section in
                return self.dataArray.count
            }
            .cellForRowAtIndexPath { tableView, indexPath in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
                //cell.textLabel?.text = "第 \(indexPath.section + 1) 组，第 \(indexPath.row + 1) 行"
                cell.textLabel?.text = self.dataArray[indexPath.row]
                return cell
            }
            .didSelectRowAtIndexPath { tableView, indexPath in
                print("didSelectRowAtIndexPath: \(indexPath.row)")
                tableView.deselectRow(at: indexPath, animated: true)
                
                switch indexPath.row {
                case 0:
                    self.navigationController?.pushViewController(Demo1(), animated: true)
                case 1:
                    self.navigationController?.pushViewController(Demo2(), animated: true)
                case 2:
                    self.navigationController?.pushViewController(Demo3(), animated: true)
                case 3:
                    self.navigationController?.pushViewController(Demo4(), animated: true)
                default:
                    self.navigationController?.pushViewController(DemoDefault(), animated: true)
                }
            }
            .heightForRowAtIndexPath { tableView, indexPath in
                return 50
            }
            .heightForHeaderInSection { tableView, section in
                return 60
            }
            .heightForFooterInSection { tableView, section in
                return 40
            }
            .viewForHeaderInSection { tableView, section in
                return UIView().haomissyou
                    .bgColor(UIColor.systemGray2)
                    .cnRadius(20)
                    .mkCorners([1, 2])
                    .addSubviewWithConfig(HaomissyouLabel(), { hm in
                        hm.text("这是第 \(section + 1) 组，组头")
                            .textInsets(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
                            .edgeToSuperView()
                    })
                    .getView()
            }
            .viewForFooterInSection { tableView, section in
                return UIView().haomissyou
                    .cnRadius(20)
                    .mkCorners([3, 4])
                    .bgColor(section == 0 ? UIColor.orange : UIColor.systemOrange)
                    .addSubviewWithConfig(HaomissyouLabel(), { hm in
                        hm.text("这是第 \(section + 1) 组，组尾")
                            .align(2)
                            .textInsets(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
                            .edgeToSuperView()
                    })
                    .getView()
            }
            ;
    }
    
}
