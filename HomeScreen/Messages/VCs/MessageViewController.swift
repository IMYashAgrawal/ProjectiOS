//
//  MessageViewController.swift
//  HealthSharing
//
//  Created by GEU on 02/02/26.
//

import UIKit

class MessageViewController: UIViewController {
    
    var allMessages: [Message] = []
    var lastMessagesPerPerson: [Message] = []
    var currentUserId: Int?

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allMessages = DataManager.shared.messages
        currentUserId = DataManager.shared.currentUser?.profileId

        buildLastMessagesPerPerson()
//        setupProfileButton()
        title = "Message"
        
        collectionView.register(UINib(nibName: "MessageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "message_cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        allMessages = DataManager.shared.messages
        currentUserId = DataManager.shared.currentUser?.profileId

        buildLastMessagesPerPerson()
    }
    
    func buildLastMessagesPerPerson() {

        var dict: [Int: Message] = [:]

        for message in allMessages {

            let otherUserId = message.senderId == currentUserId ? message.receiverId : message.senderId

            if let existing = dict[otherUserId] {
                if message.timestampUTC > existing.timestampUTC {
                    dict[otherUserId] = message
                }
            } else {
                dict[otherUserId] = message
            }
        }

        lastMessagesPerPerson = Array(dict.values).sorted { $0.timestampUTC > $1.timestampUTC }

        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard segue.identifier == "showChatSegue",
              let indexPath = sender as? IndexPath,
              let chatVC = segue.destination as? ChatViewController,
              let currentUserId = currentUserId else {
            return
        }

        let message = lastMessagesPerPerson[indexPath.item]

        let otherUserId =
            message.senderId == currentUserId
            ? message.receiverId
            : message.senderId

        chatVC.otherUserId = otherUserId
        chatVC.currentUserId = currentUserId
    }



}


extension MessageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lastMessagesPerPerson.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "message_cell",
            for: indexPath
        ) as! MessageCollectionViewCell

        let message = lastMessagesPerPerson[indexPath.item]
        cell.configure(with: message, currentUserId: currentUserId)

        return cell
    }
}

extension MessageViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(
            width: collectionView.bounds.width,
            height: 72
        )
    }
}

extension MessageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        performSegue(withIdentifier: "showChatSegue", sender: indexPath)
    }
}

