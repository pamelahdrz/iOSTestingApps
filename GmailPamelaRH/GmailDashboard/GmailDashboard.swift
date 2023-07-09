//
//  GmailDashboard.swift
//  GmailPamelaRH
//
//  Created by Razo Hernandez Pamela on 07/07/23.
//

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

public class GmailDashboard: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var emailTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyInboxView: UIView!
    
    private var emailContent: UserEmailData?
    
    var shouldCellBeExpanded = false
    var indexOfExpandedCell = -1
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.initEmailTableView()
        searchBar.delegate = self
    }
    
    private func initEmailTableView() {
        self.fetchEmailContent { (success, error) in
            if success {
                self.emailTableView.delegate = self
                self.emailTableView.dataSource = self
                self.emailTableView.isScrollEnabled = true
                self.emailTableView.separatorColor = UIColor.clear
                self.emailTableView.separatorStyle = .none
                self.emailTableView.register(UINib(nibName: "EmailCell", bundle: nil), forCellReuseIdentifier: "EmailCell")
            } else {
                print("Tabla no Inicializada")
            }
        }
    }
    
    private func fetchEmailContent(completionHandler:@escaping FetchSuccessful) {
        guard let pathJson = Bundle.main.path(forResource: "GmailUserInfo", ofType: "json") else {
            return
        }
        
        do {
            let dataUrl = try Data(contentsOf: URL(fileURLWithPath: pathJson), options: .mappedIfSafe)
            let decodeUserEmail = try JSONDecoder().decode(UserEmailData.self, from: dataUrl)
            
            emailContent = decodeUserEmail
            
            completionHandler(true, nil)
            
        } catch {
            print("JSON is not fetching itself")
            emptyInboxView.isHidden = false
            
            completionHandler(false, error as NSError)
        }
    }
}

extension GmailDashboard: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if emailContent?.userEmail.count == 0 {
            numberOfRows = 0
            emptyInboxView.isHidden = false
        } else {
            numberOfRows = emailContent?.userEmail.count ?? 0
            emptyInboxView.isHidden = true
        }
        
        return numberOfRows
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmailCell", for: indexPath) as? EmailCell else { return UITableViewCell() }
        
        cell.garbageImage.image =  cell.garbageImage.image?.withRenderingMode(.alwaysTemplate)
        cell.garbageImage.tintColor = UIColor.red
        cell.selectionStyle = .none
        
        cell.senderName.text = emailContent?.userEmail[indexPath.row].emisor
        cell.emailSubject.text = emailContent?.userEmail[indexPath.row].asunto
        cell.emailHeader.text = emailContent?.userEmail[indexPath.row].mensaje
        cell.receivedTime.text = emailContent?.userEmail[indexPath.row].hora
        
        if shouldCellBeExpanded && indexPath.row == indexOfExpandedCell {
            cell.emailHeader.numberOfLines = 5
        } else {
            cell.emailHeader.numberOfLines = 3
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size: CGFloat = 0.0
        
        if shouldCellBeExpanded && indexPath.row == indexOfExpandedCell {
            size = 170
        } else {
            size = 140
        }
        
        return size
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexOfExpandedCell = indexPath.row
        shouldCellBeExpanded = true
        
        emailTableView.beginUpdates()
        emailTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        emailTableView.endUpdates()
    }
}
