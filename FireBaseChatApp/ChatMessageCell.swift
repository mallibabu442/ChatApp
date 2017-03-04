//
//  ChatMessageCell.swift
//  FireBaseChatApp
//
//  Created by MANOJ KUMAR on 06/01/17.
//  Copyright © 2017 MANOJ KUMAR. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController:ChatLogController??
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "MESSAGES RA OPEN"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        return tv
    }()
    
    static let blueColor = UIColor(r: 74, g: 173, b: 199)
    
    let bobbleView:UIView = {
        let view  = UIView()
        view.backgroundColor = blueColor 
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return view
        
    }()
    
    let profileImageView:UIImageView = {
        
        let profileimage   = UIImageView()
        profileimage.image = UIImage(named: "image")
        profileimage.translatesAutoresizingMaskIntoConstraints = false
        profileimage.layer.cornerRadius = 16
        profileimage.contentMode = .scaleAspectFill
        profileimage.layer.masksToBounds = true

        return profileimage
    }()
    
    lazy var messageImageView:UIImageView = {
        
        let imageView   = UIImageView()
        imageView.image = UIImage(named: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlTapZoom)))
        
        return imageView
    }()
    
    func handlTapZoom(tapGesture:UITapGestureRecognizer){
        
        
        if  let imageView = tapGesture.view as? UIImageView {
            self.chatLogController??.performZoomInForStartingImageView(imageView)

        }
    }
    
    
    var bobbleViewWidthAnchor:NSLayoutConstraint?
    var bobbleViewRigntAnchor:NSLayoutConstraint?
    var bobbleViewLeftAnchor:NSLayoutConstraint?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
       addSubview(bobbleView)
       addSubview(textView)
       addSubview(profileImageView)
        
       addSubview(messageImageView)
        
        //Constraints
        //Need x,y,w,h
        messageImageView.leftAnchor.constraint(equalTo: bobbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bobbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bobbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bobbleView.heightAnchor).isActive = true
        
        
        
        //Constraints
        //Need x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor,constant:8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        //Constraints
        //Need x,y,w,h
        
        
        bobbleViewRigntAnchor =  bobbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-8)
        
        bobbleViewRigntAnchor?.isActive = true
        
        bobbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bobbleViewWidthAnchor = bobbleView.widthAnchor.constraint(equalToConstant: 200)
        bobbleViewWidthAnchor?.isActive = true
        
        
        bobbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bobbleViewLeftAnchor = bobbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
       //Constraints
       //Need x,y,w,h
        
        textView.leftAnchor.constraint(equalTo:bobbleView.leftAnchor ,constant:8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bobbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
