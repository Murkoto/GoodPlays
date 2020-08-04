//
//  GameTableViewCell.swift
//  GoodPlays
//
//  Created by Cesa Anwar on 03/08/20.
//  Copyright © 2020 Cesa Anwar. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var metacritic: UILabel!
    @IBOutlet weak var year: UILabel!
    
    var game: Game?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.cornerRadius = 8.0
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cardView.layer.shadowRadius = 8.0
        cardView.layer.shadowOpacity = 0.7
        
        thumbnail.layer.cornerRadius = 8.0
        
        name.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        year.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setData() {
        if let game = game {
            name.text = game.name ?? ""
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            if let date = game.released {
                year.text = formatter.string(from: date)
            }
            if game.image == nil {
                downloadImage(game: game)
            } else {
                self.thumbnail.image = game.image
            }
            if let metacritic = game.metacritic {
                self.metacritic.text = String(metacritic)
            }
        }
    }
    
    private func downloadImage(game: Game) {
        let urlString = game.backgroundImage ?? ""
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in

            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                game.image = image
                if game.id == self.game?.id {
                    self.thumbnail.image = image
                }
            })

        }).resume()
    }
    
    override func prepareForReuse() {
        self.game = nil
        self.thumbnail.image = nil
    }
    
}
