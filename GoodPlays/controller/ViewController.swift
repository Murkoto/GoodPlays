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
    
    private var components: URLComponents?
    private var games = [Game]()
    private var isLoading = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.searchController = searchController
        
        components = URLComponents(string: "https://api.rawg.io/api/games?page_size=5")
        gameTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier:"GameCell")
        gameTableView.estimatedRowHeight = 360
        loadData()
    }

    private func loadData() {
        isLoading = true
        guard let component = self.components else {return}
        URLSession.shared.dataTask(with: component.url!) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            if response.statusCode == 200 {
                if let games = self.decodeJson(data: data) {
                    let nextUrl = games.next ?? ""
                    self.components = URLComponents(string: nextUrl)
                    for game in games.games {
                        self.games.append(game)
                    }
                    DispatchQueue.main.async {
                        self.gameTableView.reloadData()
                    }
                }
            } else {
                
            }
        }.resume()
    }
    
    private func decodeJson(data: Data) -> Games? {
        let decoder = JSONDecoder()
        
        do {
            let games = try decoder.decode(Games.self, from: data)
            return games
        } catch let error {
            let str = String(decoding: data, as: UTF8.self)
            print(str)
            print("API Error " + error.localizedDescription)
            return nil
        }
    }
}

extension ViewController: UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = gameTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameTableViewCell else {return UITableViewCell()}
            
        let game = self.games[indexPath.row]
        cell.game = game
        cell.setData()
        
        if(indexPath.row == games.count - 1) {
            isLoading = false
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let current = indexPath.row
        let lastElement = self.games.count - 1
        if (current == lastElement && !isLoading) {
            loadData()
        }
    }
    
}

