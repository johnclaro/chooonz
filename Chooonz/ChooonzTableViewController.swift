//
//  ChooonzTableViewController.swift
//  Chooonz
//
//  Created by John Claro on 17/05/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ChooonzTableViewController: UITableViewController, UISearchResultsUpdating, ChooonzModelDelegate {
    
    var chooonzs: [Chooonz] = [Chooonz]()
    var filteredChooonzs = [Chooonz]()
    var searchController: UISearchController!
    var selectedChooonz = Chooonz(youtubeTitle: "", youtubeThumbnail: UIImage(named: "photoNotAvailable")!, youtubeID: "", artistName: "", artistImage: UIImage(named: "photoNotAvailable")!, artistDescription: "")
    let chooonzModel: ChooonzModel = ChooonzModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chooonzModel.delegate = self
        self.chooonzModel.getChooonzs()
        self.searchController = UISearchController(searchResultsController: nil) // Instantiates the search controller
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false // Disables dimming of background when search bar is pressed
        self.tableView.tableHeaderView = self.searchController.searchBar // Converts the table view's header to the search controller's search bar.
        definesPresentationContext = true // Removes the blank space between the search bar and the table view
        self.tableView.reloadData()
    }
    
    func dataReady() {
        self.chooonzs = self.chooonzModel.chooonzArray
        self.tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Filter through the songs
        self.filteredChooonzs = self.chooonzs.filter { (chooonz: Chooonz) -> Bool in
            if chooonz.youtubeTitle.lowercaseString.containsString(self.searchController.searchBar.text!.lowercaseString) {
                return true
            } else {
                return false
            }
        }
        
        // Update the results table view
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active {
            return self.filteredChooonzs.count
        } else {
            return self.chooonzs.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooonzCell", forIndexPath: indexPath) as! ChooonzCell
        
        if self.searchController.active {
            cell.youtubeTitle?.text = self.filteredChooonzs[indexPath.row].youtubeTitle
            cell.artistName?.text = self.filteredChooonzs[indexPath.row].artistName
            cell.youtubeThumbnail?.image = self.filteredChooonzs[indexPath.row].youtubeThumbnail
            cell.artistImage?.image = self.filteredChooonzs[indexPath.row].artistImage
            // Give image rounded corners
            cell.artistImage.layer.cornerRadius = cell.artistImage.frame.size.width / 2
            cell.artistImage.clipsToBounds = true
            
        } else {
            cell.youtubeTitle?.text = self.chooonzs[indexPath.row].youtubeTitle
            cell.artistName?.text = self.chooonzs[indexPath.row].artistName
            cell.youtubeThumbnail?.image = self.chooonzs[indexPath.row].youtubeThumbnail
            cell.artistImage?.image = self.chooonzs[indexPath.row].artistImage
            // Give image rounded corners
            cell.artistImage.layer.cornerRadius = cell.artistImage.frame.size.width / 2
            cell.artistImage.clipsToBounds = true
        }

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get a reference to the destination view controller
        if segue.identifier == "goToVideo" {
            let videoViewController = segue.destinationViewController as! ChooonzVideoViewController
            let path = tableView.indexPathForSelectedRow
            if self.searchController.active{
                self.selectedChooonz = self.filteredChooonzs[path!.row]
            } else {
                self.selectedChooonz = self.chooonzs[path!.row]
            }
            // Set the selected video property of the destination view controller
            videoViewController.selectedChooonz = self.selectedChooonz
        }
    }
}
