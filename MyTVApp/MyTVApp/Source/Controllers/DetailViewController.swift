//
//  DetailViewController.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 12/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class DetailViewController: UIViewController {
    
    var context: NSManagedObjectContext {
        if #available(iOS 13.0, *) {
            return (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        } else {
            return CoreDataStack.shared.viewContext
        }
    }
    
    @IBOutlet weak var showImageView: UIImageView!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var generosLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var imdbButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var tvShow: TVShow!
    var showMO: NSManagedObject?
    var isFavourite: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        fetchFavourite(id: tvShow!.id)
        setTabBarButton()
    }
    
    func setTabBarButton() {
        if let favourite = isFavourite {
            switch favourite {
            case true:
                let barButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteAlertView))
                if #available(iOS 10.0, *) {
                    barButtonItem.tintColor = UIColor.black
                } else {
                    barButtonItem.tintColor = UIColor.white
                }
                navigationItem.rightBarButtonItem = barButtonItem
            default:
                let barButtonItem = UIBarButtonItem(title: "Favourite", style: .plain, target: self, action: #selector(addFavourite))
                if #available(iOS 10.0, *) {
                    barButtonItem.tintColor = UIColor.black
                } else {
                    barButtonItem.tintColor = UIColor.white
                }
                navigationItem.rightBarButtonItem = barButtonItem
            }
        } else {
            // TODO: Couldnt determine if favourite
        }
        
    }
    
    func setView() {
        networkLabel.text = tvShow.network?.name
        daysLabel.text = tvShow.schedule?.days?.joined(separator: ", ")
        timeLabel.text = tvShow.schedule?.time
        ratingLabel.text = "Rating: " + String(tvShow.rating?.average ?? 0)
        generosLabel.text = tvShow.genres?.joined(separator: ", ")
        summaryTextView.text = tvShow.summary
        imageView.downloaded(from: tvShow.image?.original ?? "", contentMode: UIImageView.ContentMode.scaleAspectFit)
        title = tvShow.name
        if tvShow.externals?.imdb == nil {
            imdbButton.isHidden = true
        } else {
            imdbButton.isHidden = false
        }
    }
    
    @IBAction func openWebViewButtonTap(_ sender: UIButton) {
        let storyboard = self.storyboard!
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebVC") as! WebKitViewController
        viewController.url = tvShow.externals?.imdb
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc func deleteAlertView() {
        let alert = UIAlertController(title: "Eliminar favorita", message: "¿Estás seguro que quieres eliminar este show de tu lista de favoritos?", preferredStyle: .alert)
        let accept = UIAlertAction(title: "Aceptar", style: .default, handler: { [weak self] _ in
            self?.removeFavourite()
        })
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(accept)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}


// MARK: - CoreData

extension DetailViewController {
    private func fetchFavourite(id: Int) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CD_FavouriteTVShow")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        var object = [NSManagedObject]()
        do {
            object = try context.fetch(fetchRequest)
            self.showMO = object.first
            isFavourite = object.count > 0
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @objc private func addFavourite() {
        let favouriteTVShow = NSEntityDescription.entity(forEntityName: "CD_FavouriteTVShow", in: context)!
        let schedule = NSEntityDescription.entity(forEntityName: "CD_Schedule", in: context)!
        let scheduleMO = NSManagedObject(entity: schedule, insertInto: context)
        let image = NSEntityDescription.entity(forEntityName: "CD_Image", in: context)!
        let imageMO = NSManagedObject(entity: image, insertInto: context)
        let tvShow = NSManagedObject(entity: favouriteTVShow, insertInto: context)
        imageMO.setValue(self.tvShow.image?.medium, forKeyPath: "medium")
        imageMO.setValue(self.tvShow.image?.original, forKeyPath: "original")
        scheduleMO.setValue(self.tvShow.schedule?.days, forKeyPath: "days")
        scheduleMO.setValue(self.tvShow.schedule?.time, forKeyPath: "time")
        tvShow.setValue(self.tvShow.name, forKeyPath: "name")
        tvShow.setValue(self.tvShow.id, forKey: "id")
        tvShow.setValue(self.tvShow.genres, forKey: "genres")
        tvShow.setValue(self.tvShow.externals?.imdb, forKey: "imdb")
        tvShow.setValue(imageMO, forKey: "images")
        tvShow.setValue(self.tvShow.network?.name, forKey: "network")
        tvShow.setValue(self.tvShow.rating?.average, forKey: "rating")
        tvShow.setValue(scheduleMO, forKey: "schedule")
        tvShow.setValue(self.tvShow.summary, forKey: "summary")
        do {
            try context.save()
            fetchFavourite(id: self.tvShow.id)
            setTabBarButton()
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
    
    @objc private func removeFavourite() {
        context.delete(showMO!)
        do {
            try context.save()
            fetchFavourite(id: tvShow.id)
            setTabBarButton()
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
}
