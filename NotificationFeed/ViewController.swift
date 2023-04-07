//
//  ViewController.swift
//  NotificationFeed
//
//  Created by Long Tran on 30/03/2023.
//

import UIKit

struct NotiImage {
    let id: String
    let userImage: UIImageView
    let iconImage: UIImageView
    let status: UIColor
}

class ViewController: UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var exitSearchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var notiData: Notis!
    var data: [Noti] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.isHidden = true
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.placeholder = "Tìm kiếm"
        readJSONFile(forName: "noti")
        data = notiData.data
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemGray6
        searchBar.delegate = self
    }

    @IBAction func tapSearchButton(_ sender: Any) {
        searchView.isHidden = false
        searchBar.becomeFirstResponder()
        data = []
        tableView.reloadData()
    }
    
    @IBAction func tapExitSearchButton(_ sender: Any) {
        searchView.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
        data = notiData.data
        tableView.reloadData()
    }
    
    func readJSONFile(forName name: String) {
       do {
          if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
          let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
              let decoder = JSONDecoder()
              notiData = try decoder.decode(Notis.self, from: jsonData)
          }
       } catch {
          print(error)
       }
    }
    
    func checkDataSearch(id: String) -> Bool {
        for item in data {
            if(item.id == id) {
                return false
            }
        }
        return true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        if searchView.isHidden {
            cell.setupCell(data: data[indexPath.row])
        }
        else {
            cell.setupResultSearchCell(data: data[indexPath.row], searchText: searchBar.text ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        data = []
        for itemData in notiData.data {
            for itemSearchText in searchText.split(separator: " ") {
                if(itemData.message.text.lowercased().folded.contains(itemSearchText.lowercased().folded)) {
                    if(checkDataSearch(id: itemData.id)) {
                        data.append(itemData)
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
}

extension String {
    //Reference https://stackoverflow.com/questions/16836975/ios-cfstringtransform-and-%C4%90
    var folded: String {
        return self.folding(options: .diacriticInsensitive, locale: nil)
                .replacingOccurrences(of: "đ", with: "d")
                .replacingOccurrences(of: "Đ", with: "D")
    }
    
}

extension UIColor {
    public static let customColor = UIColor(red: 0.23, green: 0.71, blue: 0.48, alpha: 1.00)
}
