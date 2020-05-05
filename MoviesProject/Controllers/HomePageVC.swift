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
    let network = JsonHelper.jsonHelperSingleTone
    var movieStore = MovieStore()
    var SearchCanceledMovies = [Movie]()
    let sortMenu = ["Most Popular","Top Rated","In Theaters"]
    let rightBarDropDown = DropDown()
    
    @IBOutlet weak var sortBtnOutlet: UIBarButtonItem!
    
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "film2")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor.white)
        self.view.addSubview(revealingSplashView)
        revealingSplashView.startAnimation(){}
        network.checkReachability(completion: {[unowned self] (connected) in
            if connected{
                self.getDataFromNetwork(url: .mostPopular, entity: .mostPopular, appendValues: false)
                
            }else{
                self.movieStore.getMoviesFromCoreData(entityName: .mostPopular)
            }
            
        })
        
        rightBarDropDown.anchorView = sortBtnOutlet
        rightBarDropDown.dataSource = sortMenu
        rightBarDropDown.cellConfiguration = { (index, item) in return "\(item)" }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeCollectionView.reloadData()
    }
    
    
    
    func showAlert(withMessage:String){
        let noConnectionAlert = UIAlertController(title:"", message: withMessage, preferredStyle: .alert)
        noConnectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(noConnectionAlert, animated: true, completion: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func sortBtnPressed(_ sender: Any) {
        network.checkReachability(completion: {[unowned self] (connection) in
            self.rightBarDropDown.selectionAction = { (index: Int, item: String) in
                if index == 0 {

                    if connection{

                            self.getDataFromNetwork(url: .mostPopular, entity: .mostPopular, appendValues: false)
                            DispatchQueue.main.async {
                                self.rightBarDropDown.hide()
                                self.homeCollectionView.reloadData()
                            }
                        
                    }else{
                        self.movieStore.getMoviesFromCoreData(entityName: .mostPopular)
                        DispatchQueue.main.async {
                            self.rightBarDropDown.hide()
                            self.homeCollectionView.reloadData()
                        }
                    }
                    
                }
                else if index == 1 {
                    if connection{
                        self.getDataFromNetwork(url: .topRated, entity: .topRated, appendValues: false)
                        DispatchQueue.main.async {
                            self.rightBarDropDown.hide()
                            self.homeCollectionView.reloadData()
                        }
                    }else{
                        self.movieStore.getMoviesFromCoreData(entityName: .topRated)
                        DispatchQueue.main.async {
                            self.rightBarDropDown.hide()
                            self.homeCollectionView.reloadData()
                        }
                    }
                    
                }else{
                    if connection{
                        self.getDataFromNetwork(url: .inTheatres, entity: .inTheatres, appendValues: false)
                        DispatchQueue.main.async {
                            self.rightBarDropDown.hide()
                            self.homeCollectionView.reloadData()
                        }
                    }else{
                        self.movieStore.getMoviesFromCoreData(entityName: .topRated)
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
    
    
    func getDataFromNetwork(url: ApiURL , entity: CoreDataEntities,appendValues:Bool){
        
        network.getMovies(url: url.rawValue) {[unowned self] (response) in
            if response.count != 0{
                self.movieStore.fillMovies(response: response, entityName: entity.rawValue, appendValues: appendValues)
                self.SearchCanceledMovies = self.movieStore.movies
                self.movieStore.saveMoviesToCoreData(entityName: .mostPopular)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }else{
                self.showAlert(withMessage: "Poor Internet Connection")
                self.movieStore.getMoviesFromCoreData(entityName: .mostPopular)
            }
            
            DispatchQueue.main.async {
                self.homeCollectionView.reloadData()
            }
            
        }
    }
    
}


extension HomePageVC : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let info = storyboard?.instantiateViewController(withIdentifier: "Details") as! Details
        info.infoMovie = movieStore.getMovie(atIndex:indexPath.row)
        self.navigationController?.pushViewController(info, animated: true)
    }
}


extension HomePageVC :UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieStore.getMoviesCount()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewsCustomCells
        
        if movieStore.getMovie(atIndex: indexPath.row).hasImage{
            cell.movieImage.sd_setImage(with: URL(string: movieStore.getMovie(atIndex: indexPath.row).image ) , completed: nil)
        }
        else{
            cell.movieImage.image = UIImage.init(named: "placeholder.jpg")
        }
        if movieStore.getMovie(atIndex: indexPath.row).isFoavourite{
            cell.addToFavouritesButton.setImage( UIImage.init(named: "fav"), for: .normal)
        }else{
            cell.addToFavouritesButton.setImage( UIImage.init(named: "notfav"), for: .normal)
            
        }
        cell.btnTapAction = { () in
            if self.movieStore.getMovie(atIndex: indexPath.row).isFoavourite{
                self.movieStore.getMovie(atIndex: indexPath.row).isFoavourite = false
                self.coreData.DeleteMovieFromCoreData(withID: self.movieStore.getMovie(atIndex: indexPath.row).id, entityName: "FavouriteMovies")
                cell.addToFavouritesButton.setImage( UIImage.init(named: "notfav"), for: .normal)
            }else{
                self.movieStore.getMovie(atIndex: indexPath.row).isFoavourite = true
                self.coreData.insertMovieToCoreData(entityName: "FavouriteMovies", movieToInsert: self.movieStore.getMovie(atIndex: indexPath.row) )
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
            movieStore.movies = SearchCanceledMovies
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
            
            network.checkReachability {[unowned self] (connectivity) in
                if connectivity{
                    self.network.getMovies(url: "https://api.themoviedb.org/3/search/movie?api_key=1c49378c151f43527b6b7af9330e8875&query="+concatedUrl) { (response) in
                        if response.count == 0 {
                            self.showAlert(withMessage: "Movie Not Found")
                        }else{
                            self.movieStore.fillMovies(response: response, entityName: "", appendValues: false)
                            DispatchQueue.main.async {
                                self.homeCollectionView.reloadData()
                                 UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        }

                    }
                }else{
                    self.movieStore.getMoviesFromCoreData(entityName: .mostPopular)
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
        movieStore.movies = SearchCanceledMovies
        homeCollectionView.reloadData()
    }
    
}

