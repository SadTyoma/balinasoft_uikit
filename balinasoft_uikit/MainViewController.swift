//
//  ViewController.swift
//  balinasoft_uikit
//
//  Created by Artem Shuneyko on 6.05.23.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var itemTableView: UITableView!
    
    private var selectedId = 0
    var items: [ListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTableView.delegate = self
        itemTableView.dataSource = self
        fetchItems()
    }
    
    private func fetchItems() {
        APIWrapper.shared.fetchItems { result in
            self.items.append(contentsOf: result)
            self.itemTableView.reloadData()
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemTableViewCell
        let item = items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.photoView.imageFromURL(item.image)
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = indexPath.row
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1 {
            fetchItems()
        }
    }
}

extension MainViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage {
            APIWrapper.shared.sendPhoto(id: selectedId, image: image)
        }
    }
}
