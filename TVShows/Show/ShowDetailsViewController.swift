//
//  ShowDetailsViewController.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CodableAlamofire

class ShowDetailsViewController: UIViewController {
    
    @IBOutlet weak var showImageView: UIImageView!
    @IBOutlet weak var showTitle: UILabel!
    @IBOutlet weak var showDescription: UITextView!
    @IBOutlet weak var showNumberOfEpisodes: UILabel!
    
    @IBOutlet weak var helpView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var show: Show?
    var episodes = [Episode]()
    var tappedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let backButton = Helper().customBackButton(view: self.view)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        downloadDescriptionAndEpisodes()
        
        if Helper().isIphoneX() {
            topConstraint.constant = -44
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        Helper().setStatusBarColorLight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        Helper().setStatusBarColorDefault()
    }
    
    @objc func handleBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func downloadDescriptionAndEpisodes() {
        guard let id = show?.id else { return }
        
        APIHelper().getShowDescription(url: APIHelper.showDetailsURL(id: id)) { (description) in
            self.show?.description = description
        }
        
        self.downloadEpisodes()
    }
    
    private func downloadEpisodes() {
        guard let id = show?.id else { return }
        APIHelper().getShowEpisodes(url: APIHelper.episodesURL(id: id)) { (episodes) in
            self.episodes = episodes
            self.updateUI()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func newEpisodeTapped(_ sender: UIButton) {
    }
    
    private func updateUI() {
        
        helpView.layer.cornerRadius = 6
        
        guard let show = show else { return }
        
        showTitle.text = show.title
        showDescription.text = show.description
        showNumberOfEpisodes.text = "\(episodes.count)"
        
        if let url = URL(string: "https://api.infinum.academy\(show.imageUrl)") {
            showImageView.kf.setImage(with: url)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "episodeDetails" {
            let vc = segue.destination as! EpisodeDetailsViewController
            vc.episode = episodes[tappedIndex]
        }
        else if segue.identifier == "addEpisode" {
            let vc = segue.destination as! AddEpisodeViewController
            vc.delegate = self
            if let show = show {
                vc.showID = show.id
            }
        }
    }
}

extension ShowDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell") as! EpisodeTableViewCell
        
        let episode = episodes[indexPath.row]
        cell.episodeTitleLabel.text = episode.title
        cell.sesionEpisodeLabel.text = "S" + episode.season + " Ep" + episode.episodeNumber
                
        cell.onButtonTapped = {
            self.tappedIndex = indexPath.row
            self.performSegue(withIdentifier: "episodeDetails", sender: self)
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
}

extension ShowDetailsViewController: EpisodeDelegate {
    
    func episodeAdded() {
        self.downloadEpisodes()
    }
    
}
