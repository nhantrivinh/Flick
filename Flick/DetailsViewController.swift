//
//  DetailsViewController.swift
//  Flick
//
//  Created by Jayven Nhan on 2/17/17.
//  Copyright © 2017 Jayven Nhan. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let contentWidth = scrollView.frame.size.width
        let contentHeight = scrollView.frame.size.height
        
        let imgView = UIImageView()
        scrollView.addSubview(imgView)
        imgView.contentMode = .scaleAspectFill
        
        imgView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "https://image.tmdb.org/t/p/w500"
            let imgUrl = URL(string: baseUrl + posterPath)!
            imgView.setImageWith(imgUrl)
        }
        
        let infoViewHeight = CGFloat(250)
        let infoView = UIView()
        infoView.backgroundColor = UIColor.black
        scrollView.addSubview(infoView)
        infoView.frame = CGRect(x: 0, y: imgView.frame.maxY, width: contentWidth, height: infoViewHeight)
        
        let tabBarHeight = self.tabBarController!.tabBar.frame.height
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight + infoViewHeight - tabBarHeight)
        
        let lblTitle = UILabel()
        infoView.addSubview(lblTitle)
        lblTitle.frame = CGRect(x: 8, y: 8, width: infoView.frame.width - 16, height: 26)
        lblTitle.text = movie["title"] as? String ?? "No Movie Title"
        lblTitle.textColor = UIColor.white
        lblTitle.font = UIFont.boldSystemFont(ofSize: 24)
        
        let lblDescription = UILabel()
        infoView.addSubview(lblDescription)
        lblDescription.textColor = UIColor.white
        lblDescription.frame = CGRect(x: lblTitle.frame.minX, y: lblTitle.frame.maxY + 8, width: lblTitle.frame.maxX - 8, height: 200)
        lblDescription.numberOfLines = 0
        lblDescription.text = movie["overview"] as? String ?? "No Overview Description"
    }

}
