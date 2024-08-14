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

Similar to what I did here: [[23.12.03.Chaining closure based methods with enums]]
*/

// MARK: - Helpers
typealias AppResult<T> = Result<T, Error>
typealias AppCompletion<T> = (AppResult<T>) -> Void

typealias ProgressCallback = (Double) -> Void

/* 
Lets say we have a web service with three calls.
In our UI, we need to chain them because they each depend on
previous one:
*/
final class WebService {
    func call1(completion: @escaping AppCompletion<String>) {
        dp("Calling first method")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call1 data"))
        }
    }
    func call2(data: String, completion: @escaping AppCompletion<String>) {
        dp("Calling second method")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success("call2 data"))
        }
    }
    func call3(data: String, completion: @escaping AppCompletion<String>) {
        dp("Calling third method")
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
    
    func fetchData_1() {
        service.call1 { [weak self] result in
            switch result {
                case .success(let data):
                self?.service.call2(data: data) { result in
                    switch result {
                        case .success(let data):
                        self?.service.call3(data: data) { result  in
                            switch result {
                                case .success(let data):
                                    self?.handleSuccess(data)
                                case .failure(let error):
                                    self?.handleError(error)
                            }
                        }
                        case .failure(let error): 
                        self?.handleError(error)
                    }
                }
                case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    // View updating methods, in prod you want to trigger them on main thread
    func handleError(_ error: Error) {print(error.localizedDescription)}    
    func handleSuccess(_ data: String) { print("Success: \(data)") }
}

// This, as we can see, can become hard to read very quickly.

// Lets chain those calls using a custom operator, implementation taken from
// https://www.youtube.com/watch?v=DZlCTSr95DY
infix operator ~>: MultiplicationPrecedence
func ~> <T, U>(
    _ first: @escaping (@escaping AppCompletion<T>) -> Void, 
    _ second: @escaping (T, @escaping AppCompletion<U>) -> Void
) -> (@escaping AppCompletion<U>) -> Void {
    { completion in 
        first { result in
            switch result {
                case .success(let data): 
                    second(data, { result in
                        completion(result)
                    })
                case .failure(let error): completion(.failure(error))
            }
        }
    }
}

extension SomeController {
    func fetchData() {
        (service.call1 ~> service.call2 ~> service.call3) { [weak self] result in 
            switch result {
                case .success(let data): self?.handleSuccess(data)
                case .failure(let error): self?.handleError(error)
            }
        }
    }
}


let controller = SomeController()
controller.fetchData()
dispatchMain()