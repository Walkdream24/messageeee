//
//  Message.swift
//  messageeee
//
//  Created by 中重歩夢 on 2018/10/06.
//  Copyright © 2018年 Ayumu Nakashige. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MessageKit

private struct MockLocationItem: LocationItem {
    var location: CLLocation
    
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }

}

private struct MockMediaItem: MediaItem {
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    var url: URL?
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}

struct MockMessage: MessageType {
    
    var sender: Sender
    
    var messageId: String = ""
    
    var sentDate: Date
    
    var kind: MessageKind
    
    init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    init(text: String, sender: Sender, messageId: String, date: Date) {
        
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
        
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        
        let mediaItem = MockMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date) {
        
        let mediaItem = MockMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    init(location: CLLocation, sender: Sender, messageId: String, date: Date) {
        
        let locationItem = MockLocationItem(location: location)
        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date) {
        
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
    }
    
    
}
