//
//  GameDetailViewController.swift
//  GoodPlays
//
//  Created by Cesa Anwar on 05/08/20.
//  Copyright © 2020 Cesa Anwar. All rights reserved.
//

import UIKit

class GameDetailViewController: UIViewController {
    
    var game: Game?
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var released: UILabel!
    @IBOutlet weak var platforms: UILabel!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    private let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupActivityIndicator()
        indicator.startAnimating()
        if let game = game {
            loadData(id: game.id)
        }
    }

    private func loadData(id: Int) {
        GamesAPI.shared.getGameDetails(id: id, onResult: {game in
            self.indicator.stopAnimating()
            
            if let background = game.backgroundImage {
                self.downloadImage(urlString: background)
            }
            self.name.text = game.name
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            if let date = game.released {
                self.released.text = formatter.string(from: date)
            }
            if let platforms = game.parentPlatform {
                self.platforms.text = self.platformItemToString(platforms: platforms)
            }
            if let gameDescription = game.description {
                let descriptionData = Data(gameDescription.utf8)
                if let attributedDescription = try? NSAttributedString(data: descriptionData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    self.gameDescription.attributedText = attributedDescription
                }
            }
            if let rating = game.rating {
                self.rating.text = String(rating)
            }
        }, onError: { error in
            
        })
    }
    
    private func platformItemToString(platforms: [ParentPlatform]) -> String {
        var platformStrings = [String]()
        platforms.forEach({ platform in
            platformStrings.append(platform.platform.name)
        })
        return platformStrings.joined(separator: ", ")
    }
    
    private func downloadImage(urlString: String) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in

            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.background.image = image
            })

        }).resume()
    }

    func setupActivityIndicator() {
        indicator.style = .medium
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = .white
        indicator.frame = self.view.frame
        self.view.addSubview(indicator)
    }

}
