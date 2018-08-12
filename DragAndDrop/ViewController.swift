//
//  ViewController.swift
//  DragAndDrop
//
//  Created by Charles Martin Reed on 8/12/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate {
    
    //Interestingly enough, adding this functionality has added drag/drop across the OS. So you could, for instance, drag and drop from this add into the URL bar in Safari.
    
    //create two table views and two string arrays filed with "Left" and "Right"
    //both table views will use the view controller as their data source
    //both will have hardcoded frames, a re-use cell and will be added to the view
    //numberofRowsInSection
    //cellForRowAt
    
    
    var leftTableView = UITableView()
    var rightTableView = UITableView()
    
    //repeating the value "Left" 20 times, in an array of strings
    var leftItems = [String](repeating: "Left", count: 20)
    var rightItems = [String](repeating: "Right", count: 20)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the dataSource
        leftTableView.dataSource = self
        rightTableView.dataSource = self
        
        //creating the table views
        leftTableView.frame = CGRect(x: 0, y: 40, width: 150, height: 400)
        rightTableView.frame = CGRect(x: 150, y: 40, width: 150, height: 400)
        
        //setting up our cell reuse identifier
        leftTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        rightTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //adding the views to the screen
        view.addSubview(leftTableView)
        view.addSubview(rightTableView)
        
        //STEPS
        //1: Tell both tableViews to use currevnt view controller as drag/drop delegate
        //2: Enable drag and drop on both of them
        leftTableView.dragDelegate = self
        leftTableView.dropDelegate = self
        rightTableView.dragDelegate = self
        rightTableView.dropDelegate = self
        
        leftTableView.dragInteractionEnabled = true
        rightTableView.dragInteractionEnabled = true
    }

    //MARK: - TableView Procotol Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return leftItems.count
        } else {
            return rightItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if tableView == leftTableView {
            cell.textLabel?.text = leftItems[indexPath.row]
        } else {
            cell.textLabel?.text = rightItems[indexPath.row]
        }
        
        return cell
    }
   
    //MARK: - TableView Drag and Drop Protocol Methods
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        //called when user initiates a drag by holding
        //grab the contents into a variable
        let string = tableView == leftTableView ? leftItems[indexPath.row] : rightItems[indexPath.row]
        
        //turn that captured string into a Data value type cancel drag by returning an empty array
        guard let data = string.data(using: .utf8) else { return [] }
        
        //let other apps know what to do with the drag item by setting up an NSItemProvider
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        //where to drop the rows
        let destinationIndexPath: IndexPath
        
        //if the user places it in a row on our table view, reflect that choice. Otherwise, if they draw it outside of the parameters of our table view, place it at the end.
        if let indexPath = coordinator.destinationIndexPath {
            
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
            //attempt to load trings from drop coordinator
            coordinator.session.loadObjects(ofClass: NSString.self) { (items) in
                
                //convert the item provider array to a string array or bail out
                guard let strings = items as? [String] else { return }
                
                //create an empty array to track rows we've coppied
                var indexPaths = [IndexPath]()
                
                //loop over all the strings we've received
                for (index, string) in strings.enumerated() {
                    
                    //create an index path for this new row, moving it down depending on how many we've already inserted
                    let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                    
                    //insert the copy into the correct array
                    if tableView == self.leftTableView {
                        self.leftItems.insert(string, at: indexPath.row)
                    } else {
                        self.rightItems.insert(string, at: indexPath.row)
                    }
                    
                    //keep track of this new row
                    indexPaths.append(indexPath)
                }
                
                //insert them all into the table view at once
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

