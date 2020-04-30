//
//  IdeasViewController.swift
//  Mindmeister TODO
//
//  Created by Alexander Novikov on 29.04.2020.
//  Copyright © 2020 novikovav. All rights reserved.
//

import UIKit

class IdeasViewController: UITableViewController {
    public static let SEGUE_SHOW_IDEAS = "showIdeas"
    let apiService = MMApiService.shared
    
    var numberOfSections: Int = 1
    var mapId: String?
    var mapIdeas: MapIdeas?
    var parentId: String? {
        didSet {
            if let parentId = parentId {
                self.parentId = parentId
                if let mapIdeas = self.mapIdeas {
                    if let ideas = mapIdeas.getIdeasByParentId(parentId: parentId) {
                        self.ideas = ideas
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    var ideas: [MapIdea] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.register(UINib(nibName: "IdeaTableViewCell", bundle: nil), forCellReuseIdentifier: "IdeaTableViewCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ideas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdeaTableViewCell", for: indexPath)
        guard let ideaCell = cell as? IdeaTableViewCell else {return cell}
        ideaCell.idea = self.ideas[indexPath[1]]
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        ideaCell.addGestureRecognizer(tapRecognizer)
        return ideaCell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        let idea = self.ideas[indexPath[1]]
        if (idea.icon == MapIdea.ICON_STATUS_OK) {
            let contextItem = UIContextualAction(style: .normal, title: "Mark as Undone") { (action, sourceView, completionHandler) in
                self.apiService.setIdeaIcon(mapId: self.mapId!, ideaId: idea.id!, icon: "") { (response) in
                    idea.icon = ""
                    DispatchQueue.main.async {
                        completionHandler(true)
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
            contextItem.backgroundColor = .red
            actions.append(contextItem)
        } else {
            let contextItem = UIContextualAction(style: .normal, title: "Mark as Done") { (action, sourceView, completionHandler) in
                self.apiService.setIdeaIcon(mapId: self.mapId!, ideaId: idea.id!, icon: MapIdea.ICON_STATUS_OK) { (response) in
                    idea.icon = MapIdea.ICON_STATUS_OK
                    DispatchQueue.main.async {
                        completionHandler(true)
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
            contextItem.backgroundColor = .green
            actions.append(contextItem)
        }
        
        return UISwipeActionsConfiguration(actions: actions)
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
            if let parentId = self.ideas[indexPath[1]].id {
                if let _ = self.mapIdeas?.getIdeasByParentId(parentId: parentId) {
                    self.performSegue(
                        withIdentifier: IdeasViewController.SEGUE_SHOW_IDEAS,
                        sender: IdeasViewControllerSender(mapId: self.mapId!, mapIdeas: self.mapIdeas!, parendId: parentId)
                    )
                }
            }
        }
    }
}
