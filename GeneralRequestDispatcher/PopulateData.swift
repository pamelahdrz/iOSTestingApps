//
//  PopulateData.swift
//  GmailPamelaRH
//
//  Created by Pamela Hernández on 26/09/23.
//

import Foundation

class PopulateData {
    static let dataModel = PopulateData()
    var emailContent: [EmailContent]?
    
    public init(){}
    
    public func populateUserEmail(responseData: Data) {
        let decoder = JSONDecoder()
        do {
            emailContent = try decoder.decode([EmailContent].self, from: responseData)
        } catch {
            print("JSON is not fetching itself")
        }
    }
}


