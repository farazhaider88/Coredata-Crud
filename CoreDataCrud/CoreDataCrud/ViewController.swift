//
//  ViewController.swift
//  CoreDataCrud
//
//  Created by Faraz Haider on 27/07/2020.
//  Copyright © 2020 Faraz Haider. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var people: [NSManagedObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "The List"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do{
            people = try managedContext.fetch(fetchRequest)
        }catch let error as NSError{
            print("could not fetch . \(error), \(error.description)")
        }
        
    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        
                                        guard let textField = alert.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        
                                        self.save(name: nameToSave)
                                        self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext

      let entity =
        NSEntityDescription.entity(forEntityName: "Person",
                                   in: managedContext)!
      
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)

      person.setValue(name, forKeyPath: "name")
    
      do {
        try managedContext.save()
        people.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
}


extension ViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
            let person = people[indexPath.row]
            cell.textLabel?.text = person.value(forKeyPath: "name") as? String
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = people[indexPath.row]
        let personName = person.value(forKeyPath: "name") as? String
        
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
           return
         }
         
         let managedContext =
           appDelegate.persistentContainer.viewContext

         var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", personName as! CVarArg)
        
        do{
                let test = try managedContext.fetch(fetchRequest)
            let objectUpdate = test[0]
            (objectUpdate as AnyObject).setValue("NEW NAME", forKey: "name")
            do{
                try managedContext.save()
            }catch{
                print(error)
            }
            
            }catch let error as NSError{
                print("could not fetch . \(error), \(error.description)")
            }
        
        tableView.reloadData()
    }
    
   func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
  
            let person = people[indexPath.row]
            let personName = person.value(forKeyPath: "name") as? String
            
            guard let appDelegate =
               UIApplication.shared.delegate as? AppDelegate else {
               return
             }
             
             let managedContext =
               appDelegate.persistentContainer.viewContext

             var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
            
            fetchRequest.predicate = NSPredicate(format: "name = %@", personName as! CVarArg)
            
            do{
                    let test = try managedContext.fetch(fetchRequest)
                let objectUpdate = test[0]
                managedContext.delete(objectUpdate as! NSManagedObject)
                people.remove(at: indexPath.row)
            
                do{
                    try managedContext.save()
                }catch{
                    print(error)
                }
                
                }catch let error as NSError{
                    print("could not fetch . \(error), \(error.description)")
                }
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
        }
    }
}
