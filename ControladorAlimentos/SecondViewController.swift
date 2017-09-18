

import UIKit





class SecondViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var listaAlimentos: UITableView!
    var listaNombreAlimentos:[String] = []
    var listaFechas:[Double] = []
    var dataBasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listaNombreAlimentos = [String]()
        listaFechas = [Double]()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        
        dataBasePath = docsDir.appendingPathComponent("controladorAlimentos.db") as NSString
        
        let controladorAlimentosDB = FMDatabase(path: dataBasePath as String)
        
        if (controladorAlimentosDB?.open())! {
            let querySQL = "SELECT name,date  FROM ACTUAL"
            
            let results:FMResultSet? = controladorAlimentosDB?.executeQuery(querySQL,
                withArgumentsIn: nil)
            
            while results?.next() == true {
                listaNombreAlimentos.append(results!.string(forColumn: "name"))
                listaFechas.append(results!.double(forColumn: "date"))
            }
            controladorAlimentosDB?.close()
        } else {
            print("Error: \(controladorAlimentosDB?.lastErrorMessage())")
        }
        self.listaAlimentos.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ////////////// Métodos para la gestión de la tabla //////////////////
    /////////////////////////////////////////////////////////////////////
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listaNombreAlimentos.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let celda:Celda = tableView.dequeueReusableCell(withIdentifier: "Celda") as! Celda
        
        if !listaNombreAlimentos.isEmpty
        {
            celda.labelNombre.text = listaNombreAlimentos[indexPath.row]
            let date = Date(timeIntervalSince1970:listaFechas[indexPath.row]/1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy" //format style. Browse online to get a format that fits your needs.
            celda.labelFecha.text = dateFormatter.string(from: date)
        }
        
        
        return celda

    }
    
    
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            listaNombreAlimentos.remove(at: indexPath.row)
            
            listaAlimentos.reloadData()
        }
        
        if editingStyle == UITableViewCellEditingStyle.insert
        {
            listaNombreAlimentos.remove(at: indexPath.row)
            
            listaAlimentos.reloadData()
        }
        
    }
    

    
    func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [AnyObject]? {
        let archiveAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Receta",handler: { (action: UITableViewRowAction!, indexPath: IndexPath!) in
            // maybe show an action sheet with more options
            self.listaAlimentos.setEditing(false, animated: false)
            let currentCell = self.listaAlimentos.cellForRow(at: indexPath) as UITableViewCell!
            
            let alert = UIAlertController(title: "Buscar receta con \(self.listaNombreAlimentos[indexPath.row])", message: "Añada Alimentos a la receta", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.isSecureTextEntry = true
            })
            
            let txtReceta = alert.textFields![0] as UITextField
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:
                {
                    (alert: UIAlertAction!) in
                    self.lanzaReceta("\(currentCell?.textLabel!.text!) \(txtReceta.text!)")
            
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler:
                {
                    (alert: UIAlertAction!) in
                    
                    self.view.endEditing(true)
                    
            }))
            
            self.present(alert, animated: true, completion: nil)
            }
        )
        archiveAction.backgroundColor = UIColorFromHex(0x4C9732, alpha: 1)
        
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Delete", handler: { (action: UITableViewRowAction!, indexPath: IndexPath!) in

            let currentCell = self.listaAlimentos.cellForRow(at: indexPath) as UITableViewCell!
            self.eliminarAlimento((currentCell?.textLabel!.text!)!, indexPath: indexPath);

     
                
            }
        );
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction, archiveAction]
    }
    
    
    func lanzaReceta(_ query : String){
        if !query.isEmpty{
            let urlquery = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
            var url : URL
            url = URL(string: "https://www.google.com/search?q=receta+"+urlquery)!
            UIApplication.shared.openURL(url)

            
        }
            }
    
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func eliminarAlimento(_ alimento : String, indexPath : IndexPath){
        let alimentosDB = FMDatabase(path: self.dataBasePath as String)
        
        if (alimentosDB?.open())! {
            
            let deleteSQL = "DELETE FROM ACTUAL WHERE name = '\(alimento)'"
            
            let result = alimentosDB?.executeUpdate(deleteSQL,
                withArgumentsIn: nil)
            
            if !result! {
                let alert = UIAlertController(title: "Error", message: "Error eliminando alimento", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: nil))
                // Mostrar la alerta en Pantalla
                self.present(alert, animated:true, completion:nil)
            }else{
                //CANCELO LA NOTIFICACION
                let app:UIApplication = UIApplication.shared
                for oneEvent in app.scheduledLocalNotifications! {
                    let notification = oneEvent as UILocalNotification
                    let userInfoCurrent = notification.userInfo! as! [String:AnyObject]
                    let uid = userInfoCurrent["UUID"]! as! String
                    print(self.listaNombreAlimentos[indexPath.row] )
                    if uid == self.listaNombreAlimentos[indexPath.row] {
                        //Cancelling local notification
                        app.cancelLocalNotification(notification)
                        break;
                    }
                }
                self.listaNombreAlimentos.remove(at: indexPath.row)
                self.listaAlimentos.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)

            }
        } else {
            print("Error: \(alimentosDB?.lastErrorMessage())")
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
    


}

