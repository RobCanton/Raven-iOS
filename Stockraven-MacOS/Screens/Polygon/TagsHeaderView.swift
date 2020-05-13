//
//  TagsHeaderView.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-05-01.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit

class TagsHeaderView:UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var tags = [String]()
    var collectionView:UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.systemBackground
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        layout.estimatedItemSize = CGSize(width: 72, height: 28)
        layout.minimumLineSpacing = 12.0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        addSubview(collectionView)
        collectionView.constraintToSuperview(0, 16, 12, 16, ignoreSafeArea: false)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        collectionView.layer.cornerCurve = .continuous
        collectionView.layer.cornerRadius = 4
        collectionView.clipsToBounds = true
        
        setTags(["mainholdings", "longterm", "shortterm", "calls", "covid"])
        
        let separator = UIView()
        addSubview(separator)
        separator.backgroundColor = UIColor.separator
        separator.constraintToSuperview(nil, 0, 0, 0, ignoreSafeArea: false)
        separator.constraintHeight(to: 0.5)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TagCollectionViewCell
        cell.textLabel.text = tags[indexPath.row]
        return cell
    }
    
    func setTags(_ tags:[String]) {
        self.tags = tags
        self.collectionView.reloadData()
    }
}
