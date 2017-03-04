//
//  ViewController.swift
//  FireBaseChatApp
//
//  Created by MANOJ KUMAR on 03/01/17.
//  Copyright © 2017 MANOJ KUMAR. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessageController: UITableViewController {
    
    
    let cellId = "cellId"


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

     //Setup the LeftbarButtonItem
     navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(handleLogOut))
     navigationItem.leftBarButtonItem?.tintColor = UIColor(r: 74, g: 173, b: 199)
        
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(r: 74, g: 173, b: 199)

        
        checkIfUserIsLoggedIn()
        
        tableView.register(Usercell.self, forCellReuseIdentifier: cellId)

        
        
        
        
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()

    
    // MARK: - observeUserMessges
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)

        ref.observe(.childAdded, with:{ (snapshot) in
            
         let userID = snapshot.key
          
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.meessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func meessageWithMessageId(messageId:String) {
        
        let messageRef = FIRDatabase.database().reference().child("message").child(messageId)
        
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                message.setValuesForKeys(dictionary)
                // self.messages.append(message)
                
                if let chatPartnerId = message.chatPartnerId(){
                    self.messagesDictionary[chatPartnerId] = message
                }
               self.attemptReloadTable()
                
            }
            
        }, withCancel: nil)
        
    }
    
    private func attemptReloadTable() {
        
        self.timer?.invalidate()
        self.timer =  Timer.scheduledTimer(timeInterval: 0.1, target:self , selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer:Timer?
    
    func  handleReloadTable()
    {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })

        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
    
    
    
    // MARK: - Set the Statusbar colour.
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return.lightContent
    }

    
    
    // MARK: - UITableView Data&DelegateMethods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! Usercell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      let message = messages[indexPath.row]
     
        guard  let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        print(chatPartnerId)
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("Snapshot is ",snapshot)
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else{
                
                return
            }
            
            let user  = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatLogControllerForUser(user: user)
            
        }, withCancel: nil)
        
    }
    
    
    
    
    // MARK: - handleNewMessage()
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }

    // MARK: - checkIfUserIsLoggedIn()
    func checkIfUserIsLoggedIn()
    {
       
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        }else {
            
            fetchUserAndSetupNavBarTitle()

        }
        
        
    }

    // MARK: - fetchUserAndSetupNavBarTitle()
    func fetchUserAndSetupNavBarTitle()
    {
        guard  let uid = FIRAuth.auth()?.currentUser?.uid else{
            // for some reasons uid is nill
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //self.navigationItem.title = dictionary["name"] as? String
                

                let user = User()
                user.setValuesForKeys(dictionary)
                self.setUpNavBarWithUser(user: user)
                
            }
            
        }, withCancel: nil)

    }
    
    // MARK: - setUpNavBarWithUser
    func setUpNavBarWithUser(user: User) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        
        let profileImageView = UIImageView()
        profileImageView.layer.cornerRadius = 20
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if  let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        
        containerView.addSubview(profileImageView)

        
        //Constarins
        //need x,y,width,height
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true

        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        
        let titleLabel = UILabel()
        containerView.addSubview(titleLabel)

        titleLabel.text = user.name
        titleLabel.textColor = UIColor(r: 74, g: 173, b: 199)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        //Constarins
        //need x,y,width,height
        titleLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant:8).isActive = true

        titleLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true

        titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true

        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true


        //Constarins
        //need x,y,width,height
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        
        
        self.navigationItem.titleView = titleView
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatLogController)))

        
        

        
    }
    
    func showChatLogControllerForUser(user: User)
    {
        let chatLogController = ChatLogController(collectionViewLayout:UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    // MARK: - handleOut
    func handleLogOut(){
        
        
        do{
           try FIRAuth.auth()?.signOut()
            
        }catch let logError{
            print(logError)
        }
        
        let loginController  = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
        
    }
    


}

