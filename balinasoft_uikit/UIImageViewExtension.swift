//
//  UIImageViewExtension.swift
//  balinasoft_uikit
//
//  Created by Artem Shuneyko on 6.05.23.
//

import Foundation
import UIKit

extension UIImageView {
    func imageFromURL(_ URLString: String?) {
        let image = UIImage(systemName: "photo")
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image?.draw(in: CGRect(origin: .zero, size: size))
        let placeHolder = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.image = placeHolder
        guard let URLString = URLString else { return }
        let imageServerUrl = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: imageServerUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let data = data else {
                    print(error?.localizedDescription ?? "Unknown error")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error: invalid response")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data) {
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}
