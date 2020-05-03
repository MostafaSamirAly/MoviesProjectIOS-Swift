//
//  HomePageVC.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 1/8/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import UIKit
import SDWebImage
import DropDown
import RevealingSplashView

class HomePageVC: UIViewController {
    
    let coreData = CoreDataHelper.coreDatahelperSingleTone
    let json = JsonHelper.jsonHelperSingleTone
    var movies = [Movie]()
    var SearchCanceledMovies = [Movie]()
    var favourites = [Movie]()
    let sortMenu = ["Most Popular","Top Rated","In Theaters"]
    let rightBarDropDown = DropDown()
    
    @IBOutlet weak var sortBtnOutlet: UIBarButtonItem!
    
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "film2")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor.white)
        self.view.addSubview(revealingSplashView)
        revealingSplashView.startAnimation(){}
        
        json.checkReachability { [unowned self] (connectivity) in
            if connectivity{
                self.json.getMovies(url: "http://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=1c49378c151f43527b6b7af9330e8875") { (response) in
                    self.fillMovies(response: response, entityName: "MostPopular")
                    self.SearchCanceledMovies = self.movies
                    DispatchQueue.main.async {
                        self.homeCollectionView.reloadData()
                    }
                }
            }else{
                self.movies = self.coreData.getMoviesFromCoreData(entityName: "MostPopular")
                self.showAlert(withMessage: "No Internet Connection")
                DispatchQueue.main.async {
                    self.homeCollectionView.reloadData()
                }
            }
        }
        
        favourites = coreData.getMoviesFromCoreData(entityName: "FavouriteMovies")
        rightBarDropDown.anchorView = sortBtnOutlet
        rightBarDropDown.dataSource = sortMenu
        rightBarDropDown.cellConfiguration = { (index, item) in return "\(item)" }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeCollectionView.reloadData()
    }
    
    func fillMovies(response : [Dictionary<String,Any>] , entityName : String) -> Void {
        if response.count != 0{
            movies.removeAll()
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
            if entityName != ""{
                coreData.DeleteAllMoviesFrom(entityName: entityName)
                for i in 0...self.movies.count-1{
                    self.coreData.insertMovieToCoreData(entityName: entityName, movieToInsert: self.movies[i])
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            homeCollectionView.reloadData()
        }else{
                showAlert(withMessage: "Poor Internet Connection")
            movies = coreData.getMoviesFromCoreData(entityName: entityName)
            homeCollectionView.reloadData()
        }
    }
    
    func showAlert(withMessage:String){
        let noConnectionAlert = UIAlertController(title:"", message: withMessage, preferredStyle: .alert)
        noConnectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(noConnectionAlert, animated: true, completion: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func sortBtnPressed(_ sender: Any) {
        json.checkReachability(completion: { (connection) in
            self.rightBarDropDown.selectionAction = { (index: Int, item: String) in
                if index == 0 {

                    if connection{
                        self.json.getMovies(url: "https://api.themoviedb.org/3/movie/popular?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US") { (response) in
                            self.fillMovies(response: response, entityName: "MostPopular")
                            DispatchQueue.main.async {
                                self.rightBarDropDown.hide()
                                self.homeCollectionView.reloadData()
                            }
                        }
                    }else{
                        self.movies = self.coreData.getMoviesFromCoreData(entityName: "MostPopular")
                        DispatchQueue.main.async {
                            self.rightBarDropDown.hide()
                            self.homeCollectionView.reloadData()
                        }
                    }
                    
                }
                else if index == 1 {
                    if connection{
                        self.json.getMovies(url: "https://api.themoviedb.org/3/movie/top_rated?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US") { (response) in
                            self.fillMovies(response: response, entityName: "TopRatedMovies")
                            DispatchQueue.main.async {
                                self.rightBarDropDown.hide()
                                self.homeCollectionView.reloadData()
                            }
                        }
                    }else{
                        self.movies = self.coreData.getMoviesFromCoreData(entityName: "TopRatedMovies")
                        DispatchQueue.main.async {
                            self.rightBarDropDown.hide()
                            self.homeCollectionView.reloadData()
                        }
                    }
                    
                }else{
                    if connection{
                        self.json.getMovies(url: "https://api.themoviedb.org/3/movie/now_playing?api_key=1c49378c151f43527b6b7af9330e8875&language=en-US") { (response) in
                            self.fillMovies(response: response, entityName: "InTheatres")
                            DispatchQueue.main.async {
                                self.rightBarDropDown.hide()
                                self.homeCollectionView.reloadData()
                            }
                        }
                    }else{
                        self.movies = self.coreData.getMoviesFromCoreData(entityName: "InTheatres")
                        DispatchQueue.main.async {
                            self.rightBarDropDown.hide()
                            self.homeCollectionView.reloadData()
                        }
                    }
                }
            }
        })
        rightBarDropDown.width = 140
        rightBarDropDown.bottomOffset = CGPoint(x: 0, y:(rightBarDropDown.anchorView?.plainView.bounds.height)!)
        rightBarDropDown.show()
    }
    
}


extension HomePageVC : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let info = storyboard?.instantiateViewController(withIdentifier: "Details") as! Details
        info.infoMovie = movies[indexPath.row]
        self.navigationController?.pushViewController(info, animated: true)
    }
}


extension HomePageVC :UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewsCustomCells
        
        if movies[indexPath.row].hasImage{
            cell.movieImage.sd_setImage(with: URL(string: movies[indexPath.row].image ) , completed: nil)
        }
        else{
            cell.movieImage.image = UIImage.init(named: "placeholder.jpg")
        }
        if movies[indexPath.row].isFoavourite{
            cell.addToFavouritesButton.setImage( UIImage.init(named: "fav"), for: .normal)
        }else{
            cell.addToFavouritesButton.setImage( UIImage.init(named: "notfav"), for: .normal)
            
        }
        cell.btnTapAction = { () in
            if self.movies[indexPath.row].isFoavourite{
                self.movies[indexPath.row].isFoavourite = false
                self.coreData.DeleteMovieFromCoreData(withID: self.movies[indexPath.row].id, entityName: "FavouriteMovies")
                cell.addToFavouritesButton.setImage( UIImage.init(named: "notfav"), for: .normal)
            }else{
                self.movies[indexPath.row].isFoavourite = true
                self.coreData.insertMovieToCoreData(entityName: "FavouriteMovies", movieToInsert: self.movies[indexPath.row] )
                cell.addToFavouritesButton.setImage( UIImage.init(named: "fav"), for: .normal)
            }
            
        }
        return cell
    }
    
}
extension HomePageVC :UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = UIScreen.main.bounds.size.height
        let width = UIScreen.main.bounds.size.width
        return CGSize(width: width/2 , height: height/2 )
    }
}
extension HomePageVC :UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        searchBar.showsCancelButton = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.count == 0 {
            movies = SearchCanceledMovies
            homeCollectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count != 0{
            
            let query = searchBar.text?.components(separatedBy: " ")
            var concatedUrl = query![0]
            if (query!.count) > 1{
                for i in 1...query!.count-1{
                    concatedUrl += "%20" + (query![i])
                }
            }
            
            json.checkReachability { (connectivity) in
                if connectivity{
                    self.json.getMovies(url: "https://api.themoviedb.org/3/search/movie?api_key=1c49378c151f43527b6b7af9330e8875&query="+concatedUrl) { (response) in
                        if response.count == 0 {
                            self.showAlert(withMessage: "Movie Not Found")
                        }else{
                            self.fillMovies(response: response, entityName: "")
                            DispatchQueue.main.async {
                                self.homeCollectionView.reloadData()
                            }
                        }
                        
                    }
                }else{
                    self.movies = self.coreData.getMoviesFromCoreData(entityName: "MostPopular")
                    self.showAlert(withMessage: "No Result")
                    DispatchQueue.main.async {
                        self.homeCollectionView.reloadData()
                    }
                }
            }
            searchBar.endEditing(true)
            searchBar.showsCancelButton = false
            
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        movies = SearchCanceledMovies
        homeCollectionView.reloadData()
    }
    
}

