//
//  ListTableViewController.swift
//  CoreDataProject
//
//  Created by Alexander Chervoncev on 17/1/2023.
//

import UIKit
import CoreData

final class ListTableViewController: UITableViewController {
    
    //MARK: - Inits
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Person]?
    
    //MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchPeople()
    }
    
    //MARK: - IBAction funcion
    @IBAction func addTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Person",
                                      message: "What is their name?",
                                      preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "add", style: .default) { [weak self] (action) in
            
            guard let self = self else { return }
            let texfield = alert.textFields![0]
            let newPerson = Person(context: self.context)
            newPerson.name = texfield.text
            newPerson.age = 209
            newPerson.gender = "Male"
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchPeople()
        }
        alert.addAction(submitButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let person = self.items?[indexPath.row]
        cell.textLabel?.text = person?.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.items?[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Person",
                                      message: "Edit Name",
                                      preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields?[0]
        textField?.text = person?.name
        
        let saveButton = UIAlertAction(title: "save", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            let textField = alert.textFields?[0]
            
            person?.name = textField?.text
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchPeople()
            
        }
        alert.addAction(saveButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let personToRemove = self.items?[indexPath.row]
            
            self.context.delete(personToRemove!)
            
            do {
                try self.context.save()
            } catch {
                
            }
            
            self.fetchPeople()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

//MARK: - Private extension
private extension ListTableViewController {
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func relationshipDemo() {
        let family = Family(context: context)
        family.name = "ABC Family"
        
        let person = Person(context: context)
        person.name = "Maggie"
        person.family = family
        
        family.addToPeople(person)
        
        do {
            try context.save()
        } catch {
            
        }
    }
    
    func fetchPeople() {
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            // sorting
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            // adding to the database
            self.items = try context.fetch(request)
            
            //asynchronous table restart
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetchPeople - \(error.localizedDescription)")
        }
    }
}
