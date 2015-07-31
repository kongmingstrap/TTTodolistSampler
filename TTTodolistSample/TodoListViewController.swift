//
//  TodoListViewController.swift
//  TTTodolistSample
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: TodoDetailViewController? = nil
    var editViewController: TodoEditViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? TodoDetailViewController
        }
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh() {
        let request = TodoSampleAPI.GetTodos()
        TodoSampleAPI.sendRequest(request) { result in
            switch result {
            case .Success(let todos):
                let context = self.fetchedResultsController.managedObjectContext
                let entity = self.fetchedResultsController.fetchRequest.entity!
                for todo in todos.todos {
                    let id = todo["id"]
                    let content = todo["content"]
                    let fetchRequest = NSFetchRequest()
                    fetchRequest.entity = entity
                    let format = "id == \(id!)"
                    let predicate = NSPredicate(format: format, argumentArray: nil)
                    fetchRequest.predicate = predicate
                    do {
                        let fetchObjects = try context.executeFetchRequest(fetchRequest)
                        if fetchObjects.count > 0 {
                            let managedObject = fetchObjects[0] as! NSManagedObject
                            managedObject.setValue(id, forKey: "id")
                            managedObject.setValue(content, forKey: "content")
                        } else {
                            let managedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
                            managedObject.setValue(id, forKey: "id")
                            managedObject.setValue(content, forKey: "content")
                        }
                        try context.save()
                    } catch {
                        abort()
                    }
                }
            case .Failure(let error):
                print("error: \(error)")
            }
            self.refreshControl!.endRefreshing()
        }
    }
    
    func insertNewObject(sender: AnyObject) {
        self.performSegueWithIdentifier("showEdit", sender: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! TodoDetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "showEdit" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! TodoEditViewController
            controller.doneTextClosure = ({(text: String) -> Void in
                print("todos: \(text)")
                let request = TodoSampleAPI.PostTodo(content: text)
                TodoSampleAPI.sendRequest(request) { result in
                    switch result {
                    case .Success(let todo):
                        let context = self.fetchedResultsController.managedObjectContext
                        let entity = self.fetchedResultsController.fetchRequest.entity!
                        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
                        newManagedObject.setValue(todo.id, forKey: "id")
                        newManagedObject.setValue(todo.content, forKey: "content")
                        do {
                            try context.save()
                        } catch {
                            abort()
                        }
                    case .Failure(let error):
                        print("error: \(error)")
                    }
                }
            })
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath))
            do {
                try context.save()
            } catch {
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("content")!.description
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Todo", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "TodoList")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             abort()
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

