//
//  HomePageCell.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 1/2/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import UIKit

class CollectionViewsCustomCells: UICollectionViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    
    var btnTapAction : (()->())?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    let addToFavouritesButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.contactAdd)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.isOpaque = true
        let fav = UIImage.init(named: "fav")
        let tintedFav = fav?.withRenderingMode(.alwaysOriginal)
        button.setImage(fav, for: .normal)

        return button
    }()
    func setupViews(){
        
        addSubview(addToFavouritesButton)
        addToFavouritesButton.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        
    }
    
    @objc func btnTapped() {
        btnTapAction?()
    }
}
