//
//  APIHelper.swift
//  TVShows
//
//  Created by Petra Cvrljevic on 13/09/2018.
//  Copyright © 2018 Petra Cvrljevic. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire
import SwiftyJSON

class APIHelper {

    static let basic = "https://api.infinum.academy"
    
    static let loginURL = URL(string: "\(basic)/api/users/sessions")!
    
    static let showsURL = URL(string: "\(basic)/api/shows")!
    
    static let addCommentURL = URL(string: "\(basic)/api/comments")!
    
    static let uploadImageURL = URL(string: "\(basic)/api/media")!
    
    static let createEpisodeURL = URL(string: "\(basic)/api/episodes")!
    
    static func showDetailsURL(id: String) -> URL {
        return URL(string: "\(basic)/api/shows/\(id)")!
    }
    
    static func episodesURL(id: String) -> URL {
        return URL(string: "\(basic)/api/shows/\(id)/episodes")!
    }
    
    static func commentsURL(id: String) -> URL {
        return URL(string: "\(basic)/api/episodes/\(id)/comments")!
    }
    
    func header() -> [String: String]? {
        if let authorizationHeader = UserDefaults.standard.string(forKey: "token") {
            let headers = ["Authorization": authorizationHeader]
            return headers
        }
        return nil
    }
    
    func login(url: URL, params: Parameters, callback: @escaping(Bool) -> ()) {
        
        alamofireJSON(url: url, params: params, login: true) { (response) in
            DispatchQueue.main.async {
                callback(response)
            }
        }
    }
    
    let decoder = JSONDecoder()
    
    func getShows(url: URL, callback: @escaping([Show]) -> ()) {
        
        Helper().addProgressNotification()
        
        if let headers = header() {
            
            decoder.dateDecodingStrategy = .secondsSince1970
            
            Alamofire.request(url, headers: headers).responseDecodableObject(keyPath: "data", decoder: decoder) { (response: DataResponse<[Show]>) in
                
                Helper().hideProgressNotification()
                
                if let shows = response.result.value {
                    DispatchQueue.main.async {
                        callback(shows)
                    }
                }
                
            }
        }
    }
    
    func getShowDescription(url: URL, callback: @escaping(String) -> ()) {
        if let headers = header() {
            
            Helper().addProgressNotification()
            
            Alamofire.request(url, headers: headers).responseJSON { (response) in
                
                Helper().hideProgressNotification()
                
                if let value = response.result.value {
                    let json = JSON(value)
                    let description = json["data"]["description"].stringValue
                    
                    DispatchQueue.main.async {
                        callback(description)
                    }
                }
            }
        }
    }
    
    func getShowEpisodes(url: URL, callback: @escaping([Episode]) -> ()) {
        if let headers = header() {
            
            Helper().addProgressNotification()
            
            decoder.dateDecodingStrategy = .secondsSince1970
            
            Alamofire.request(url, headers: headers).responseDecodableObject(keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Episode]>) in
                
                Helper().hideProgressNotification()
                
                if let episodes = response.result.value {
                    DispatchQueue.main.async {
                        callback(episodes)
                    }
                }
                
            })
        }
    }
    
    func getComments(url: URL, callback: @escaping([Comment]) -> ()) {
        
        if let headers = header() {
            
            Helper().addProgressNotification()
            
            decoder.dateDecodingStrategy = .secondsSince1970
            
            Alamofire.request(url, headers: headers).responseDecodableObject(keyPath: "data", decoder: decoder) { (response: DataResponse<[Comment]>) in
                
                Helper().hideProgressNotification()

                if let comments = response.result.value {

                    DispatchQueue.main.async {
                        callback(comments)
                    }
                }
            }
        }
    }
    
    func postComment(url: URL, params: Parameters, callback: @escaping(Bool) -> ()) {
        
        alamofireJSON(url: url, params: params, login: false) { (response) in
            DispatchQueue.main.async {
                callback(response)
            }
        }
    }
    
    private func alamofireJSON(url: URL, params: Parameters, login: Bool, callback: @escaping(Bool) -> ()) {
        
        Helper().addProgressNotification()
        
        var headers = [String:String]()
        if !login {
            if let header = header() {
                headers = header
            }
        }
        else {
            headers = [:]
        }
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            Helper().hideProgressNotification()
            
            switch response.result {
            case .success:
                
                if let statusCode = response.response?.statusCode, statusCode>=200 && statusCode<300 {
                    if let value = response.result.value {
                        
                        if login {
                            let json = JSON(value)
                            
                            let token = json["data"]["token"].stringValue
                            UserDefaults.standard.set(token, forKey: "token")
                            UserDefaults.standard.synchronize()
                        }
                        
                        DispatchQueue.main.async {
                            callback(true)
                        }
                    }
                }
                else {
                    callback(false)
                }
   
            case .failure:
                
                DispatchQueue.main.async {
                    callback(false)
                }
            }
        }
    }
    
    func uploadImage(url: URL, imageURL: URL, callback: @escaping(String) -> ()) {
        
        Helper().addProgressNotification()
        
        var id = ""
        
        if let headers = header() {
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageURL, withName: "file")
            }, to: url, method: .post, headers: headers) { (encodingResult) in

                Helper().hideProgressNotification()
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        if let statusCode = response.response?.statusCode, statusCode>=200 && statusCode<300 {
                            if let value = response.result.value {
                                id = JSON(value)["data"]["_id"].stringValue
                                
                                DispatchQueue.main.async {
                                    callback(id)
                                }
                            }
                        }

                        
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    DispatchQueue.main.async {
                        callback(id)
                    }
                }
            }
        }
    }
    
    func addEpisode(url: URL, params: Parameters, callback: @escaping(Bool) -> ()) {
        alamofireJSON(url: url, params: params, login: false) { (response) in
            DispatchQueue.main.async {
                callback(response)
            }
        }
    }
}
