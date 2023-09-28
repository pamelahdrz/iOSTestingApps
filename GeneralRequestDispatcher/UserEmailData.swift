//
//  UserEmailData.swift
//  GmailPamelaRH
//
//  Created by Pamela Hernández on 26/09/23.
//

public struct UserEmailData: Decodable, Encodable {
    var userEmail: [EmailContent]
}

struct EmailContent: Decodable, Encodable {
    var id: Int?
    var emisor: String?
    var correoEmisor: String?
    var asunto: String?
    var mensaje: String?
    var hora: String?
    var leido: Bool?
    var destacado: Bool?
    var spam: Bool?
    
    init(_ id: Int, _ emisor: String, _ correoEmisor: String, _ asunto: String, _ mensaje: String, _ hora: String, _ leido: Bool, _ destacado: Bool, _ spam: Bool) {
        self.emisor = emisor
        self.correoEmisor = correoEmisor
        self.asunto = asunto
        self.mensaje = mensaje
        self.hora = hora
        self.leido = leido
        self.destacado = destacado
        self.spam = spam
        self.id = id
    }
}
