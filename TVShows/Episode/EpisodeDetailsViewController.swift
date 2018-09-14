//
//  EpisodeDetailsViewController.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import Kingfisher

class EpisodeDetailsViewController: UIViewController {
    
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeSeasonEpisodeLabel: UILabel!
    @IBOutlet weak var helpView: UIView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var episode: Episode?

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = Helper().customBackButton(view: self.view)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        updateUI()
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
    
    private func updateUI() {
        
        helpView.layer.cornerRadius = 6
        
        guard let episode = episode else { return }
        
        episodeTitleLabel.text = episode.title
        episodeSeasonEpisodeLabel.text = "S" + episode.season + " Ep" + episode.episodeNumber
        descriptionTextView.text = episode.description
        
        if let url = URL(string: "https://api.infinum.academy\(episode.imageUrl)") {
            episodeImageView.kf.setImage(with: url)
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comments" {
            let vc = segue.destination as! CommentsViewController
            if let id = episode?.id {
                vc.episodeID = id
            }
        }
    }
}
