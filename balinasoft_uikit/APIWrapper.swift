//
//  APIWrapper.swift
//  balinasoft_uikit
//
//  Created by Artem Shuneyko on 6.05.23.
//

import Foundation
import UIKit

final class APIWrapper {
    static let shared = APIWrapper()
    
    private let baseUrl = "https://junior.balinasoft.com/api/v2"
    private let name = "Shuneyko Artyom Vadimovich"
    private var currentPage = 0
    private var totalPages = 0

    private init(){}
    
    func fetchItems(complition: @escaping ([ListItem])->Void) {
        guard currentPage < totalPages || currentPage == 0 else { return }
        
        let url = URL(string: "\(baseUrl)/photo/type?page=\(currentPage)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(APIResult.self, from: data)
                self.currentPage += 1
                self.totalPages = result.totalPages
                DispatchQueue.main.async {
                    complition(result.content)
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func sendPhoto(id: Int, image: UIImage){
        let url = URL(string: "\(baseUrl)/photo")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "accept")

        let imageData = image.jpegData(compressionQuality: 1.0)!
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(name)\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(id)\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(name).jpeg\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: invalid response")
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let id = json?["id"] as? String {
                        print("Successfully uploaded photo with ID: \(id)")
                    } else {
                        print("Error: invalid response")
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                print("Error: invalid response")
            }
        }
        task.resume()
    }
}
