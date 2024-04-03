//
//  SuccessViewController.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 27/03/24.
//

import UIKit

class SuccessViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backupButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var signInSuccess: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.signInSuccess.text = "Signed In as: \(AccountViewModel.shared.currentUser.email!)"
        self.signInSuccess.numberOfLines = 2
        self.signInSuccess.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.reloadData()
    }
    
    @IBAction func signOut() {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.resetLazyContainer()
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
        UserDefaults.standard.synchronize()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backup(_ sender: UIButton) {
        LocalDatabaseManager.backup { success in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        LocalDatabaseManager.reset { flag in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dbUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dbUrls[indexPath.row].lastPathComponent
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Backup List\n"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .normal, title: "Restore", handler: { [weak self] action, view ,_ in
            guard let url = self?.dbUrls[indexPath.row] else { return }
            LocalDatabaseManager.restoreFromStore(url: url) { success in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
        let action2 = UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] action, view ,_ in
            guard let fileUrl = self?.dbUrls[indexPath.row] else { return }
            guard let urls = self?.dbSupportUrls(fileUrl) else { return }
            urls.forEach { url in
                try? FileManager.default.removeItem(at: url)
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
        let action = UISwipeActionsConfiguration(actions: [action1, action2])
        return action
    }
    var fileURLs: [URL] {
        let fm = FileManager.default
        guard let folder = AccountViewModel.shared.currentUser.email else { return [] }
        let folderUrl = URL(fileURLWithPath: docDirectory).appending(path: folder)
        let contents = (try? fm.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: [])) ?? []
        return contents
    }
    
    var dbUrls: [URL] {
        let urls = fileURLs.filter({ $0.pathExtension == "sqlite" }).sorted { url1, url2 in
            let attr1 = try? FileManager.default.attributesOfItem(atPath: url1.path())
            let attr2 = try? FileManager.default.attributesOfItem(atPath: url2.path())
            let date1 = attr1?[FileAttributeKey.creationDate] as? Date
            let date2 = attr2?[FileAttributeKey.creationDate] as? Date
            return date1?.compare(date2 ?? Date()) == .orderedDescending
        }
        return urls
    }
    func dbSupportUrls(_ forUrl: URL) -> [URL] {
        var url = forUrl
        return fileURLs.filter({ url.pathExtension.contains("sqlite") && $0.deletingPathExtension() == url.deletingPathExtension() })
    }
}

extension SuccessViewController {
    var docDirectory: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }
}
