//
//  ViewController.swift
//  messageeee
//
//  Created by 中重歩夢 on 2018/10/06.
//  Copyright © 2018年 Ayumu Nakashige. All rights reserved.
//

import UIKit
import MessageKit
import Firebase


class ViewController: MessagesViewController {
    
    var messageList:[MockMessage] = []
    var db: Firestore!
    var realtimedb: DatabaseReference!
    var sender: Sender!
    var sender1: Sender!
    var contentsArray = [String:Any]()
    var uid1:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        realtimedb = Database.database().reference()
        if let uid = Auth.auth().currentUser?.uid {
            uid1 = uid
            db.collection("users").document(uid).getDocument { (snap, error) in
                if let error = error {
                    print(error.localizedDescription)
                }else{
                    let data = snap?.data()
                    self.sender = Sender(id: uid, displayName: data!["name"]as! String)
                    self.realtimedb.ref.child("message").observe(.value){ (snap) in
                        self.messageList = [MockMessage]()
                        for item in snap.children {
                            let child = item as! DataSnapshot
                            let dic = child.value as! NSDictionary
                            let attributedText = NSAttributedString(string:dic["text"] as! String, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                            self.sender1 = Sender(id: dic["senderID"] as! String, displayName: dic["senderName"]as! String)
                            let message = MockMessage(attributedText: attributedText, sender: self.sender1, messageId: UUID().uuidString, date: Date())
                            self.messageList.append(message)
                        }
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            }
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
extension ViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section & 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    
    }
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter
            } ()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateStirng = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateStirng, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}
extension ViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white: .darkText
        
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
        UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
        UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ?
        .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(image: nil, initials: message.sender.displayName)
        avatarView.set(avatar: avatar)
    }
}
extension ViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}
extension ViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for componet in inputBar.inputTextView.components {
            if let image = componet as? UIImage {
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
            }else if let text = componet as? String {
                print(text)
                contentsArray = ["text":text,"senderID": uid1, "senderName": self.sender.displayName]
                realtimedb.ref.child("message").childByAutoId().setValue(contentsArray)
                let attributedText = NSAttributedString(string: text, attributes: [.font:UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
