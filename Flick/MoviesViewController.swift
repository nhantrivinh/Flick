//
//  MoviesViewController.swift
//  Flick
//
//  Created by Jayven Nhan on 2/17/17.
//  Copyright © 2017 Jayven Nhan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import PopupDialog

class MoviesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sc: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let refreshControl = UIRefreshControl()
    var collectionView: UICollectionView!
    let moveGridCellID = "MovieGridCell"
    let apiKey = "de37a3615ccd2e5fadbd0bbb3610daeb"
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(MoviesViewController.networkRequest), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)

        sc.addTarget(self, action: #selector(MoviesViewController.segmentControlValueChange(_:)), for: .valueChanged)
        
        networkRequest()
    }
    
    func setupCollectionView() {
        self.automaticallyAdjustsScrollViewInsets = false
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: self.tableView.frame, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieGridCell.self, forCellWithReuseIdentifier: moveGridCellID)
        collectionView.backgroundColor = UIColor.white
        
        view.insertSubview(collectionView, at: 0)
        collectionView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.isHidden = true
    }
    
    
    func networkRequest() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (dataOrNil, response, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let data = dataOrNil, let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
//                NSLog("response: \(responseDictionary)")
                guard let resultsDictionary = responseDictionary.value(forKeyPath: "results") as? [NSDictionary] else { return }
                self.movies = resultsDictionary
                self.filteredMovies = self.movies
                self.reloadTableViewAndCollectionViewData()
                self.refreshControl.endRefreshing()
            } else {
                self.presentPopupError()
            }
        }
        task.resume()
    }
    
    func presentPopupError() {
        let title = "NETWORK ERROR"
        let message = "No internet connection"
        let popup = PopupDialog(title: title, message: message)
        let btnOk = DefaultButton(title: "OK", action: {
            print("OK!")
        })
        popup.addButton(btnOk)
        self.present(popup, animated: true, completion: nil)
    }

    func segmentControlValueChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tableView.isHidden = false
            collectionView.isHidden = true
        } else {
            tableView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    func reloadTableViewAndCollectionViewData() {
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let movie = filteredMovies![indexPath.row]
        
        let detailVC = segue.destination as! DetailsViewController
        detailVC.movie = movie
    }

}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = self.filteredMovies![indexPath.row]
        
        let title = movie["title"] as! String
        cell.lblTitle.text = title
        let overview = movie["overview"] as! String
        cell.lblOverview.text = overview
        
        if let posterPath = movie["poster_path"] as? String {
            self.loadImage(cell.imgView, posterPath: posterPath)
        }
        
//        cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadImage(_ sender: UIImageView, posterPath: String) {
        let baseLowResUrl = "https://image.tmdb.org/t/p/w45" + posterPath
        let baseHighResUrl = "https://image.tmdb.org/t/p/original" + posterPath
        
        let lowResUrl = URL(string: baseLowResUrl)!
        let highResUrl = URL(string: baseHighResUrl)!
        
        let lowResImageRequest = NSURLRequest(url: lowResUrl)
        let highResImageRequest = NSURLRequest(url: highResUrl)
        
        sender.setImageWith(lowResImageRequest as URLRequest, placeholderImage: nil, success: { (lowResImageRequest, response, image) in
            sender.image = image
            sender.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                sender.alpha = 1
            }, completion: { (completed) in
                sender.setImageWith(highResImageRequest as URLRequest, placeholderImage: nil, success: { (highResImageRequest, response, image) in
                    if response != nil {
                        sender.image = image
                    }
                }, failure: nil)
            })
        }, failure: nil)
    }
    
}

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: moveGridCellID, for: indexPath) as? MovieGridCell {
            
            let movie = self.filteredMovies![indexPath.row]
            if let posterPath = movie["poster_path"] as? String {
                self.loadImage(cell.imgView, posterPath: posterPath)
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width/2
        return CGSize(width: width, height: width + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension MoviesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let keywords = searchBar.text
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let movies = movies else { return }

        filteredMovies = searchText.isEmpty ? movies : movies.filter({ movie in
            let title = movie["title"] as! String
            return title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        
        self.reloadTableViewAndCollectionViewData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
