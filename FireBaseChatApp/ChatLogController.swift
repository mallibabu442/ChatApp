//
//  ChatLogController.swift
//  FireBaseChatApp
//
//  Created by MANOJ KUMAR on 05/01/17.
//  Copyright © 2017 MANOJ KUMAR. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage


class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    let cellID = "cellID"
    
    var user:User?{
        didSet{
            navigationItem.title = user?.name
            //navigationItem.leftBarButtonItem?.tintColor = UIColor(r: 74, g: 173, b: 199)
           // navigationController?.navigationBar.tintColor = UIColor(r: 74, g: 173, b: 199)
  
            

            
            observeMessages()
        }
    }
    
    
    var messages = [Message]()
    
    func observeMessages(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid,let toId = user?.id else {
            return
        }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        
        userMessageRef.observe(.childAdded, with: {
            (snapshot) in
            print(snapshot)
            
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("message").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: {
                (snapshot) in
        
                
             guard  let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                //let message = Message()
                //Potential crashing if key's don't match
                
                
                //do we need attempt filtering anymore?
                self.messages.append(Message(dictionary:dictionary))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }

                
            
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        

        
    }
    
    lazy var inputTextField:UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Enter message......"
        tf.tintColor = UIColor(r: 74, g: 173, b: 199)
        
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
        
    }()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset  = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
       // collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 52, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.keyboardDismissMode = .interactive
        
        //To set the colour for Backbarbuton title colour.
        self.navigationController?.navigationBar.tintColor = UIColor(r: 74, g: 173, b: 199)
        //To set the colour for NavigationTitle title colour.

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(r: 74, g: 173, b: 199)]

        
        //setUpInputComponents()
    }
    
    
    
    lazy var inputContainerView:UIView = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.tintColor = UIColor(r: 74, g: 173, b: 199)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        containerView.addSubview(sendButton)
        
        //Constraints
        //Need x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor ,constant: -8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        
        
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        //Constarints
        //Need x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        
        //Constarints
        //Need x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo:uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let sepratorView = UIView()
        sepratorView.backgroundColor = UIColor.black
        sepratorView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(sepratorView)
        
        //Constant
        //Need x,y,w,h
        sepratorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        sepratorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sepratorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        sepratorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
        return containerView
        
        
    }()
    
    
    func handleUploadTap(){
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
        
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
    }
        
  }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    
    func setUpKeyBoardObserves()  {
        
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -(keyboardFrame?.height)!
        
        UIView.animate(withDuration: keyboardDuration!, animations:{
            
            self.view.layoutIfNeeded()
        })
        
    }
    
    func handleKeyboardWillHide(notification:NSNotification) {
        containerViewBottomAnchor?.constant = 0
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        UIView.animate(withDuration: keyboardDuration!, animations:{
            
            self.view.layoutIfNeeded()
        })
        
    }
    
    
   // MARK: - UIImagePickerView Delegate Methods.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editImage = info["UIImagePickerControllerOriginalImage" ] as? UIImage {
            
            selectedImageFromPicker = editImage
            
        }else if let originalImage = info["UIImagePickerControllerEditImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectImage = selectedImageFromPicker{
            
            //profileImage.image = selectImage
            
            uploadToFirebaseStorageUsingImage(image:selectImage)
        }
        
        dismiss(animated: true, completion: nil)
        
        print(info)
    }
    
    private func uploadToFirebaseStorageUsingImage(image:UIImage){
        
        let imagename = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message-Image").child(imagename)
        if let uploadData = UIImageJPEGRepresentation(image, 0.1){
        
            ref.put(uploadData, metadata: nil, completion: {(metadata, error) in
                
                if error != nil{
                    
                    return
                }
                
               if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                self.sendMessageWithImageUrl(imageurl: imageUrl, Image: image)
                    
                }

               // print(metadata?.downloadURL()?.absoluteString)
            
            })
            
        }
    }
    
    private func sendMessageWithImageUrl(imageurl:String ,Image:UIImage) {
        
        
        let ref = FIRDatabase.database().reference().child("message")
        let childRef = ref.childByAutoId()
        //is it there best thing to include the name inside of the message node
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["imageUrl": imageurl, "toId": toId, "fromId": fromId,"timestamp":timeStamp,"imageWidth":Image.size.width,"imageHeight":Image.size.height] as [String : Any]
        //childRef.updateChildValues(values)
        
        
        childRef.updateChildValues((values), withCompletionBlock: {(error,ref) in
            
            if  error != nil {
                print(error)
                return
            }
            
            self.inputTextField.text  = nil
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId:1])
            
            
            let recipintUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipintUserMessageRef.updateChildValues([messageId:1])
            
            
            
        })
        

        
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
   // MARK: - UICollectionView Data & DelegateMethods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        
      
        cell.chatLogController = self
        
        setUpCell(cell: cell, message: message)
        
        if let text = message.text {
            //a text message
            cell.bobbleViewWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            //fall in here if its an image message
            cell.bobbleViewWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        
        
        return cell
    }
    
    
    private func setUpCell(cell:ChatMessageCell,message:Message){
        
        if let profilrImageUrl = self.user?.profileImageUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(profilrImageUrl)
        }
        
        
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //Outgoing
            cell.bobbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bobbleViewRigntAnchor?.isActive = true
            cell.bobbleViewLeftAnchor?.isActive = false

            
        }else{
            //Incoming
            cell.bobbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bobbleViewRigntAnchor?.isActive = false
            cell.bobbleViewLeftAnchor?.isActive = true
            

        }
        
        if let imageUrl = message.imageUrl {
            
            cell.messageImageView.loadImageUsingCacheWithUrlString(imageUrl)
            cell.messageImageView.isHidden = false
            cell.bobbleView.isHidden = true
            
        }else{
            cell.messageImageView.isHidden = true
            
            
        }


    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        //get estimated height for text somehow???
        let message = messages[indexPath.item]
        if let text = message.text {
            
            height = estimateFrameForText(text: text).height + 40
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = 123
            
           // h1/w1 = h2/w2
           // Solve for h1
           
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    private func estimateFrameForText(text:String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttachmentAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
        
        
    }
    
    
    var containerViewBottomAnchor:NSLayoutConstraint?

    
    
    func handleSend()
    {
        let ref = FIRDatabase.database().reference().child("message")
        let childRef = ref.childByAutoId()
        //is it there best thing to include the name inside of the message node
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId,"timestamp":timeStamp] as [String : Any]
        //childRef.updateChildValues(values)
        
        
        childRef.updateChildValues((values), withCompletionBlock: {(error,ref) in
            
          if  error != nil {
                print(error)
               return
            }
            
            self.inputTextField.text  = nil
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId:1])
            
            
            let recipintUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipintUserMessageRef.updateChildValues([messageId:1])
        
        
        
        })
        
        
        
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // MARK: -  My custom zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    
    // MARK: -  My custom zoom Out logic
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }

}
