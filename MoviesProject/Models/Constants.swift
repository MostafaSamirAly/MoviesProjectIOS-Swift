//
//  Constants.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 5/5/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import Foundation

enum CoreDataEntities : String{
    
    case mostPopular = "MostPopular"
    case topRated = "TopRatedMovies"
    case inTheatres = "InTheatres"
    case favourites = "FavouriteMovies"
}


enum ApiURL : String{
    
    case mostPopular = "https://api.themoviedb.org/3/movie/popular?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US&page=1"
    
    case topRated = "https://api.themoviedb.org/3/movie/top_rated?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US&page=1"
    
    case inTheatres = "https://api.themoviedb.org/3/movie/now_playing?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US&page=1"
    
   case search = "https://api.themoviedb.org/3/search/movie?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US&query="
}

enum PagingURL : String{
    
    case mostPopular = "https://api.themoviedb.org/3/movie/popular?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US&page="
    
    case topRated = "https://api.themoviedb.org/3/movie/top_rated?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US&page="
    
    case inTheatres = "https://api.themoviedb.org/3/movie/now_playing?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US&page="
}
