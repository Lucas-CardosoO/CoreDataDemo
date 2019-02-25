//
//  PokemonViewController.swift
//  CoreDataDemo
//
//  Created by Lucas Cardoso on 20/02/19.
//  Copyright © 2019 Lucas Cardoso. All rights reserved.
//

import UIKit
import CoreData

class PokemonViewController: UIViewController {
    @IBOutlet weak var pokemonTableView: UITableView!
    var pokemons: [Pokemon] = []
    var owner: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = owner!.name! + "'s Pokemons"
        
        pokemonTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func save(name:String, pokeOwner: Person){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Pokemon", in: managedContext)!
        
        let pokemon = NSManagedObject(entity: entity, insertInto: managedContext) as! Pokemon
        
        pokemon.name = name
        pokemon.owned = pokeOwner
        
        do {
            try managedContext.save()
            pokemons.append(pokemon)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFromDatabase (_ pokemon: Pokemon){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pokemon>(entityName: "Pokemon")
        
        let myPredicate = NSPredicate(format: "name == %@ AND owned.name == %@", pokemon.name!, owner!.name!)
        
        fetchRequest.predicate = myPredicate
        do {
            let delPokemons = try managedContext.fetch(fetchRequest)
            let delPokemon = delPokemons[0]
            
            managedContext.delete(delPokemon)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func transferPokemon(pokemon: Pokemon, name: String) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        
        let myPredicate = NSPredicate(format: "name == %@", name)
        
        fetchRequest.predicate = myPredicate
        
        let personToTranfer = try managedContext.fetch(fetchRequest)
        
        if(personToTranfer.count < 1){
            throw "No User"
        }
        
        owner?.removeFromOwner(pokemon)
        
        personToTranfer[0].addToOwner(pokemon)
        
        do {
            try managedContext.save()
            
            loadData()
        } catch {
            print("Could not save.")
        }
    }
    
    func openTransferAlert(_ pokemon: Pokemon) {
        let alert = UIAlertController(title: "Transfer", message: "Transfer pokemon to:", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Transfer", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToTransfer = textField.text else {
                return
            }
            do{
                try self.transferPokemon(pokemon: pokemon, name: nameToTransfer)
            } catch {
                let errorAlert = UIAlertController(title: "Error", message: "Person don't exist", preferredStyle: .alert)
                
                let returnAction = UIAlertAction(title: "Cancel", style: .cancel)
                errorAlert.addAction(returnAction)
                
                self.present(errorAlert, animated: true)
            }
            self.pokemonTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
        super.viewWillAppear(animated)
    }
    
    func loadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Pokemon>(entityName: "Pokemon")
        
        let myPredicate = NSPredicate(format: "owned.name == %@", owner!.name!)
        
        fetchRequest.predicate = myPredicate
        do {
            pokemons = try managedContext.fetch(fetchRequest)
            //            pokemons = try managedContext.fetch(fetchRequest).filter({ (pokemon) -> Bool in
            //                return pokemon.owned?.name == self.owner?.name
            //            })
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @IBAction func addPokemon(_ sender: Any) {
        let alert = UIAlertController(title: "New Pokemon", message: "Add a new pokemon", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            
            self.save(name: nameToSave, pokeOwner: self.owner!)
            self.pokemonTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)

    }
}


// MARK: - UITableViewDataSource

extension PokemonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pokemon = pokemons[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = pokemon.value(forKey: "name") as? String
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PokemonViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            self.deleteFromDatabase(self.pokemons[indexPath.row])
            self.pokemons.remove(at: indexPath.row)
            self.pokemonTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let transfer = UITableViewRowAction(style: .default, title: "Transfer") { (action, indexPath) in
            // delete item at indexPath
            self.openTransferAlert(self.pokemons[indexPath.row])
//            self.pokemons.remove(at: indexPath.row)
//            self.pokemonTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        transfer.backgroundColor = UIColor.lightGray
        
        return [delete, transfer]
    }
}


extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
