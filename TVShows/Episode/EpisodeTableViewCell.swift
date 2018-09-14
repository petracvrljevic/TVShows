//
//  EpisodeTableViewCell.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit

class EpisodeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sesionEpisodeLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    
    var onButtonTapped : (() -> Void)? = nil
    
    @IBAction func episodeDetailsTapped(_ sender: UIButton) {
        if let onButtonTapped = self.onButtonTapped {
            onButtonTapped()
        }
    }
}
