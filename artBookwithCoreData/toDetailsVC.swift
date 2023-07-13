//
//  toDetailsVC.swift
//  artBookwithCoreData
//
//  Created by Doğukan Ahi on 12.07.2023.
//

import UIKit
import CoreData

class toDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearfield: UITextField!
    @IBOutlet weak var artistfield: UITextField!
    @IBOutlet weak var namefield: UITextField!
    @IBOutlet weak var imageview: UIImageView!
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            namefield.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistfield.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearfield.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageview.image = image
                        }
                        
                    }
                    
                    
                }
                
            } catch{
                print("error3")
            }
        }
        else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
        }
        
        
        
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageview.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageview.addGestureRecognizer(imageTapRecognizer)
        
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageview.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
        
    }
    @objc func hideKeyboard(){
        view.endEditing(true)
    }

  
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegeta = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegeta.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(namefield.text!, forKey: "name")
        if let year = Int(yearfield.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(artistfield.text!, forKey: "artist")
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageview.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        do{
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
         
        NotificationCenter.default.post(name:  NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
