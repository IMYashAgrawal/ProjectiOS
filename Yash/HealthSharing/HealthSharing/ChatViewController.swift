//
//  ChatViewController.swift
//  HealthSharing
//
//  Created by GEU on 06/02/26.
//

import UIKit

class ChatViewController: UIViewController {
    
    var otherUserId: Int!
    var currentUserId: Int!
    var messages: [Message] = []
    var chatItems: [ChatItem] = []

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var newMessageTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.register(UINib(nibName: "SentMessageCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "sent_message_cell")
        collectionView.register(UINib(nibName: "ReceivedMessageCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "received_message_cell")
        collectionView.register(UINib(nibName: "DateHeaderCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "date_header_cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        newMessageTextView.delegate = self

        title = displayName(for: otherUserId)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 8
        }
        
        newMessageAreaSetUp()
        
        loadMessages()
        buildChatItems(from: messages)
        collectionView.reloadData()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        newMessageTextView.text = ""
        sendButton.isEnabled = false
        sendButton.alpha = 0.4
    }
    
    func newMessageAreaSetUp() {
        newMessageTextView.isScrollEnabled = true
        newMessageTextView.textContainer.lineBreakMode = .byWordWrapping
        newMessageTextView.textContainer.maximumNumberOfLines = 0
        newMessageTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        
        newMessageTextView.layer.cornerRadius = 16
        newMessageTextView.layer.borderWidth = 1
        newMessageTextView.layer.borderColor = UIColor.systemGray4.cgColor
        
        newMessageTextView.text = "Type your message here"
        
        sendButton.layer.cornerRadius = 16
        sendButton.isEnabled = false
    }
    
    func loadMessages() {
        messages = DataManager.shared.messages
            .filter {
                ($0.senderId == currentUserId && $0.receiverId == otherUserId) ||
                ($0.senderId == otherUserId && $0.receiverId == currentUserId)
            }
            .sorted { $0.timestampUTC < $1.timestampUTC }

        buildChatItems(from: messages)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom(animated: false)
    }

    func scrollToBottom(animated: Bool = false) {
        collectionView.layoutIfNeeded()

        let section = 0
        let itemCount = collectionView.numberOfItems(inSection: section)
        guard itemCount > 0 else { return }

        let indexPath = IndexPath(item: itemCount - 1, section: section)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }


    func displayName(for userId: Int) -> String {
        let dm = DataManager.shared

        if let profile = dm.allProfiles.first(where: { $0.profileId == userId }) {
            return profile.nickName ?? profile.firstName
        }

        if let user = dm.currentUser, user.profileId == userId {
            return user.nickName ?? user.firstName
        }

        return "User"
    }
    
    enum ChatItem {
        case dateHeader(String)
        case message(Message)
    }
    
    func buildChatItems(from messages: [Message]) {
        chatItems.removeAll()

        let calendar = Calendar.current

        let sortedMessages = messages.sorted {
            $0.timestampUTC < $1.timestampUTC
        }

        var lastDate: Date?

        for message in sortedMessages {
            let messageDate = calendar.startOfDay(for: message.timestampUTC)

            if lastDate == nil || messageDate != lastDate {
                let title = formattedDateTitle(for: message.timestampUTC)
                chatItems.append(.dateHeader(title))
                lastDate = messageDate
            }

            chatItems.append(.message(message))
        }
    }
    
    func formattedDateTitle(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        }
        
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type your message here" {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Type your message here"
            textView.textColor = .lightGray
            sendButton.isEnabled = false
            sendButton.alpha = 0.4
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let hasRealText =
            textView.text != "Type your message here" &&
            !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        sendButton.isEnabled = hasRealText
        sendButton.alpha = hasRealText ? 1.0 : 0.4
    }

}

extension ChatViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return chatItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = chatItems[indexPath.item]

        switch item {

        case .dateHeader(let title):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "date_header_cell",for: indexPath) as! DateHeaderCollectionViewCell
            cell.configure(title: title)
            return cell

        case .message(let message):
            if message.senderId == currentUserId {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sent_message_cell",for: indexPath) as! SentMessageCollectionViewCell
                cell.configure(with: message)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "received_message_cell",for: indexPath) as! ReceivedMessageCollectionViewCell
                cell.configure(with: message)
                return cell
            }
        }
    }

}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = chatItems[indexPath.item]
        
        switch item {
        case .dateHeader(_):
            return CGSize(width: collectionView.bounds.width, height: 40)
            
        case .message(let message):
            let maxWidth = collectionView.bounds.width * 0.75
            let padding: CGFloat = 16 // left + right padding inside bubble
            let verticalPadding: CGFloat = 26 // top + bottom + time label
            
            // Calculate text height
            let textWidth = maxWidth - padding - 24 // 24 for cell margins
            let font = UIFont.systemFont(ofSize: 17) // Match your label font
            
            let textHeight = message.message.height(
                withConstrainedWidth: textWidth,
                font: font
            )
            
            return CGSize(
                width: collectionView.bounds.width,
                height: textHeight + verticalPadding + 8 // 8 for cell top/bottom
            )
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
