//
//  MovieGridCell.swift
//  Flick
//
//  Created by Jayven Nhan on 2/18/17.
//  Copyright © 2017 Jayven Nhan. All rights reserved.
//

import UIKit
import AFNetworking

class MovieGridCell: UICollectionViewCell {
    
    let imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
//    override func prepareForReuse() {
//        self.imgView.image = nil
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imgView)
        
        imgView.contentMode = .scaleAspectFill
        imgView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imgView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
