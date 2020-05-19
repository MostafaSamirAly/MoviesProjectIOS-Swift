//
//  FavouritesVC.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 1/4/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import UIKit


class FavouritesVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    let coreData = CoreDataHelper.coreDatahelperSingleTone
    var favouriteMovies = [Movie]()
    //var cell = CollectionViewsCustomCells()

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        favouriteMovies = coreData.getMoviesFromCoreData(entityName: "FavouriteMovies")
        collectionView.reloadData()
    }
   

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return favouriteMovies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fcell", for: indexPath) as! CollectionViewsCustomCells
        
        if favouriteMovies[indexPath.row].hasImage{
            cell.movieImage.sd_setImage(with: URL(string: favouriteMovies[indexPath.row].image ) , completed: {
                (_,_,_,_) in
                cell.loadingIndicator.isHidden = true
            })
        }
            
        else{
            cell.movieImage.image = UIImage.init(named: "placeholder.jpg")
            
        }
        cell.addToFavouritesButton.isHidden=true
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let favouriteInfo = storyboard?.instantiateViewController(withIdentifier: "Details") as! Details
        favouriteInfo.infoMovie = favouriteMovies[indexPath.row]
        self.navigationController?.pushViewController(favouriteInfo, animated: true)
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = UIScreen.main.bounds.size.height
        let width = UIScreen.main.bounds.size.width
        return CGSize(width: width/2 , height: height/2 )
    }

    

}
