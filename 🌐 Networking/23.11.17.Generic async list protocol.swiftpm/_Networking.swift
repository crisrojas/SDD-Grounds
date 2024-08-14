//
//  Networking.swift
//  Generic async list protocol
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.
//

import Foundation


// Globals
let jsonDecoder = JSONDecoder()

// MARK: - Newtork

final class Api {
    static let baseURL = "http://localhost:3000"
}

protocol NetworkResource {
    associatedtype T: Decodable
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension NetworkResource {
    var queryItems: [URLQueryItem] { [] }
    func get() async throws -> T {
        let url = URL(string: Api.baseURL)!.appendingPathComponent(path)
        var urlComponents = URLComponents(string: url.absoluteString)
        
        if queryItems.isNotEmpty {
            urlComponents?.queryItems = queryItems
        }
        
        let request = URLRequest(url: urlComponents!.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try jsonDecoder.decode(T.self, from: data)
        return decoded
    }
}

// MARK: - Api models

struct Item: Identifiable, Decodable {
    let id: String
    let title: String
    let subtitle: String
    let commentCount: String
}


struct Comment: Identifiable, Decodable {
    let id: String
    let feedId: String
    let author: String
    let comment: String
}


