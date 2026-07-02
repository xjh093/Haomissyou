//
//  HaomissyouSingleSectionController.swift
//  HaomissyouListKit
//
//  Created by Haomissyou on 2026-07-02
//  Copyright © 2026年 HaoCold. All rights reserved.
//
//  MIT License
//

import UIKit

/// 固定只有一个 cell 的 SectionController（numberOfItems() 恒为 1）。
/// 子类只需重写 cellForItem(at:) 和 sizeForItem(at:) 即可。
open class HaomissyouSingleSectionController: HaomissyouFlowSectionController {

    public override final func numberOfItems() -> Int { 1 }
}
