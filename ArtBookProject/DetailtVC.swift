//
//  DetailtVC.swift
//  ArtBookProject
//
//  Created by Hanife Mehan on 13.03.2021.
//  Copyright © 2021 Hanife Mehan. All rights reserved.
//

import UIKit
import CoreData

class DetailtVC: UIViewController  , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaitingId : UUID?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if chosenPainting != ""{
            //Eğer boş değilse butonun görünür olmaması sağlanır isHidden = true da kullanılabilir
            saveButton.isEnabled = false
            
            let appDelegtae = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegtae.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            //filtrele yaptık
            let idString = chosenPaitingId?.uuidString
            //Yazdığımız koşula göre veriye ulaşırız.
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "atist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                
                print("error")
                
            }
            //Core Data
            //id ye gmre filtreleyip çekeceğiz
            //let stringUUID = chosenPaitingId!.uuid
        //veirye tıklandığında uuid çıktı alınır
            //print(stringUUID)
            
        }else{
            //görünür olsun ama
            saveButton.isHidden = false
            //tıklanamasın
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
     

        // Do any additional setup after loading the view.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }



    @IBAction func saveButtonClicked(_ sender: Any) {
        
        //AppDelegate yi değişken olarak tanımlamış oluruz.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //coreDataya veri kaydetmemize olanak sağlayacak fonksiyonumuz
        //context.save()
        
        //1.si entity nin adı 2. si bunu kaydedebileceğimiz context ver
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        //Painting entity mizin içine verileri kaydederiz
        //Attributes
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
       
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
 
        newPainting.setValue(UUID(), forKey: "id")
        //görseli data olarak kaydedeceğiz , görseli dataya çeviririzz.
        //image i data ya çevirirken kullanılan yapıda hata alıyoruz bu yüzden core data ya kaydedemedik.
       //let data = imageView.image!.jpegData(CompressionQuality:0.5)
      //  newPainting.setValue(data, forKey: "image")
       // newPainting.setValue(imageView.image, forKey: "image")
        
        
        do{
            try context.save()
            print("succes")
        }catch{
            print("error")
        }
        
        //Diğer viewController lara haber göndermeyi sağlıyor
        //Bir viewControllerda yapılan değişikliği diğer viewController lara haber vermek için kullndık
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        //ile bir önceki sayfaya gidebiliriz
        self.navigationController?.popViewController(animated: true)
        
       
    }
    
    @objc  func hideKeyboard(){
        //uygullama içinde yapılan değişiklikleri kapatır Klavyeyi kapatır
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        
        //Galeriye göndermek için kullanırız
        let picker = UIImagePickerController()
        picker.delegate = self
        //foto erişimini nerden sağlayacağımızı belirtiriz
        picker.sourceType = .photoLibrary
        //düzenlemeye croplamaya izin vermek için kullanırız
        picker.allowsEditing = true
        //picker ımızı bu şekilde gösteririz
        present(picker, animated: true, completion: nil)
        
        
        
    }
    //medyayla işimiz bitince ne yapacağımızı yazarız
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //fotoğraf seçildiği zaman tıklanabilir olsun
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
  

 
}
