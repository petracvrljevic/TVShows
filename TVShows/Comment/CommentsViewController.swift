//
//  CommentsViewController.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 12/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var episodeID: String?
    var comments = [Comment]()
    var testImages = [#imageLiteral(resourceName: "img-placeholder-user1"), #imageLiteral(resourceName: "img-placeholder-user2"), #imageLiteral(resourceName: "img-placeholder-user3")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        self.navigationItem.title = "Comments"
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.hidesBackButton = true
        let backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "ic-navigate-back"), for: .normal)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        downloadComments()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            bottomConstraint.constant = 0
        }
        else {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                bottomConstraint.constant = keyboardSize.height
                let lastIndex = comments.count-1
                if lastIndex > 0 {
                    tableView.scrollToRow(at: IndexPath(row: lastIndex, section: 0), at: .none, animated: true)
                }
            }
        }
    }
    
    func downloadComments() {
        
        guard let id = episodeID else { return }
        
        APIHelper().getComments(url: APIHelper.commentsURL(id: id)) { (comments) in
            
            if comments.isEmpty {
                self.tableView.isHidden = true
                
                self.showNoCommentsView()
            }
            else {
                self.tableView.isHidden = false
                self.comments = comments
                self.tableView.reloadData()
            }
            
        }
    }
    
    private func showNoCommentsView() {
        
        if let noCommentsView = Bundle.main.loadNibNamed("NoCommentsView", owner: nil, options: nil)?.first as? NoCommentsView {
            self.view.addSubview(noCommentsView)
            
            noCommentsView.translatesAutoresizingMaskIntoConstraints = false
            noCommentsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            noCommentsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
            noCommentsView.heightAnchor.constraint(equalToConstant: 210).isActive = true
            noCommentsView.widthAnchor.constraint(equalToConstant: 310).isActive = true
        }
        
    }
    
    @objc func handleBack() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func postTapped(_ sender: UIButton) {
        
        if let text = commentTextField.text, let id = episodeID {
            let params: Parameters = ["text": text,
                                      "episodeId": id]
            
            APIHelper().postComment(url: APIHelper.addCommentURL, params: params) { (success) in
                if success {
                    self.downloadComments()
                    self.commentTextField.text = ""
                }
                else {
                    Helper().showErrorAlertWithMessage(message: "Problem with adding comment!", view: self)
                }
            }
        }
        
        
    }
    
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
        
        let comment = comments.reversed()[indexPath.row]
        cell.commentUsernameLabel.text = comment.userEmail
        cell.commentTextLabel.text = comment.text
        
        let randomNumber = Int(arc4random_uniform(3))
        cell.commentImageView.image = testImages[randomNumber]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
