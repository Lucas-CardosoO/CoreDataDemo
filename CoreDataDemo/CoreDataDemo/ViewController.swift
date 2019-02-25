//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Lucas Cardoso on 19/02/19.
//  Copyright © 2019 Lucas Cardoso. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var usersTableView: UITableView!
    var names: [Person] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Friends List"
        
        usersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Testando o Core Data
        
        /*
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        newUser.setValue("abc", forKey: "username")
        newUser.setValue("admin", forKey: "password")
        newUser.setValue("26", forKey: "age")
        
        do {
            try context.save()
        } catch {
            print("Failed Saving")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        //request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]{
                print(data.value(forKey: "username") as! String)
            }
        } catch {
            print("Failed Fetching")
        }
        */
    }

    @IBAction func addFriend(_ sender: Any) {
        let alert = UIAlertController(title: "New Friend", message: "Add a new friend", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            
            self.save(nameToSave)
            self.usersTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(_ name:String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext) as! Person
        
        person.name = name

        do {
            try managedContext.save()
            names.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFromDatabase(_ person: Person){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        let myPredicate = NSPredicate(format: "name == %@", person.name!)
        
        fetchRequest.predicate = myPredicate
        do {
            let delPersons = try managedContext.fetch(fetchRequest)
            let delPerson = delPersons[0]
            
            managedContext.delete(delPerson)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        do {
            names = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var owner:Person?
        
        if let sender = sender as? Person{
            owner = sender
        }
        
        let destinationViewController = segue.destination as! PokemonViewController
        
        destinationViewController.owner = owner
        
        super .prepare(for: segue, sender: sender)
    }
}


// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = names[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = person.value(forKey: "name") as? String
        
        return cell
    }
    
    
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = names[indexPath.row]
        
        performSegue(withIdentifier: "toPokemon", sender: person)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            self.deleteFromDatabase(self.names[indexPath.row])
            self.names.remove(at: indexPath.row)
            self.usersTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
    }
}

