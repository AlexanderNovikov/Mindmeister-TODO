//
//  MapsViewController.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 14.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import UIKit

class MapsViewController: UITableViewController {
    public static let SEGUE_SHOW_MAPS = "showMaps"
    let apiService = MMApiService.shared
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var numberOfSections: Int = 1
    var maps: [MapListMap] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.register(UINib(nibName: "MapTableViewCell", bundle: nil), forCellReuseIdentifier: "MapTableViewCell")
        self.tableView.backgroundView = self.activityIndicator
        
        self.tableView.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        self.apiService.getMapList { (response) in
            self.maps.append(contentsOf: response)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.maps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath)
        guard let mapCell = cell as? MapTableViewCell else {return cell}
        mapCell.map = self.maps[indexPath[1]]
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        mapCell.addGestureRecognizer(tapRecognizer)
        return mapCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if (destination is IdeasViewController) {
            let ideasView = destination as? IdeasViewController
            let ideasSender = sender as? IdeasViewControllerSender
            ideasView?.mapId = ideasSender?.mapId
            ideasView?.mapIdeas = ideasSender?.mapIdeas
            ideasView?.parentId = ideasSender?.parentId
        }
    }
    
    @objc private func tapGesture(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: tapLocation) {
            if let mapId = self.maps[indexPath[1]].id {
                self.tableView.isUserInteractionEnabled = false
                self.activityIndicator.startAnimating()
                self.apiService.getMap(mapId: mapId) { (response) in
                    DispatchQueue.main.async {
                        self.tableView.isUserInteractionEnabled = true
                        self.activityIndicator.stopAnimating()
                        self.performSegue(
                            withIdentifier: IdeasViewController.SEGUE_SHOW_IDEAS,
                            sender: IdeasViewControllerSender(mapId: mapId, mapIdeas: response.ideas!, parendId: mapId)
                        )
                    }
                }
            }
        }
    }
}
