//
//  FavouritesTableViewController.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 12/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import UIKit
import CoreData

class FavouritesTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext {
        if #available(iOS 13.0, *) {
            return (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        } else {
            return CoreDataStack.shared.viewContext
        }
    }
    var favourites: [CD_FavouriteTVShow] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavourites()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PingFangTC-Light", size: 35)!, NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.backgroundColor = UIColor(named: "Purple")
            self.navigationController?.navigationBar.tintColor = UIColor.white
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PingFangTC-Light", size: 20
                )!, NSAttributedString.Key.foregroundColor: UIColor.black]
            UINavigationBar.appearance().barTintColor = UIColor(red: 120, green: 74, blue: 250, alpha: 1)
            self.navigationController?.navigationBar.tintColor = UIColor.black
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouritesCell", for: indexPath)
        let tvShow = favourites[indexPath.row]
        cell.textLabel?.text = tvShow.name
        cell.imageView?.downloaded(from: tvShow.images?.medium ?? "", contentMode: UIImageView.ContentMode.scaleAspectFit)
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tvShow = favourites[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.deleteAlertView(acceptAction: { (_) in
                self?.removeFavourite(show: tvShow)
            })
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let show = favourites[indexPath.row]
        detailViewController(show: show)
    }
    
    func deleteAlertView(acceptAction: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: "Eliminar favorita", message: "¿Estás seguro que quieres eliminar este show de tu lista de favoritos?", preferredStyle: .alert)
        let accept = UIAlertAction(title: "Aceptar", style: .default, handler: acceptAction)
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(accept)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    // MARK: Navigation

    func detailViewController(show: CD_FavouriteTVShow) {
        let storyboard = self.storyboard!
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        viewController.tvShow = TVShow(id: Int(show.id), name: show.name, genres: show.genres as? [String], schedule: Schedule(time: show.schedule?.time, days: show.schedule?.days as? [String]), rating: Rating(average: show.rating), network: Network(name: show.network), externals: Externals(imdb: show.imdb), image: Image(medium: show.images?.medium, original: show.images?.original), summary: show.summary)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

// MARK: - CoreData

extension FavouritesTableViewController {
    func getFavourites() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CD_FavouriteTVShow")
        fetchRequest.includesSubentities = true
        do {
            favourites = try (context.fetch(fetchRequest) as? [CD_FavouriteTVShow])!
            favourites.sort(by: {$0.id < $1.id})
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            self.alertView(title: "Oos, algo salió mal!", message: "Hubo un problema al cargar tus favoritos")
        }
    }
    
    func removeFavourite(show: NSManagedObject) {
        context.delete(show)
        do {
            try context.save()
            getFavourites()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            self.alertView(title: "Oos, algo salió mal!", message: "Hubo un problema al guardar tus favoritos")
        }
    }
}
