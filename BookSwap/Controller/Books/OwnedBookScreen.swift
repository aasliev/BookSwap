//
//  OwnedBookScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class OwnedBookScreen: UITableViewController {
    var itemArray = [OwnedBook]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("inside ownedBookScreen")
        loadItems()
        tableView.rowHeight = 80
    }
    
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "booksCell", for: indexPath) as! BooksTableViewCell
        cell.nameOfTheBook?.text = itemArray[indexPath.row].bookName
        cell.authorOfTheBook?.text = itemArray[indexPath.row].author
        cell.swap.isHidden = true
        cell.delegate = self
        return cell
    }
    
    
    
    //MARK: - Model Manipulation Methods
    func loadItems(with request: NSFetchRequest<OwnedBook> = OwnedBook.fetchRequest()) {
        do {
            //let request = request
            //request.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
    
    func saveItems()
    {
        do {
            try context.save()
            print("saved")
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }

}


//MARK: Search

extension OwnedBookScreen: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<OwnedBook> = OwnedBook.fetchRequest()
        request.predicate = NSPredicate(format: "bookName CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
        
        loadItems(with: request)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadItems()
            tableView.reloadData()
        }
    }
    
}

//MARK: SwipeCellKit
extension OwnedBookScreen: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.saveItems()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-icon")
        
        return [deleteAction]
    }
    
    
}
