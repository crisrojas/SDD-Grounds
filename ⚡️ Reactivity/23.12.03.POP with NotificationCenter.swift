//
//  Notifications.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//
import Foundation

// Simplify working with the `NotificationCenter` by leveraging protocol extensions
extension Notification.Name {
    static let login : Self = .init(rawValue: "com.myapp.login" )
    static let logout: Self = .init(rawValue: "com.myapp.logout")
}

extension Notification {
    protocol Radio: Emitter, Observer {}
    protocol Emitter {}
    protocol Observer {}
}

extension Notification.Emitter {
    func post(_ notification: Notification.Name) {
        NotificationCenter.default.post(
            name: notification, 
            object: nil
        )
    }
}

extension Notification.Observer {
    func observe(_ notification: Notification.Name, _ selector: Selector) {
        NotificationCenter
        .default
        .addObserver(
            self,
            selector: selector,
            name: Notification.Name.logout,
            object: nil
        )
    }
}

final class Observer: Notification.Observer {
    
    func start() {observeAuthEvents()}
    
    private func observeAuthEvents() {
        observe(.login , #selector(login ))
        observe(.logout, #selector(logout))
    }
    
    @objc func logout() {print("login out")}
    @objc func login () {print("login in ")}
}

final class Emitter: Notification.Emitter {}

final class Radio: Notification.Radio {
    var loginSelector : Selector {#selector(login )}
    var logoutSelector: Selector {#selector(logout)}
    
    func observe(_ notification: Notification.Name) {
        switch notification {
            case .login : observe(notification, #selector(login))
            case .logout: observe(notification, #selector(logout))
            default: return
        }
    }
    
    @objc private func login () {print("login from radio" )}
    @objc private func logout() {print("logout from radio")}
}


var observer: Observer? = Observer()
observer?.start()

let emitter  = Emitter()
emitter.post(.logout)
emitter.post(.login )

observer = nil

let radio = Radio()
radio.observe(.login)
radio.observe(.logout)
radio.post(.login )
radio.post(.logout)
