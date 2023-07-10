//
//  GmailDashboard.swift
//  GmailPamelaRH
//
//  Created by Razo Hernandez Pamela on 07/07/23.
//

import UIKit

struct GmailColors {
    var grayGmail: UIColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
    var blueGmail: UIColor = UIColor(red: 83.0/255.0, green: 131.0/255.0, blue: 236.0/255.0, alpha: 1.0)
}

struct UserEmailData: Decodable, Encodable {
    var userEmail: [EmailContent]
}

struct EmailContent: Decodable, Encodable {
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

public enum FilterEmails {
    case inbox
    case starred(Bool)
    case spam(Bool)
    case trash
}

public typealias FetchSuccessful = (_ success : Bool, _ error : NSError?) -> ()

public class GmailDashboard: UIViewController {
    
    @IBOutlet weak var emailTableView: UITableView!
    @IBOutlet weak var emptyInboxView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var slideOutMenu: UIView!
    @IBOutlet weak var leadingConstraintMenu: NSLayoutConstraint!
    
    private var emailContent: UserEmailData?
    
    var filterStarred: FilterEmails?
    var filterSpam: FilterEmails?
    
    var shouldCellBeExpanded = false
    var indexOfExpandedCell = -1
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.initEmailTableView()
        blurView.isHidden = true
        
        ///UISwipeGestureRecognizer
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.showSlideOutMenuGesture(_:)))
        rightSwipe.direction = .right
        
        self.view.addGestureRecognizer(rightSwipe)
        
        if let data = UserDefaults.standard.object(forKey: "emailDeleted") as? Data,
           let category = try? JSONDecoder().decode(EmailContent.self, from: data) {
            print("UserDefaults Email: \(category)")
        }
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
    
    ///SlideOutMenu
    @objc func showSlideOutMenuGesture(_ sender: UITapGestureRecognizer? = nil) {
        blurView.isHidden = false
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        UIView.animate(withDuration: 0.7) {
            self.blurView.alpha = 1
            self.leadingConstraintMenu.constant = 0
            self.view.layoutIfNeeded()
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissSlideOutMenu(_:)))
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.numberOfTapsRequired = 1
        blurView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissSlideOutMenu(_ sender: UITapGestureRecognizer? = nil) {
        UIView.animate(withDuration: 1) {
            self.blurView.alpha = 0
            self.leadingConstraintMenu.constant = -350
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
        
        cell.starredImage.image = cell.starredImage.image?.withRenderingMode(.alwaysTemplate)
        cell.spamImage.image = cell.spamImage.image?.withRenderingMode(.alwaysTemplate)
        cell.starredImage.tintColor = GmailColors().grayGmail
        cell.spamImage.tintColor = GmailColors().grayGmail
        
        filterStarred = .starred(emailContent?.userEmail[indexPath.row].destacado ?? false)
        filterSpam = .spam(emailContent?.userEmail[indexPath.row].spam ?? false)
        
        cell.garbageButton.tag = indexPath.row
        cell.garbageButton.addTarget(self, action: #selector(garbageButton(sender:)), for: .touchUpInside)
    
        
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
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func garbageButton(sender: UIButton) {
        let index = sender.tag
        
        if let encoded = try? JSONEncoder().encode(emailContent?.userEmail[index]) {
            UserDefaults.standard.set(encoded, forKey: "emailDeleted")
        }
        
        self.emailContent?.userEmail.remove(at: index)
        
        let indexPath = IndexPath(row: index, section: 0)
        self.emailTableView.deleteRows(at: [indexPath], with: .left)
        self.emailTableView.reloadData()
    }
}
