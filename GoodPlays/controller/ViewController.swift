//
//  ViewController.swift
//  GoodPlays
//
//  Created by Cesa Anwar on 02/08/20.
//  Copyright © 2020 Cesa Anwar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var searchContainer: UIView!
    
    private var components: URLComponents?
    private var games = [Game]()
    private var isLoading = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var indicator = UIActivityIndicatorView()
    
    private var refreshControl = UIRefreshControl()
    
    private var pageSize = 10
    private var page = 1
    private var search = ""
    
    let defaultUrl = "https://api.rawg.io/api/games"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.searchController = searchController
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "goodplays"))
        
        components = URLComponents(string: defaultUrl)
        
        setupActivityIndicator()
        self.indicator.startAnimating()
        
        setupGameTableView()
        setupRefresh()
        setupSearchBar()
        loadData()
        
    }
    
    private func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func setupRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        gameTableView.addSubview(refreshControl)
    }
    
    private func setupGameTableView() {
        gameTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.scrollsToTop = true
        gameTableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier:"GameCell")
        gameTableView.estimatedRowHeight = 360
    }
    
    private func refresh() {
        self.games.removeAll()
        self.page = 1
        loadData()
    }
    
    @objc func refresh(_ sender: Any?) {
        self.games.removeAll()
        self.page = 1
        loadData()
    }
    
    func setupActivityIndicator() {
        indicator.style = .medium
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = .white
        indicator.frame = view.frame
        self.view.addSubview(indicator)
    }

    @IBAction func onProfileButtonClicked(_ sender: Any) {
        let profile = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    private func loadData() {
        isLoading = true
        let queryItems = [
            URLQueryItem(name: "page_size", value: String(pageSize)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "search", value: search)
        ]
        GamesAPI.shared.getGames(params: queryItems,
            onResult: { games in
                self.isLoading = false
                self.page += 1
                for game in games {
                    self.games.append(game)
                }
                self.indicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.gameTableView.reloadData()
        }, onError: { error in
            print(error.localizedDescription)
        })
    }
}

extension ViewController: UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = gameTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameTableViewCell else {return UITableViewCell()}
            
        let game = self.games[indexPath.row]
        cell.game = game
        cell.setData()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let current = indexPath.row
        let lastElement = self.games.count - 1
        if (current == lastElement && !isLoading) {
            loadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameTableView.deselectRow(at: indexPath, animated: true)
        let detail = GameDetailViewController(nibName: "GameDetailViewController", bundle: nil)
        let game = games[indexPath.row]
        detail.game = game
        
        self.navigationController?.pushViewController(detail, animated: true)
    }
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        indicator.startAnimating()
        self.gameTableView.setContentOffset(.zero, animated: false)
        self.search = searchText
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.refresh(_:)), object: nil)
        self.perform(#selector(self.refresh(_:)), with: nil, afterDelay: 0.5)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.indicator.startAnimating()
        self.gameTableView.setContentOffset(.zero, animated: false)
        self.search = ""
        self.refresh()
    }
    
}

