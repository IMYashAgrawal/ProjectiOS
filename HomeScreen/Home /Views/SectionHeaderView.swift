//
//  SectionHeaderView.swift
//  HomeScreen
//
//  Created by Himadri  on 30/01/26.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(withTitle title: String) {
        headerLabel.text = title
    }
    
}
