//
//  ChatViewController.swift
//  Books Generator
//
//  Created by Mostafa Sami on 12/4/16.
//  Copyright © 2016 Sami. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Alamofire

class ChatViewController: JSQMessagesViewController {
    
    
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = ""
        self.inputToolbar.contentView.leftBarButtonItem = nil
        Alamofire.request(MainViewController.BASE_URL + MainViewController.WELCOME_URL).responseJSON { response in
            //to get JSON return value
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                self.senderId = JSON.object(forKey: "uuid") as! String!
                self.addMessage(withId: "chatbot", name: "Chatbot", text: JSON.object(forKey: "message") as! String)
                self.finishReceivingMessage()
            }
            
        }

        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.senderDisplayName = "Chatbot"
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.addMessage(withId: senderId, name: senderDisplayName, text: text)
        finishSendingMessage()
        let parameters: Parameters = ["message": text]
        let headers: HTTPHeaders = [
            "Authorization": senderId
        ]
        
        Alamofire.request(MainViewController.BASE_URL + MainViewController.CHAT_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            if let result = response.result.value {
                print(result)
                let JSON = result as! NSDictionary
                print(JSON.object(forKey: "message") as! String)
                self.addMessage(withId: "chatbot", name: "Chatbot", text: JSON.object(forKey: "message") as! String)
                self.finishReceivingMessage()
            }
        }
    }
}
