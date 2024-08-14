import Foundation

func anyError() -> Error { NSError(domain: "", code: 0)}

extension Result {
	var data: Success? {
		switch self {
			case .success(let data): return data
			case .failure: return nil
		}
	}
}