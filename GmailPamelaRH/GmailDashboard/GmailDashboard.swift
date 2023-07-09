//
//  GmailDashboard.swift
//  GmailPamelaRH
//
//  Created by Razo Hernandez Pamela on 07/07/23.
//

import Foundation
import UIKit

struct UserEmailData: Decodable {
    var userEmail: [EmailContent]
}

struct EmailContent: Decodable {
    var emisor: String?
    var correoEmisor: String?
    var asunto: String?
    var mensaje: String?
    var hora: String?
    var leido: Bool?
    var destacado: Bool?
    var spam: Bool?
    
    init(_ emisor: String, _ correoEmisor: String, _ asunto: String, _ mensaje: String, _ hora: String, _ leido: Bool, _ destacado: Bool, _ spam: Bool) {
        self.emisor = emisor
        self.correoEmisor = correoEmisor
        self.asunto = asunto
        self.mensaje = mensaje
        self.hora = hora
        self.leido = leido
        self.destacado = destacado
        self.spam = spam
    }
}

public typealias FetchSuccessful = (_ success : Bool, _ error : NSError?) -> ()

public class GmailDashboard: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var emailTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyInboxView: UIView!
    
    private var emailContent: UserEmailData?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        emailTableView.delegate = self
        emailTableView.dataSource = self
        emailTableView.isScrollEnabled = true
        emailTableView.separatorColor = UIColor.clear
        emailTableView.separatorStyle = .none
        emailTableView.register(UINib(nibName: "EmailCell", bundle: nil), forCellReuseIdentifier: "EmailCell")
        DispatchQueue.main.async {
            self.fetchEmailContent { (success, error) in
                if success {
                    self.emailTableView.reloadData()
                }
            }
        }
    }
    
    public func fetchEmailContent(completionHandler:@escaping FetchSuccessful) {
        guard let pathJson = Bundle.main.path(forResource: "GmailUserInfo", ofType: "json") else {
            return
        }
        
        do {
            let dataUrl = try Data(contentsOf: URL(fileURLWithPath: pathJson), options: .mappedIfSafe)
            let decodeUserEmail = try JSONDecoder().decode(UserEmailData.self, from: dataUrl)
            
            emailContent = decodeUserEmail
            
            print("Numero de objetos: \(emailContent?.userEmail.count ?? 0)")
            
        } catch {
            print("JSON is not fetching itself")
            emptyInboxView.isHidden = false
        }
    }
    
    // MARK: TableViewDelegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //var numberOfRows = 0
        /*self.fetchEmailContent { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    numberOfRows = self?.emailContent?.userEmail.count ?? 0
                    self?.emptyInboxView.isHidden = true
                } else {
                    numberOfRows = 0
                    self?.emptyInboxView.isHidden = false
                }
                self?.emailTableView.reloadData()
            }
        }*/
        return 5
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmailCell", for: indexPath) as? EmailCell else { return UITableViewCell() }
        
        fetchEmailContent { (success, error) in
            if success {
                DispatchQueue.main.async {
                    cell.senderName.text = self.emailContent?.userEmail[indexPath.row].emisor
                    cell.emailSubject.text = self.emailContent?.userEmail[indexPath.row].asunto
                    cell.emailHeader.text = self.emailContent?.userEmail[indexPath.row].mensaje
                    cell.receivedTime.text = self.emailContent?.userEmail[indexPath.row].hora
                }
            }
        }
        return cell
    }
    
    
    
    
}
