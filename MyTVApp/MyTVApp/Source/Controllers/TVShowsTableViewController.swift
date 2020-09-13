//
//  TVShowsTableViewController.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 12/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import UIKit
import CoreData

class TVShowsTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext {
        if #available(iOS 13.0, *) {
            return (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        } else {
            return CoreDataStack.shared.viewContext
        }
    }
    var userCacheURL: URL?
    var tvShows = [TVShow]()
    var page: Int = 0
    var favourites: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            readPage(url: cacheURL.appendingPathComponent("paginatedTVShows", isDirectory: true), index: page)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
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
        return tvShows.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TVShowCell", for: indexPath)
        let tvShow = tvShows[indexPath.row]
        cell.textLabel?.text = tvShow.name
        cell.imageView?.downloaded(from: tvShow.image?.medium ?? "", contentMode: UIImageView.ContentMode.scaleAspectFit)
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tvShow = tvShows[indexPath.row]
        let result = checkExistence(of: tvShow.id)
        if let show = result.0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
                self?.deleteAlertView(acceptAction: { (_) in
                    self?.removeFavourite(show: show)
                })
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else if result.1 {
            let favouriteAction = UIContextualAction(style: .normal, title: "Favourite") { [weak self] (_, _, completion) in
                self?.saveFavourites(show: tvShow)
                completion(true)
            }
            favouriteAction.backgroundColor = .green
            return UISwipeActionsConfiguration(actions: [favouriteAction])
        } else {
            self.alertView(title: "Oos, algo salió mal!", message: "Hubo un problema al validar si este show está en favoritos")
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tvShow = tvShows[indexPath.row]
        detailViewController(show: tvShow)
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
    
    func detailViewController(show: TVShow) {
        let storyboard = self.storyboard!
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        viewController.tvShow = show
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

//MARK: - File Manager
extension TVShowsTableViewController {

    fileprivate func readPage(url: URL, index: Int) {
        let filepath = url.appendingPathComponent(String(index), isDirectory: false)
        if FileManager.default.fileExists(atPath: filepath.path) {
            DispatchQueue.global().async { [weak self] in
                do {
                    let data = try Data(contentsOf: filepath, options: [])
                    self?.tvShows.append(contentsOf: try JSONDecoder().decode([TVShow].self, from: data))
                    self?.tvShows.sort(by: {$0.id < $1.id})
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            loadPage(url: url, index: index)
        }
    }
    
    fileprivate func writePage(url: URL, index: Int, object: [TVShow]) {
        DispatchQueue.global().async {
            do {
                let path = url.appendingPathComponent(String(index), isDirectory: false)
                let data = try JSONEncoder().encode(object)
                FileManager.default.createFile(atPath: path.path, contents: data, attributes: nil)
            } catch {
                print(error.localizedDescription)
                self.alertView(title: "Oos, algo salió mal!", message: "Hubo un problema al guardar en cache")
            }
        }
    }
}

//MARK: - Services

extension TVShowsTableViewController {
    fileprivate func loadPage(url: URL, index: Int) {
        TVShowService.get(page: index) { [weak self] (list) in
            if let list = list {
                self?.tvShows.append(contentsOf: list)
                self?.tvShows.sort(by: {$0.id < $1.id})
                self?.writePage(url: url, index: index, object: list)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } else {
                self?.alertView(title: "Oos, algo salió mal!", message: "Ocurrió un error al consultar el servicio. ¿Quieres intentar nuevamente?")
            }
        }
    }
}

// MARK: - CoreData

extension TVShowsTableViewController {
    
    fileprivate func checkExistence(of id: Int) -> (NSManagedObject?, Bool) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CD_FavouriteTVShow")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        var object = [NSManagedObject]()
        do {
            object = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return (nil, false)
        }
        return (object.first, true)
    }
    
    fileprivate func saveFavourites(show: TVShow) {
        let favouriteTVShow = NSEntityDescription.entity(forEntityName: "CD_FavouriteTVShow", in: context)!
        let schedule = NSEntityDescription.entity(forEntityName: "CD_Schedule", in: context)!
        let scheduleMO = NSManagedObject(entity: schedule, insertInto: context)
        let image = NSEntityDescription.entity(forEntityName: "CD_Image", in: context)!
        let imageMO = NSManagedObject(entity: image, insertInto: context)
        let tvShow = NSManagedObject(entity: favouriteTVShow, insertInto: context)
        imageMO.setValue(show.image?.medium, forKeyPath: "medium")
        imageMO.setValue(show.image?.original, forKeyPath: "original")
        scheduleMO.setValue(show.schedule?.days, forKeyPath: "days")
        scheduleMO.setValue(show.schedule?.time, forKeyPath: "time")
        tvShow.setValue(show.name, forKeyPath: "name")
        tvShow.setValue(show.id, forKey: "id")
        tvShow.setValue(show.genres, forKey: "genres")
        tvShow.setValue(show.externals?.imdb, forKey: "imdb")
        tvShow.setValue(imageMO, forKey: "images")
        tvShow.setValue(show.network?.name, forKey: "network")
        tvShow.setValue(show.rating?.average, forKey: "rating")
        tvShow.setValue(scheduleMO, forKey: "schedule")
        tvShow.setValue(show.summary, forKey: "summary")
        do {
            try context.save()
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
            self.alertView(title: "Oos, algo salió mal!", message: "Hubo un problema al guardar/borrar este show de TV. ¿Quieres intentar nuevamente?")
        }
    }
    
    func removeFavourite(show: NSManagedObject) {
        context.delete(show)
        do {
            try context.save()
        } catch {
            self.alertView(title: "Oos, algo salió mal!", message: "Hubo un problema al guardar/borrar este show de TV. ¿Quieres intentar nuevamente?")
        }
    }
}
