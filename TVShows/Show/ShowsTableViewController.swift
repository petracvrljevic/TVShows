//
//  ShowsTableViewController.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import Kingfisher

class ShowsTableViewController: UITableViewController {
    
    var shows = [Show]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarItems()
        downloadShows()
    }
    
    @objc func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.synchronize()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavigationBarItems() {
        let logoutButton = UIButton()
        logoutButton.setImage(#imageLiteral(resourceName: "ic-logout"), for: .normal)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutButton)
        
        let label = UILabel()
        label.text = "Shows"
        label.font = label.font.withSize(28)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    func downloadShows() {

        APIHelper().getShows(url: APIHelper.showsURL) { (shows) in
            
            self.shows = shows
            self.tableView.reloadData()
            
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let vc = segue.destination as! ShowDetailsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.show = shows[indexPath.row]
            }
            
        }
    }
    
}

extension ShowsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell
        
        let show = shows[indexPath.row]
        cell.showTitle.text = show.title
        
        if let url = URL(string: "https://api.infinum.academy\(show.imageUrl)") {
            cell.showImageView.kf.setImage(with: url)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}
