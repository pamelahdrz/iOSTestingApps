//
//  GeneralRequestDispatcher.swift
//  GmailPamelaRH
//
//  Created by Pamela Hernández on 25/09/23.
//

import Foundation

public typealias FetchSuccessful = (_ success : Bool, _ error : NSError?) -> ()

public class GeneralRequestDispatcher {
    static let shared = GeneralRequestDispatcher()
    
    public init(){}
    
    public func fetchPOSTUserEmailContent(completionHandler:@escaping FetchSuccessful) {
        guard let endpoint = URL(string:"http://localhost:3000/userEmail") else { return }
        let urlRequest = URLRequest(url: endpoint)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(false, error as? NSError)
                return
            }
            
            guard let responseData = data else {
                print("nil Data received from the server")
                return
            }
            
            PopulateData.dataModel.populateUserEmail(responseData: responseData)
            completionHandler(true, nil)
        }
        task.resume()
    }
}
