//
//  ViewController.swift
//  dataApp
//
//  Created by MacStudent on 2020-01-16.
//  Copyright © 2020 MacStudent. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var books: [Book]?
    @IBOutlet var textFields: [UITextField]!
    


    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        loadCoreData()
        loadCoredata()
       // NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func getFilePath() -> String
    {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if documentPath.count > 0
        {
            let documentDirectory = documentPath[0]
            let filePath = documentDirectory.appending("/data.txt" )
            return filePath
        }
        return ""
    }
    func loadData()
    {
        let filePath = getFilePath()
        books = [Book]()
        
        if FileManager.default.fileExists(atPath: filePath)
        {
            do
            {
                //extract Data
                let fileContents = try String(contentsOfFile: filePath)
                let contentArray = fileContents.components(separatedBy: "\n")
                for content in contentArray
                {
                    let bookContent = content.components(separatedBy: ",")
                    if bookContent.count == 4
                    {
                        let book = Book(title: bookContent[0], author: bookContent[1], pages: Int(bookContent[2])!, year: Int(bookContent[3])!)
                        books?.append(book)
                    }
                }
            }
            catch
            {
                print(error)
            }
        }
    }
    @IBAction func addBook(_ sender: UIBarButtonItem)
    {
       let title = textFields[0].text ?? ""
        let author = textFields[1].text ?? ""
        let pages = Int(textFields[2].text ?? "") ?? 0
        let year =  Int(textFields[3].text ?? "2020") ?? 2020
        
        let book = Book(title: title,author: author, pages: pages, year: year)
        books?.append(book)
        
        for textField in textFields
        {
            textField.text = ""
            textField.resignFirstResponder()
            
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender Sender: Any?)
    {
        if let BookTable = segue.destination as? BookTableVC
        {
            BookTable.books = self.books
        }
        
    }
    
    @objc func saveData()
    {
        let filePath = getFilePath()
        var saveString = ""
        for book in books! {
            saveString = "\(saveString)\(book.title),\(book.author),\(book.pages),\(book.author)\n"
            
        }
        
        do
        {
            try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
        catch{
            print(error)
        }
    }

    func basic()
    {
        
    }
    
    func saveCoreData()
    {
        
        //call clear core data
        clearCoredata()
        // create an instance of app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //second step is context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for book in  books!
        {
            let bookEntity = NSEntityDescription.insertNewObject(forEntityName: "BookModel", into: managedContext)
            bookEntity.setValue(book.title, forKey: "title")
            bookEntity.setValue(book.author, forKey: "author")
            bookEntity.setValue(book.pages, forKey: "pages")
            bookEntity.setValue(book.year, forKey: "year")
            
        // save context
            do{
                try managedContext.save()
            }
            catch{
                print(error)
            }
        }
        
    }
    
    func loadCoredata()
    {
        books = [Book]()
        // create an instance of app delegate
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               //second step is context
               let managedContext = appDelegate.persistentContainer.viewContext
    //create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookModel")
        do{
            let results = try managedContext.fetch(fetchRequest)
            if results is [NSManagedObject]
            {
                for result in results as! [NSManagedObject]
                {
                    let title = result.value(forKey: "title")
                    let author = result.value(forKey: "author")
                    let pages = result.value(forKey: "pages")
                    let year = result.value(forKey: "year")
                    
                    books?.append(Book(title: title as! String, author: author as! String, pages: pages as! Int, year: year as! Int))
                }
            }
        }
        catch{
            print(error)
        }
        
    }
    func clearCoredata()
    {
                    // create an instance of app delegate
                   let appDelegate = UIApplication.shared.delegate as! AppDelegate
                   //second step is context
                   let managedContext = appDelegate.persistentContainer.viewContext
                    //create fetch request
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookModel")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObjects in results
            {
             if let managedObjectsData = managedObjects as? NSManagedObject
             {
                managedContext.delete(managedObjectsData)
                }
            }
        }catch{
            print(error)
        }
        
    }
}

