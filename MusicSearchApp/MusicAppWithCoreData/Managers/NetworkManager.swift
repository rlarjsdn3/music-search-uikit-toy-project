//
//  NetworkManager.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/17.
//

import Foundation

// MARK: - API통신 과정에서 발생할 수 있는 에러 정의

enum NetworkError: Error {
    case networkError
    case dataError
    case parseError
}

// MARK: - API와 통신하는 클래스 모델

final class NetworkManager {
    
    // 싱글톤으로 구현
    static let shared = NetworkManager()
    private init() { }
    
    typealias NetworkCompletion = (Result<[Music], NetworkError>) -> Void
    
    // 주어진 검색어를 가지고 음악 데이터를 요청하는 함수(비동기)
    func fetchMusic(searchTerm: String, completionHandler: @escaping NetworkCompletion) {
        // 요청을 위한 Url을 만들기
        let urlString = "\(MusicApi.requestUrl)\(MusicApi.mdediaParam)&term=\(searchTerm)"
        // 만든 Url로 API에 데이터 요청하기
        performRequest(with: urlString) { result in
            completionHandler(result)
        }
    }
    
    // 실제 API로 데이터를 요청하는 함수(비동기)
    private func performRequest(with urlString: String, completionHandler: @escaping NetworkCompletion) {
        print(#function)
        // 유효한 주소인지 검사
        guard let url = URL(string: urlString) else { return }
        // 새로운 세션 생성하기
        let session = URLSession.shared
        // 세션에 작업 할당하기
        let task = session.dataTask(with: url) { (data, response, error) in
            // 에러가 발생하였다면
            guard error == nil else {
                completionHandler(.failure(.networkError))
                return
            }
            // 상태 코드가 200번대가 아니라면
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300) ~= statusCode else {
                print((response as? HTTPURLResponse)?.statusCode)
                completionHandler(.failure(.networkError))
                return
            }
            // 받은 데이터가 유효하지 않다면
            guard let safeData = data else {
                completionHandler(.failure(.dataError))
                return
            }
            // JSON 디코드에 성공한다면
            if let parsedData = self.decode(of: MusicData.self, data: safeData) {
                completionHandler(.success(parsedData.results))
                return
            // JSON 디코드에 실패한다면
            } else {
                completionHandler(.failure(.parseError))
                return
            }
        }
        // 할당된 작업 시작하기
        task.resume()
    }
    
    // 받아온 JSON을 구조체로 디코드하는 함수
    private func decode<T: Codable>(of type: T.Type, data: Data) -> T? {
        do {
            let decoder = JSONDecoder()
            let parsedData = try decoder.decode(type, from: data)
            return parsedData
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
