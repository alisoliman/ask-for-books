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
    
    // Array to hold Chat Messages
    var messages = [JSQMessage]()
    
    // Set colors for the chat bubbles
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChat()
        
        
        // Remove Avatars Icons
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Remove attachments button
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        }
    
    private func setupChat(){
        
        // REQUIRED: Initially Set Sender ID
        self.senderId = ""
        self.senderDisplayName = "User"
        
        // Initiate a request to get the uuid
        Alamofire.request(Constants.BASE_URL + Constants.WELCOME_URL).responseJSON { response in
            if let result = response.result.value {
                
                // Typecast result into Dictionary
                let JSON = result as! NSDictionary
                
                // Set actual senderId
                self.senderId = JSON.object(forKey: "uuid") as! String!
                
                // Add Initial Message to the messages array
                self.addMessage(withId: "chatbot", name: "Chatbot", text: JSON.object(forKey: "message") as! String)
                
                // Declare that we finished receiving messages to refresh the view
                self.finishReceivingMessage()
            }
            
        }

    }
    
    
    // MARK: JSQMessageViewController Delegate Methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    
    // MARK: Helper method to add message to the messages array
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    
    // MARK: Handle Send Button Pressed
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        // Add the message I just typed to the messages Array
        self.addMessage(withId: senderId, name: senderDisplayName, text: text)
        
        // Declare that I finished Sending the message to refresh the View
        finishSendingMessage()
        
        // API Handling
        let parameters: Parameters = ["message": text]
        let headers: HTTPHeaders = [
            "Authorization": senderId
        ]
        
        Alamofire.request(Constants.BASE_URL + Constants.CHAT_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                print(JSON.object(forKey: "message") as! String)
                self.addMessage(withId: "chatbot", name: "Chatbot", text: JSON.object(forKey: "message") as! String)
                self.finishReceivingMessage()
            }
        }
    }
    
    // MARK: Set Incoming/Outgoing Bubble colors
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
    }
}
