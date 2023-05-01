//
//  NamesViewController.swift
//  RememberMe
//
//  Created by William Misiaszek on 3/13/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import CoreData
import CoreLocation

class NamesViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: - OUTLETS
    @IBOutlet weak var NameList: UITableView!
    var names: [Note] = []

      
      //FireBase Cloud Storage
      let db = Firestore.firestore()
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          navigationController?.setNavigationBarHidden(true, animated: false)
          
          NameList.dataSource = self
          NameList.delegate = self
          NameList.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
          
          fetchNames()
      }
      
      override func viewDidLoad() {
          super.viewDidLoad()
      }
    
    func createAttributedString(from noteText: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: noteText)
        
        if let range = noteText.range(of: " - ") {
            let boldRange = NSRange(noteText.startIndex..<range.lowerBound, in: noteText)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 19), range: boldRange)
        }
        
        return attributedString
    }
      
    func fetchNames() {
        if let userEmail = Auth.auth().currentUser?.email {
            db.collection("notes")
                .whereField("user", isEqualTo: userEmail)
                .getDocuments { querySnapshot, error in
                    if let e = error {
                        print("There was an issue retrieving data from Firestore: \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            self.names = snapshotDocuments.compactMap { queryDocumentSnapshot -> Note? in
                                let data = queryDocumentSnapshot.data()
                                let noteText = data["note"] as? String ?? ""
                                if let locationData = data["location"] as? GeoPoint {
                                    let locationName = data["locationName"] as? String ?? ""
                                    let noteID = queryDocumentSnapshot.documentID
                                    
                                    let location = CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude)
                                    return Note(id: noteID, text: noteText, location: location, locationName: locationName)
                                } else {
                                    return nil
                                }
                            }
                            
                            // Sort notes alphabetically
                            self.names.sort { $0.text.lowercased() < $1.text.lowercased() }
                            
                            // Reload the table view
                            DispatchQueue.main.async {
                                self.NameList.reloadData()
                            }
                        }
                    }
                }
        }
    }

    
  
  }

  // MARK: - UITableViewDataSource
  extension NamesViewController: UITableViewDataSource {
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return names.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
          let name = names[indexPath.row]
          
          // Configure the cell with the name
          cell.noteTextField.attributedText = createAttributedString(from: name.text) // Set the attributed text
          cell.noteLocation = name.location
          cell.delegate = self
          cell.noteId = name.id // Set the noteId property
          
          return cell
      }

  }

  // MARK: - UITableViewDelegate
  extension NamesViewController: UITableViewDelegate {
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
          
          // Perform any action when a name is selected, if needed
      }
  }

// In NamesViewController.swift
extension NamesViewController: NoteCellDelegate {
    func noteCellTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 

    func noteCell(_ cell: NoteCell, didUpdateNote note: Note) {
        // Save the updated note to Firestore
        if let userEmail = Auth.auth().currentUser?.email {
            db.collection("notes").document(note.id).updateData([
                "note": note.text,
                "location": GeoPoint(latitude: note.location.latitude, longitude: note.location.longitude),
                "locationName": note.locationName,
                "user": userEmail
            ]) { error in
                if let error = error {
                    print("Error updating note: \(error)")
                } else {
                    print("Note successfully updated")
                }
            }
        }
    }

    func noteCellDidEndEditing(_ cell: NoteCell) {
        // Perform any additional tasks when editing ends, if necessary
    }
}

