//
//  CoreDataHelper.swift
//  MoviesProject
//
//  Created by Mostafa Samir on 1/4/20.
//  Copyright © 2020 Mostafa Samir. All rights reserved.
//

import UIKit
import CoreData
class CoreDataHelper {
    static let coreDatahelperSingleTone = CoreDataHelper()
    let appDelegate : AppDelegate?
    let managedContext : NSManagedObjectContext?
    var retrievedData : Array<NSManagedObject> = []
    private init() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate!.persistentContainer.viewContext
    }
    
    func getMoviesFromCoreData(entityName : String) -> [Movie] {
        var rtnMovies = [Movie]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName : entityName)
        
        do {
            retrievedData = try managedContext!.fetch(fetchRequest)
        } catch let error as NSError {
            print(error)
        }
        if retrievedData.count != 0{
            for i in 0...retrievedData.count-1{
                let movie = Movie()
                movie.id = retrievedData[i].value(forKey: "id") as! Int
                movie.title = retrievedData[i].value(forKey: "title") as! String
                movie.image = retrievedData[i].value(forKey: "image") as! String
                movie.overView = retrievedData[i].value(forKey: "overView") as! String
                movie.releaseYear = retrievedData[i].value(forKey: "releaseYear") as! String
                movie.rating = retrievedData[i].value(forKey: "rating") as! Double
                movie.hasImage = retrievedData[i].value(forKey: "hasImage") as! Bool
                movie.isFoavourite = retrievedData[i].value(forKey: "isFavourite") as! Bool
                rtnMovies.append(movie)
                
            }
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        return rtnMovies
    }
    
    
    
    func insertMovieToCoreData (entityName : String , movieToInsert : Movie) -> Void {
        
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext!)
            let movie = NSManagedObject(entity: entity!, insertInto: managedContext)
            movie.setValue(movieToInsert.id, forKey: "id")
            movie.setValue(movieToInsert.title, forKey: "title")
            movie.setValue(movieToInsert.image, forKey: "image")
            movie.setValue(movieToInsert.overView, forKey: "overView")
            movie.setValue(movieToInsert.releaseYear, forKey: "releaseYear")
            movie.setValue(movieToInsert.rating, forKey: "rating")
            movie.setValue(movieToInsert.hasImage, forKey: "hasImage")
            movie.setValue(movieToInsert.isFoavourite, forKey: "isFavourite")
            do{
                try managedContext?.save()
            }catch let error as NSError{
                print(error)
            }
    }
    
    func DeleteMovieFromCoreData(withID:Int , entityName : String) -> Void{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName : entityName)
        let myPredicate = NSPredicate(format: "id = \(withID)")
        fetchRequest.predicate = myPredicate
        if let result = try? managedContext!.fetch(fetchRequest) {
            for object in result {
                managedContext!.delete(object)
                do{
                    try managedContext!.save()
                }catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    func updateCoreDataObject(withID: Int , addedData : Any , forKey:String , entityName:String){
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName : entityName)
        let myPredicate = NSPredicate(format: "id = \(withID)")
        fetchRequest.predicate = myPredicate
        if let result = try? managedContext!.fetch(fetchRequest) {
            for object in result {
                object.setValue(addedData, forKey: forKey)
                do{
                    try managedContext!.save()
                }catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    func DeleteAllMoviesFrom(entityName : String) -> Void{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName : entityName)
        if let result = try? managedContext!.fetch(fetchRequest) {
            for object in result {
                managedContext!.delete(object)
                do{
                    try managedContext!.save()
                }catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    
    private func checkExistanceOfMovieInCoreData (movie:Movie , entityName : String) -> Bool {
        let coreDataMovies = getMoviesFromCoreData(entityName: entityName)
        var movieExist = false
        if coreDataMovies.count != 0{
            for i in 0...coreDataMovies.count-1 {
                if movie.id == coreDataMovies[i].id{
                    movieExist = true
                }
            }
        }
        return movieExist
    }
    

    
}
