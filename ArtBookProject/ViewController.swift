//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Hanife Mehan on 13.03.2021.
//  Copyright © 2021 Hanife Mehan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingID : UUID?
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate=self
        tableView.dataSource=self
        
        
        //ViewController daki toolBar kısmın ulaşmış oluruz bu kod ile. barButtonSystemItem ile icon koyabiliriz.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonClick))
        
        getData()
    }
    
    //ViewController her açıldığında çağırılacağı için Notification fonksiynumuzu burada döndürdük
    override func viewWillAppear(_ animated: Bool) {
        //gözlemci ekle - getData() yı burada döndürdük ki her değişiklikte güncellensin
        NotificationCenter.default.addObserver(self, selector: #selector (getData), name: NSNotification.Name(rawValue : "newData"), object: nil)
    }

    
    @objc func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //fetch metodunu verileri çekmek için kullanırız
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        //okuma hızı artar ve daha verimli saklama sağlanır false yaparız.
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            //results değişkeni bir dizi artık
           let results =  try context.fetch(fetchRequest)
            if results.count > 0{
            for result in results as! [NSManagedObject]{
                
                //String olarak cast etmek istiyoruz .koşul sağlıyorsa işlem devam eder
                if let name = result.value(forKey: "name") as? String{
                    
                    self.nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    
                    self.idArray.append(id)
                }
                //Yeni veri geldiğinde kendisini güncellemesini sağlar
                self.tableView.reloadData()
            }
            }
            
        }catch{
            
            print("errorr..")
        }
        
    }

    //ToolBarımızın işlevini veridğimiz fonksiyon
    @objc func addButtonClick(){
        //eğer + ya tıklandıysa boş string yanib oş sayfa açılır
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    // -> var ise bir return değeri dönecek anlamını çıkarabiliriz
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailsVC"{
            //Senkronize ettik
            let destinationVC = segue.destination as! DetailtVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaitingId = selectedPaintingID
            
        }
        
    }
    //Bir veriye tıklandığında segue yapacağız
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Eğer bir isme tıklandıysa isime ait verilere ktarılır
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    //Kullanıcı delete mi yapıyor algılayıp işlemlerimizi yapıyoruz (Silme işlemleri burada yapıldı)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            //fetchReguest ile ilgili veriyi çekeceğiz çektiğimiz veriyi sileceğiz.
            let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = idArray[indexPath.row].uuidString
            fetchReguest.predicate = NSPredicate(format: "id = %@", idString)
            fetchReguest.returnsObjectsAsFaults = false
            
            do{
            let results = try context.fetch(fetchReguest)
                if results.count>0{
                    
                    for result in results as! [NSManagedObject]{
                        
                        if let id = result.value(forKey: "id") as? UUID{
                            //silmeden önce iyice kontrol ediliyor.
                            if id == idArray[indexPath.row]{
                                
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("error..")
                                }
                                
                                break
                            }
                        }
                    }
                }
            }catch{
                print("error..")
            }
        }
    }
    

}

