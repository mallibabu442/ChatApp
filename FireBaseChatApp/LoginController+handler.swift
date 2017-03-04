//
//  LoginController+handler.swift
//  FireBaseChatApp
//
//  Created by MANOJ KUMAR on 04/01/17.
//  Copyright © 2017 MANOJ KUMAR. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

extension LoginController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
    
    
    func handleRegister() {
        guard let email = emailTexField.text, let password = passwordTexField.text, let name = nameTexField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let imagename = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imagename).jpg")
            
            if let profileImage = self.profileImage.image , let uploadImage = UIImageJPEGRepresentation(profileImage, 0.1){
                
            storageRef.put(uploadImage, metadata: nil, completion: { (metadata,error) in
                    
                    if error != nil{
                        print(error)
                        
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                    }
                    
                })
            }
            
        
        })
    }
    
    
    
    
    
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://fir-chatapp-8f4b0.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
             
            if err != nil {
                print(err)
                return
            }
            
            
            let user = User()
            user.setValuesForKeys(values)
//           // self.messageController?.fetchUserAndSetupNavBarTitle()
//            self.messageController?.navigationItem.title = values["name"] as? String
            self.messageController?.setUpNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
        })
    }

    
    
    
    
        
    
    
    func handleSelectProfileImageView(){
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        
        
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editImage = info["UIImagePickerControllerEditedImage" ] as? UIImage {
            
            selectedImageFromPicker = editImage
            
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectImage = selectedImageFromPicker{
            
            profileImage.image = selectImage
        }
        
        dismiss(animated: true, completion: nil)
        
        print(info)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
