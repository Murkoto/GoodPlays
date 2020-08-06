//
//  GamesAPI.swift
//  GoodPlays
//
//  Created by Cesa Anwar on 06/08/20.
//  Copyright © 2020 Cesa Anwar. All rights reserved.
//

import Foundation

struct GamesAPI {
    
    static let shared = GamesAPI()
    
    public func getGames(params: [URLQueryItem], onResult: @escaping ([Game]) -> Void, onError: @escaping (Error) -> Void) {
        var component = URLComponents(string: "https://api.rawg.io/api/games")!
        component.queryItems = params
        URLSession.shared.dataTask(with: (component.url)!) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            if response.statusCode == 200 {
                if let games = self.decodeGameListJson(data: data) {
                    DispatchQueue.main.async {
                        onResult(games.games)
                    }
                }
            } else {
                if let error = error {
                    onError(error)
                }
            }
        }.resume()
    }
    
    public func getGameDetails(id: Int, onResult: @escaping (Game) -> Void, onError: @escaping (Error) -> Void) {
        let component = URLComponents(string: "https://api.rawg.io/api/games/" + String(id))!
        URLSession.shared.dataTask(with: (component.url)!) { data, response, error in
            guard let response = response as? HTTPURLResponse, let data = data else {return}
            if response.statusCode == 200 {
                if let game = self.decodeGameDetailsJson(data: data) {
                    DispatchQueue.main.async {
                        onResult(game)
                    }
                }
            } else {
                if let error = error {
                    onError(error)
                }
            }
        }.resume()
    }
    
    private func decodeGameDetailsJson(data: Data) -> Game? {
        let decoder = JSONDecoder()
        
        do {
            let game = try decoder.decode(Game.self, from: data)
            return game
        } catch let error {
            print("Decode Detail Error " + error.localizedDescription)
            return nil
        }
    }
    
    private func decodeGameListJson(data: Data) -> Games? {
        let decoder = JSONDecoder()
        
        do {
            let games = try decoder.decode(Games.self, from: data)
            return games
        } catch let error {
            print("Decode List Error " + error.localizedDescription)
            return nil
        }
    }
    
}
