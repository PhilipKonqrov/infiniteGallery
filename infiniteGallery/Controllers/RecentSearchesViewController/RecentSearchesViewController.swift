//
//  RecentSearchesViewController.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 28.03.22.
//

import UIKit

// MARK: - Notifications

extension Notification.Name {
    static let recentSearchTapped = Notification.Name("recentSearchTappedNotification")
}

// MARK: - Class Definition

class RecentSearchesViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var recentSearches: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRecentSearches()
    }
    
    private func setupUI() {
        title = "Recent searches"
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearRecentSearches))
    }
    
    @objc private func clearRecentSearches() {
        recentSearches = []
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: .recentSearchesDirectory(), includingPropertiesForKeys: nil)
            for url in fileURLs { try FileManager.default.removeItem(at: url) }
        } catch {
            print("Error deleting recent searches:: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    private func loadRecentSearches() {
        recentSearches = []
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: .recentSearchesDirectory(), includingPropertiesForKeys: nil)
            for url in fileURLs {
                let data = try Data(contentsOf: url)
                if let recentSearchString = String(data: data, encoding: .utf8) {
                    recentSearches.append(recentSearchString)
                }
            }
        } catch { print("Error while loading recent searches: \(error.localizedDescription)") }
        tableView.reloadData()
    }
}

// MARK: - CollectionView Delegate methods

extension RecentSearchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchesCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.backgroundColor = .black
        content.text = recentSearches[indexPath.row]
        content.textProperties.color = .white
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard recentSearches.indices.contains(indexPath.row) else { return }
        NotificationCenter.default.post(name: .recentSearchTapped, object: recentSearches[indexPath.row])
        
        tabBarController?.selectedIndex = 0 // Switch to HomeVC
    }
}
