//
//  ThirdViewController.swift
//  ControladorAlimentos
//
//  Created by Miguel Ibáñez Paricio on 23/9/15.
//  Copyright © 2015 Miguel Ibáñez Paricio. All rights reserved.
//


import UIKit
import GoogleMaps
var mapView = GMSMapView()

class ThirdViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
        }else{
            let camera = GMSCameraPosition.cameraWithLatitude(-33.86,
                longitude: 151.20, zoom: 6)
            mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
            mapView.myLocationEnabled = true
            self.view = mapView
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
            marker.title = "Sydney"
            marker.snippet = "Australia"
            marker.map = mapView
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let camera = GMSCameraPosition.cameraWithLatitude(locValue.latitude ,
            longitude: locValue.longitude, zoom: 13)
        mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        mapView.myLocationEnabled = true
        self.view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(locValue.latitude ,locValue.longitude)
        marker.title = "Yo"
        marker.map = mapView
        self.locationManager.stopUpdatingLocation()
        obtenerSupermercados( String(format:"%f", locValue.latitude), long: String(format:"%f", locValue.longitude))
        
        

        
    }
    
    func obtenerSupermercados(_ lat:String,long:String)
    {
        var query:String
        query="https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        query += "location=" +  lat + "," + long + "&"
        query+="radius=10000&"
        query+="types=" + "grocery_or_supermarket" + "&"
        query += "sensor=true&" //Must be true if queried from a device with GPS
        query += "key=" + "AIzaSyCuGTza0XrakZtybz3U-AJKQyuuQAFLUk4"
        let url = URL(string: query)
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            print("tarea finalizada")
            if error != nil
            {
                print("error")
                print(error!.localizedDescription)
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    let jsonArray = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                    if let arraySupermercados = jsonArray["results"] as? NSArray
                    {
                        print(arraySupermercados)
                        for supermercado in arraySupermercados
                        {
                            
                            if let geometry = supermercado["geometry"] as? NSDictionary
                            {
                                if let location = geometry["location"] as? NSDictionary{
                                    
                                    if let latitude = location["lat"] as? Double{
                                        if let longitude = location["lng"] as? Double{
                                            let marker = GMSMarker()
                                            marker.position = CLLocationCoordinate2DMake(latitude,longitude)
                                            marker.title = supermercado["name"] as? String
                                            marker.map = mapView
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                })
            }
        })
        
        
        task.resume()
    }

    

}
