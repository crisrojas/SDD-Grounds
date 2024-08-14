//
//  AsyncChainedCallsInteractor.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//
// #asynchronicity #networking

import Foundation

/*
The goal of this little playground is to come up with a simple api for chaining calls when using closure based async methods.
*/

// MARK: - Helpers
typealias AppResult = Result<String, Error>
typealias AppCompletion = (AppResult) -> Void

typealias ProgressCallback = (Double) -> Void

/* 
Lets say we have a web service with three calls.
In our UI, we need to chain them because they each depend on
previous one:
*/
final class WebService {
    func call1(completion: @escaping AppCompletion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call1 data"))
        }
    }
    func call2(data: String, completion: @escaping AppCompletion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call2 data"))
        }
    }
    func call3(data: String, completion: @escaping AppCompletion) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call3 data"))
        }
    }
}

/* 
We could invoke them in a nested callback fashion:
*/

final class SomeController {
    
    var service = WebService()
    
    func showError() {}
    func fetchData() {
        service.call1 { [weak self] result in
            switch result {
                case .success(let data):
                self?.service.call2(data: data) { [weak self] 
                    result in
                    switch result {
                        case .success(let data):
                        self?.service.call3(data: data) { _ in }
                        case .failure: 
                        self?.showError()
                    }
                }
                case .failure:
                self?.showError()
            }
        }
    }
}

// Which as we can see, can become hard to read very quickly.

/*
Lets chain those calls using an enum
*/
final class DataGetter {
    
    let webservice = WebService()
    var completion: AppCompletion!
    
    func callAsFunction(
        completion: @escaping AppCompletion) {
            
            self.completion = completion
            ongoinCall = .call1
        }
    
    var ongoinCall: CallChain? = .none {
        didSet {
            switch ongoinCall {
                case .call1: call1()
                case .call2(let data): call2(data: data)
                case .call3(let data): call3(data: data)
                case .none: break
            }
        }
    }
    
    func call1() {
        dp("first call")
        webservice.call1 { [weak self] result in
            switch result {
                case .success(let data):
                self?.ongoinCall = .call2(data: data)
                case .failure(let error):
                self?.completion(.failure(error))
            }
        }
    }
    
    func call2(data: String) {
        dp("second call")
        webservice.call2(data: data) { [weak self] result in
            switch result {
                case .success(let data):
                self?.ongoinCall = .call3(data: data)
                case .failure(let error):
                self?.completion(.failure(error))
            }
        }
    }
    
    func call3(data: String) {
        dp("third call")
        webservice.call3(data: data) { [weak self] result in
            self?.completion(result)
            self?.ongoinCall = .none
        }
    }
}

// MARK: - Call chain
extension DataGetter {
    enum CallChain {
        case call1
        case call2(data: String)
        case call3(data: String)
    }
}


final class SomeController_2 {
    
    private let dataGetter = DataGetter()
    
    func fetchData() {
        dataGetter(completion: updateView(_:))
    }
    
    // Process data
    func updateView(_ result: AppResult) {
        switch result {
            case .success(let message):
            print("Success: \(message)")
            case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
}


let controller = SomeController_2()
controller.fetchData()
dispatchMain()