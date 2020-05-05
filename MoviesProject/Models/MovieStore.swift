//
//  MovieStore.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 5/5/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import Foundation

class MovieStore {
    var movies = [Movie]()
    var favourites : [Movie]
    let coreData = CoreDataHelper.coreDatahelperSingleTone
    
    init() {
        favourites = coreData.getMoviesFromCoreData(entityName: CoreDataEntities.favourites.rawValue)
    }
    
    func fillMovies(response : [Dictionary<String,Any>] , entityName : String, appendValues:Bool) -> Void {
        if response.count != 0{
            if !appendValues{
                movies.removeAll()
            }
            
            for i in 0...response.count-1
            {
                var dict = response[i]
                let movie = Movie()
                movie.id = dict["id"] as! Int
                movie.title = dict["title"] as? String ?? "N/A"
                movie.rating = dict["vote_average"] as? Double ?? 0.0
                movie.overView = dict["overview"] as? String ?? "N/A"
                if let image = dict["poster_path"] as? String{
                    movie.image = "http://image.tmdb.org/t/p/w342" + image
                }else{
                    movie.image = "placeholder.jpg"
                    movie.hasImage = false
                }
                let date = String(dict["release_date"] as? String ?? "N/A")
                let year = date.components(separatedBy: "-")
                movie.releaseYear = year[0]
                if favourites.count != 0{
                    for i in 0...favourites.count-1{
                        if movie.id == favourites[i].id{
                            movie.isFoavourite = true
                        }
                    }
                    
                }
                self.movies.append(movie)
            }
        }
        
    }
    
    func saveMoviesToCoreData(entityName: CoreDataEntities){
        for i in 0...19{
          coreData.insertMovieToCoreData(entityName: entityName.rawValue, movieToInsert: movies[i])
        }
    }
    
    func getMoviesFromCoreData(entityName: CoreDataEntities){
        movies = coreData.getMoviesFromCoreData(entityName: entityName.rawValue)
    }
    
    func getMovie(atIndex: Int) -> Movie{
        return movies[atIndex]
    }
    
    func getMoviesCount() -> Int{
        return movies.count
    }
    
}
