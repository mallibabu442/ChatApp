//
//  LoginController.swift
//  FireBaseChatApp
//
//  Created by MANOJ KUMAR on 03/01/17.
//  Copyright © 2017 MANOJ KUMAR. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class LoginController: UIViewController {

    
    var messageController:MessageController?
    
    // MARK: - ContainerView
    let inputContainerViews:UIView = {

      let view = UIView()
      view.backgroundColor = UIColor.white
      view.layer.cornerRadius = 5
      view.layer.masksToBounds = true
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
        
    }()
    
    
   // MARK: - LOGIN & REGISTER BUTTON
   lazy var loginRegisterButton:UIButton = {
        
        let button = UIButton(type:.system)
        button.backgroundColor = UIColor(r: 74, g: 190, b: 200)
        button.setTitle("Register", for:.normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
       
        return button
    }()
    
    
    
    func handleLoginRegister(){
        
        if loginRegisterSegmentedController.selectedSegmentIndex == 0{
            handleLogin()
        }else {
            handleRegister()
        }
        
    }
    
    
    // MARK: - Login Button Action
    func handleLogin() {
        
       guard let email = emailTexField.text , let password = passwordTexField.text else {
            print("Form is not Valid")
            return
        }
        
       FIRAuth.auth()?.signIn(withEmail: email,password:password, completion: {(user,erro) in
    
         if erro != nil
            {
                print(erro)
                return
            }
            
            //Successfully logged in our user
            self.messageController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    
    // MARK: - Register Button Action

    
    // MARK: - nameTexField
    let nameTexField:UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.textColor = UIColor(r: 74, g: 173, b: 199)

        tf.tintColor = UIColor(r: 74, g: 173, b: 199)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // MARK: - nameSeparatorView

    let nameSeparatorView:UIView = {
       let separator = UIView()
       separator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
       separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
        
    }()
    
    // MARK: - emailTextField
    let emailTexField:UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.tintColor = UIColor(r: 74, g: 173, b: 199)
        tf.textColor = UIColor(r: 74, g: 173, b: 199)


        tf.isSecureTextEntry  = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // MARK: - emailSeparatorView
    let emailSeparatorView:UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
        
    }()
    
    // MARK: - passwordTextField
    let passwordTexField:UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.tintColor = UIColor(r: 74, g: 173, b: 199)
        tf.textColor = UIColor(r: 74, g: 173, b: 199)


        tf.isSecureTextEntry  = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

  
    // MARK: - profileImage
    lazy var profileImage:UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile-Image")
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    
    // MARK: - SegmentController
    lazy var loginRegisterSegmentedController:UISegmentedControl = {
        let sc = UISegmentedControl(items:["Login","Register"])
        sc.tintColor = UIColor.white
    
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        
        sc.addTarget(self, action:#selector(handleLoginRegisterChange), for: .valueChanged)

    
        return sc
    
    }()
    
    // MARK: - SegmentController Action
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedController.titleForSegment(at: (loginRegisterSegmentedController.selectedSegmentIndex))
        
      loginRegisterButton.setTitle(title, for: .normal)
        
      //Change the height of inputContainerView
        inputContainerViewHeightConstraint?.constant = loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 99 : 150
        
        
       //Change the height of nametextfield
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTexField.heightAnchor.constraint(equalTo: inputContainerViews.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 0 : 1/3)

        
        if loginRegisterSegmentedController.selectedSegmentIndex == 0 {
            nameTexField.placeholder = nil
        }else{
            nameTexField.placeholder = "Name"
        }
        
        
        
        nameTextFieldHeightAnchor?.isActive = true
        
        
        //Change the height of emailTexField

        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTexField.heightAnchor.constraint(equalTo: inputContainerViews.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        
        //Change the height of passwordTexField

        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTexField.heightAnchor.constraint(equalTo: inputContainerViews.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        
        passwordTextFieldHeightAnchor?.isActive = true

        

        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       view.backgroundColor = UIColor(r: 74, g: 173, b: 199)
       view.addSubview(inputContainerViews)
       view.addSubview(loginRegisterButton)
       view.addSubview(profileImage)
       view.addSubview(loginRegisterSegmentedController)
    
       setupInputContainerView()
       setupLoginRegisterButton()
       setupLoginRegisterSegment()
        
    }
    
    // MARK: - Set the Statusbar colour.
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return.lightContent
    }
    
    
    
    
    // MARK: - Constrains for ContainerView
    var inputContainerViewHeightConstraint:NSLayoutConstraint?
    var nameTextFieldHeightAnchor:NSLayoutConstraint?
    var emailTextFieldHeightAnchor:NSLayoutConstraint?
    var passwordTextFieldHeightAnchor:NSLayoutConstraint?
    
    func setupInputContainerView() {
        //Need x,y,width,height Constraints
        inputContainerViews.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerViews.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerViews.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerViewHeightConstraint = inputContainerViews.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightConstraint?.isActive = true
        
        
        inputContainerViews.addSubview(nameTexField)
        inputContainerViews.addSubview(nameSeparatorView)
        inputContainerViews.addSubview(emailTexField)
        inputContainerViews.addSubview(emailSeparatorView)
        inputContainerViews.addSubview(passwordTexField)
        
        
        

        //Need x,y,width,height Constraints
        nameTexField.leftAnchor.constraint(equalTo: inputContainerViews.leftAnchor,constant:12).isActive = true
        nameTexField.topAnchor.constraint(equalTo: inputContainerViews.topAnchor).isActive = true
        nameTexField.widthAnchor.constraint(equalTo: inputContainerViews.widthAnchor).isActive = true
        
        nameTextFieldHeightAnchor =  nameTexField.heightAnchor.constraint(equalTo: inputContainerViews.heightAnchor, multiplier: 1/3)
        
        nameTextFieldHeightAnchor?.isActive = true
        
        
        
        //Need x,y,width,height Constraints
      nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerViews.leftAnchor).isActive = true
        
        nameSeparatorView.topAnchor.constraint(equalTo: nameTexField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerViews.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
        
        //Need x,y,width,height Constraints
        emailTexField.leftAnchor.constraint(equalTo: inputContainerViews.leftAnchor,constant:12).isActive = true
        emailTexField.topAnchor.constraint(equalTo: nameTexField.bottomAnchor).isActive = true
        emailTexField.widthAnchor.constraint(equalTo: inputContainerViews.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTexField.heightAnchor.constraint(equalTo: inputContainerViews.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        
        
        //Need x,y,width,height Constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerViews.leftAnchor).isActive = true
        
        emailSeparatorView.topAnchor.constraint(equalTo: emailTexField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerViews.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
        
        
        //Need x,y,width,height Constraints
        passwordTexField.leftAnchor.constraint(equalTo: inputContainerViews.leftAnchor,constant:12).isActive = true
        passwordTexField.topAnchor.constraint(equalTo: emailTexField.bottomAnchor).isActive = true
        passwordTexField.widthAnchor.constraint(equalTo: inputContainerViews.widthAnchor).isActive = true
        
        
        
        passwordTextFieldHeightAnchor = passwordTexField.heightAnchor.constraint(equalTo: inputContainerViews.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        //Need x,y,width,height Constraints
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: loginRegisterSegmentedController.topAnchor,constant:-12).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true

        
        
        
    }
    
    
    
    // MARK: - Constrains for LoginRegisterButton

    func setupLoginRegisterButton()
    {
        
        //Need x,y,width,height Constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo:inputContainerViews.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerViews.widthAnchor).isActive  = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Constrains for LoginRegisterSegment

    func setupLoginRegisterSegment() {
        
        
        loginRegisterSegmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedController.bottomAnchor.constraint(equalTo: inputContainerViews.topAnchor,constant:-12).isActive = true
        loginRegisterSegmentedController.widthAnchor.constraint(equalTo: inputContainerViews.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedController.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        
    }
    
    
    
    
    
}

extension UIColor{
    
    convenience init(r:CGFloat , g:CGFloat , b:CGFloat) {
        self.init(red:r/255,green:g/255,blue:b/255, alpha:1)
    }
}
