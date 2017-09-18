

import UIKit
import Foundation

class FirstViewController: UIViewController {
    
    

    @IBOutlet weak var editName: UITextField!
    
    @IBOutlet weak var date: UIDatePicker!
    
    var dataBasePath = NSString()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let fileManager = FileManager.default
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        
        dataBasePath = docsDir.appendingPathComponent("controladorAlimentos.db") as NSString
        
        
        
        if !fileManager.fileExists(atPath: dataBasePath as String){
            let controladorAlimentosDB = FMDatabase(path: dataBasePath as String)
            if controladorAlimentosDB == nil{
                print("Error: \(controladorAlimentosDB?.lastErrorMessage())")
            }
            
            if (controladorAlimentosDB?.open())! {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS ACTUAL (name TEXT PRIMARY KEY, date LONG)"
                if !(controladorAlimentosDB?.executeStatements(sql_stmt))! {
                    print("Error: \(controladorAlimentosDB?.lastErrorMessage())")
                }
                controladorAlimentosDB?.close()
            } else {
                print("Error: \(controladorAlimentosDB?.lastErrorMessage())")
            }
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    @IBAction func saveData(_ sender: AnyObject) {
        
        if (editName.text!.isEmpty){
            let alert = UIAlertController(title: "Error", message: "Introduzca un nombre", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: nil))
            // Mostrar la alerta en Pantalla
            self.present(alert, animated:true, completion:nil)
            
        }else{
            let controladorAlimentosDB = FMDatabase(path: dataBasePath as String)
            
            if (controladorAlimentosDB?.open())! {
                
                
                let timestamp : TimeInterval = date.date.timeIntervalSince1970 * 1000
                
                let insertSQL = "INSERT INTO ACTUAL (name, date) VALUES ('\(editName.text!)', '\(timestamp)')"
                
                let result = controladorAlimentosDB?.executeUpdate(insertSQL,
                    withArgumentsIn: nil)
                
                if !result! {
                    let alert = UIAlertController(title: "Error", message: "Ya existe un alimento con el mismo nombre", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: nil))
                    // Mostrar la alerta en Pantalla
                    self.present(alert, animated:true, completion:nil)
                    editName.text = ""
                    date.date = Date()
                    print("Error: \(controladorAlimentosDB?.lastErrorMessage())")
                } else {
                    let notification = UILocalNotification()
                    notification.alertBody = "\(editName.text!) caduca mañana" // text that will be displayed in the notification
                    notification.alertAction = "Abrir" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                    notification.fireDate = date.date.addingTimeInterval(-60*60*24) // todo item due date (when notification will be fired)
                    //notification.fireDate = NSDate(timeIntervalSinceNow: 15)
                    notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                    notification.userInfo = ["UUID": editName.text!, ] // assign a unique identifier to the notification so that we can retrieve it later
                    notification.applicationIconBadgeNumber += 1
                    UIApplication.shared.scheduleLocalNotification(notification)
                    let alert = UIAlertController(title: "Controlador de Alimentos", message: "Alimento añadido correctamente", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: nil))
                    // Mostrar la alerta en Pantalla
                    self.present(alert, animated:true, completion:nil)
                    editName.text = ""
                    date.date = Date()
                    
                }
            } else {
                print("Error: \(controladorAlimentosDB?.lastErrorMessage())")
            }

        }
        
    }
    
    
    
    
    //////////////////////////  Gestión del teclado ////////////////////////////////////
    
    /////// Método llamado al perder el foco el cuadro de texto
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    /////// Método de UITextFieldDelegate al pulsar RETURN
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

