//
//  LaunchScreenVC.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 1/6/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import UIKit
import Cosmos

class Details: UIViewController{
    
    
    let coreData = CoreDataHelper.coreDatahelperSingleTone
    var infoMovie = Movie()
    let jsonHelper =  JsonHelper.jsonHelperSingleTone
    var videosID = [String]()
    
    //for Reviews Collection View

    @IBOutlet weak var overViewTxt: UITextView!
    @IBOutlet weak var movieTitleLbl: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var favouritesBtn: UIButton!
    @IBOutlet weak var trailersTable: UITableView!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var reviewsCollection: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let videosUrl = "https://api.themoviedb.org/3/movie/"+String(infoMovie.id)+"/videos?api_key=1c49378c151f43527b6b7af9330e8875"
        jsonHelper.getMovies(url: videosUrl) {[unowned self] (respons) in
            if respons.count != 0{
                for i in 0...respons.count-1{
                    self.infoMovie.trailers.append(respons[i]["key"] as! String)
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.trailersTable.reloadData()
        }
        
        
        let reviewsUrl = "https://api.themoviedb.org/3/movie/"+String(infoMovie.id)+"/reviews?api_key=1c49378c151f43527b6b7af9330e8875"
        jsonHelper.getMovies(url: reviewsUrl) {[unowned self] (respons) in
            if respons.count != 0{
                for i in 0...respons.count-1{
                    self.infoMovie.reviews.append(respons[i]["content"] as! String)
                    DispatchQueue.main.async {
                        self.reviewsCollection.reloadData()
                    }
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        movieTitleLbl.text = infoMovie.title
        releaseDateLabel.text = infoMovie.releaseYear
        cosmosView.rating = (infoMovie.rating/2.0)
        overViewTxt.text = infoMovie.overView
        if infoMovie.hasImage{
            movieImage?.sd_setImage(with: URL(string: infoMovie.image), completed: nil)
        }else{
            movieImage?.image = UIImage.init(named: "placeholder.jpg")
        }
        
        if infoMovie.isFoavourite{
            favouritesBtn.setTitle("Remove From Favourites", for: .normal)
        }else{
            favouritesBtn.setTitle("Add To Favourites", for: .normal)
        }
    }
    
    @IBAction func favoritesBtn(_ sender: Any) {
        
        if infoMovie.isFoavourite {
            favouritesBtn.setTitle("Add To Favourites", for: .normal)
            infoMovie.isFoavourite = false
            coreData.DeleteMovieFromCoreData(withID: infoMovie.id, entityName: "FavouriteMovies")
        }else{
            favouritesBtn.setTitle("Remove From Favourites", for: .normal)
            infoMovie.isFoavourite = true
            coreData.insertMovieToCoreData(entityName: "FavouriteMovies", movieToInsert: infoMovie)
            
        }
    }
}

extension Details : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = "https://www.youtube.com/watch?v=" + infoMovie.trailers[indexPath.row]
        UIApplication.shared.open(URL(string: url)!)
    }
}

extension Details : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoMovie.trailers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Vcell", for: indexPath)
        cell.textLabel?.text = "Trailer \(indexPath.row+1)"
        cell.imageView?.image = UIImage.init(named: "youTube.png")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Trailers"
    }
    
}

extension Details : UICollectionViewDelegate{}

extension Details : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoMovie.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "revCell", for: indexPath) as! ReviewPageCell
        cell.reviewerImage.image = UIImage.init(named: "reviewer")
        cell.reviewText.text = infoMovie.reviews[indexPath.row]
        return cell
    }
}

extension Details : UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        let width = collectionView.frame.size.width
        return CGSize(width: width , height: height )
    }
    
}
