//
//  Movie.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 1/2/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import UIKit

class Movie: NSObject {
    var id = 0
    var title = ""
    var image = ""
    var releaseYear = ""
    var rating : Double = 0.0
    var overView = ""
    var trailers = [String]()
    var reviews = [String]()
    var isFoavourite   = false
    var hasImage  = true

}
