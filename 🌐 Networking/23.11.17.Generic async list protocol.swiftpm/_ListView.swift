//
//  code.swift
//  Generic async list protocol
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.
//

import SwiftUI

enum ListState<T> {
    case idle
    case loading
    case success([T])
    case error(String)
    case empty
}

extension ListState {
    
    init(from array: [T]) {
        if array.isEmpty { self = .empty }
        else { self = .success(array) }
    }
}

protocol ListView: View, NetworkResource where T == [ModelType] {
    associatedtype ModelType: Identifiable
    associatedtype CellType: View
    var state: ListState<ModelType> { get set }
    func loadItems() async
    func row(_ item: ModelType) -> CellType
}

extension ListView {

    // MARK: - UI
    var body: some View { list }
    
    
    @ViewBuilder
    var list: some View {
        switch state {
        case .idle, .loading: loadingView
        case .error(let message): error(message)
        case .success(let items): list(items)
        default: emptyView
        }
    }
    
    var loadingView: some View {
        ProgressView().task { await loadItems() }
    }

    func error(_ message: String) -> some View { Text(message) }
    
    func list(_ items: [ModelType]) -> some View {
        List(items) { row($0) }
    }
    
    var emptyView: some View { Text("No items found") }
    
    // MARK: - Default methods
    
    // Would love to find a way to give a default loadItems()
    // implementation instead, but can't mutate state in extension...
    func makeState() async -> ListState<ModelType> {
        do {
            let data = try await get()
            return .init(from: data)
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
