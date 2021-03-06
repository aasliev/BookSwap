//
//  booksPageViewController.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 11/9/19.
//  Copyright © 2019 RV. All rights reserved.
//


import UIKit
import CoreData

class booksPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageControl = UIPageControl()
    
    let commonFunctions = CommonFunctions.sharedCommonFunction
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Holds email of user's book page
    var usersBookPage : String?
    
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    // MARK: UIPageViewControllerDataSource
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "books"),
                self.newVc(viewController: "wishList")]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            //self.title = "Owned Books"
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        configurePageControl()
        
        checkOtherUser()
    }
    
    func getUser() -> String? {
        return usersBookPage
    }
    
    func checkOtherUser() {
        
        //cheking if user is on their own book page or some else's
        if (authInstance.isItOtherUsersPage(userEmail: usersBookPage!)) {
            //if other user is not empty, that means user is on someone else's screen
            addButton.isEnabled = false
            addButton.tintColor = UIColor.clear
        }
    }
    
    func configurePageControl() {
        
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        //self.pageControl.tintColor = UIColor.white
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor =
            UIColor(red: 0, green: 50, blue: 100, alpha: 1)
        self.view.addSubview(pageControl)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for subView in view.subviews {
            if  subView is  UIPageControl {
                subView.frame.origin.y = self.view.frame.size.height - self.tabBarController!.tabBar.frame.height-40
                
            }
        }
    }
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    
    // MARK: Delegate methords
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
        self.navigationItem.title = pageContentViewController.navigationItem.title
    }
    
    
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            //return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            //return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    //MARK: Add book to Firestore
    func updateToFirestore(bookName: String, bookAuthor: String, trueForOwnedBook_falseForWishList: Bool) {
        
        //Checking for extra space at the start or end of the String
        let name = bookName.trimmingCharacters(in: .whitespacesAndNewlines)
        let author = bookAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (trueForOwnedBook_falseForWishList) {
            //add book to OwnedBook
            databaseIstance.addToOwnedBook(currentUserEmail: authInstance.getCurrentUserEmail(), bookName: name, bookAuthor: author)
            
        } else {
            //add book to WishList
            databaseIstance.addToWishList(currentUserEmail: authInstance.getCurrentUserEmail(), bookName: name, bookAuthor: author)
            
        }
    }
    
    
    //MARK: Add Button Pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
       
        var bookTitle : String = ""
        var bookAuthor : String = ""
        var titleTextField = UITextField()
        var authorTextField = UITextField()
        
        
        let alert = UIAlertController(title: "Add New Book", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Book", style: .default) { (action) in
            
            //what will happen when the user clicks the add button
            bookTitle = titleTextField.text!
            bookAuthor = authorTextField.text!
            
            if (bookTitle.isEmpty || bookAuthor.isEmpty) {
                print("one Field is empty ")
                
                self.commonFunctions.createUIalert("Fields can't be empty.\nTry Again", self)
                return
            }
            
            //if in the owned books page, save it to owned books (or set the boolean to true, if we are using bool)
            //else save it to wish list
            let tmp = self.navigationItem.title
            
            if (tmp == "BookShelf") {
                self.saveBooks(viewControllerNumber: 1, title: bookTitle, author: bookAuthor)

                self.updateToFirestore(bookName: titleTextField.text!, bookAuthor: authorTextField.text!, trueForOwnedBook_falseForWishList: true)
                
            } else {
                self.saveBooks(viewControllerNumber: 2, title: bookTitle, author: bookAuthor)
                
                self.updateToFirestore(bookName: titleTextField.text!, bookAuthor: authorTextField.text!, trueForOwnedBook_falseForWishList: false)
                
            }
            
           
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Title of the Book"
                titleTextField = alertTextField
            }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Author"
            authorTextField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func saveBooks(viewControllerNumber: Int, title: String, author: String){
        
        //write a function to save functions
        if(viewControllerNumber == 1){
            
            //Checking if book already exist in core data. if exist in CoreDat, that means it's duplicate
            if (CoreDataClass.sharedCoreData.checkIfOwnedBookExist(bookName: title, bookAuthor: author)) {
                commonFunctions.createUIalert(title: "Book Exist!", "This book titile with author already exist.", self)
                return
            }
            
            //Checking if book already exist in Wish List core data. if exist ask user to move it from there.
            if (CoreDataClass.sharedCoreData.checkIfWishListBookExist(bookName: title, bookAuthor: author)) {
                commonFunctions.createUIalert(title: "Book Exist in Wish List!", "Book you're trying to add is already exist in Wish List. \nMove it from Wish List", self)
                return
            }
            
            //save inside the owned books
            var ownedBook = [OwnedBook]()
            
            let newOwnedBook = OwnedBook(context: self.context)
            newOwnedBook.author = author
            newOwnedBook.bookName = title
            newOwnedBook.holder = authInstance.getCurrentUserEmail()
            newOwnedBook.status = true
            
            ownedBook.append(newOwnedBook)
            
        } else {
            
            //Checking if book already exist in Wish List Core Data. if exist in CoreDat, that means it's duplicate
            if (CoreDataClass.sharedCoreData.checkIfWishListBookExist(bookName: title, bookAuthor: author)) {
                commonFunctions.createUIalert(title: "Book Exist in Wish List!", "This book titile with author already exist.", self)
                return
            }
            
            //Checking if book already exist in core data. if exist in CoreDat, that means it's duplicate
            if (CoreDataClass.sharedCoreData.checkIfOwnedBookExist(bookName: title, bookAuthor: author)) {
                commonFunctions.createUIalert(title: "Book Exist in Bookshelf!", "This book titile with author already exist in Bookshelf.", self)
                return
            }
            //
            var wishListArray = [WishList]()
            let newWishListBook = WishList(context: self.context)
            newWishListBook.author = author
            newWishListBook.bookName = title
            
            wishListArray.append(newWishListBook)
            //WishListScreen().refresher.beginRefreshing()
        }
        
        //post notification!!!
        NotificationCenter.default.post(name: .didReceiveData, object: nil)
        
        //NOTE: Need to create another save method which does tableview.reloadData() once context is saved. 
        CoreDataClass.sharedCoreData.saveContext()


    }
    
}
