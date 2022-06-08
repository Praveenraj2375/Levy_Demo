//
//  SelfSizingTableview.swift
//  Levy
//
//  Created by Praveenraj T on 21/05/22.
//

import Foundation
import UIKit

class SelfSizingTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = min(.infinity, contentSize.height)
        return CGSize(width: contentSize.width, height: height)
    }
}
