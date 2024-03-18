//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Lwazi M on 3/17/24.
//

import Foundation

class TriviaQuestionService {
    func fetchTriviaQuestions(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        let apiUrl = "https://opentdb.com/api.php?amount=10"
        
        guard let url = URL(string: apiUrl) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(nil, NSError(domain: "Invalid HTTP response", code: 0, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let results = jsonObject?["results"] as? [[String: Any]] {
                    completion(results, nil)
                } else {
                    completion(nil, NSError(domain: "Invalid JSON format", code: 0, userInfo: nil))
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
