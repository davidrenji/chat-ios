//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

// MARK: - UIViewController
// MARK: -
class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = Constants.appName
        
        messageTextfield.delegate = self
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadMessages()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        sendMessageAction()
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print(error)
        }
    }
    
    func loadMessages() {
        //We add a listener to any change in the document
        db.collection(Constants.FStore.collectionName)
            .order(by: Constants.FStore.dateField)
            .addSnapshotListener { (data, error) in
            self.messages = []
            if let e = error {
                print(e.localizedDescription)
            } else {
                if let documents = data?.documents {
                    for document in documents {
                        if let sender: String = document.data()[Constants.FStore.senderField] as? String,
                           let body: String = document.data()[Constants.FStore.bodyField] as? String {
                            //Let's create the message
                            let message: Message = Message(sender: sender, body: body)
                            self.messages.append(message)
                        }
                    }
                    self.reloadTableView()
                }
            }
        }
    }
    
    func reloadTableView() {
        //Good practice to use the queue when updating the ui in a closure
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: !self.firstLoad)
            self.firstLoad = false
        }
    }
    
    func sendMessageAction(){
        if let messageBody = messageTextfield.text, let currentuser = Auth.auth().currentUser?.email {
            let dataToSend: [String : Any] = [
                Constants.FStore.dateField: Date().timeIntervalSince1970,
                Constants.FStore.senderField: currentuser,
                Constants.FStore.bodyField: messageBody
            ]
            db.collection(Constants.FStore.collectionName).addDocument(data: dataToSend) { (error) in
                if let e = error {
                    print("Error: \(e.localizedDescription)")
                } else {
                    print("Data saved! YEAH!!")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                    
                }
            }
        }
    }
    
}

//MARK: - UITableViewDataSource extension -

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        let sender =  message.sender
        
        if (sender == Auth.auth().currentUser?.email){
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBuble.backgroundColor = UIColor(named: Constants.BrandColors.purple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.lightPurple)
        } else {
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            cell.messageBuble.backgroundColor = UIColor(named: Constants.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: Constants.BrandColors.purple)
        }
        
        return cell
    }
    
    
}

//MARK: - UITextFieldDelegate extension
// MARK: -
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendMessageAction()
        return true
    }
}
