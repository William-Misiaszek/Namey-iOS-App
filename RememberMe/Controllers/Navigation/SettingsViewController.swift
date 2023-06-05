//
//  SettingsViewController.swift
//  RememberMe
//
//  Created by William Misiaszek on 3/13/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    var rotationSpeed = 1.0


    @IBOutlet weak var catImage: UIImageView!
    
    @IBAction func LogOutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
           do {
               try firebaseAuth.signOut()

               // Notify the scene delegate to show the initial view controller
               NotificationCenter.default.post(name: .didSignOut, object: nil)

           } catch let signOutError as NSError {
               print("Error signing out: %@", signOutError)
           }
       }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add UITapGestureRecognizer to catImage
               let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
               catImage.isUserInteractionEnabled = true
               catImage.addGestureRecognizer(tapGestureRecognizer)
           }
        // Do any additional setup after loading the view.
    
    @objc private func imageTapped() {
           rotationSpeed += 0.1
           let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
           rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0 * rotationSpeed)
           rotationAnimation.duration = 1.0
           rotationAnimation.isCumulative = true
           rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
           catImage.layer.add(rotationAnimation, forKey: "rotationAnimation")
       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
