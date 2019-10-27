//
//  ViewController.swift
//  MapApp
//
//  Created by William Wilson on 10/3/19.
//  Copyright © 2019 William Wilson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
//import PythonKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let locationManager = CLLocationManager()
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeButton: UISegmentedControl!
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func showTableView(_ sender: Any) {
        performSegue(withIdentifier: "SegueToCameraViewController", sender: self)
    }
    
    let regionRadius: CLLocationDistance = 1000
    
    var gasStations = [GasStation]()
    //let gasStations = [GasStation(prices: [1.0,2.0], lattitude: 51.5549, longtitude: -0.108436)]
    
    var lastUserLocation: MKUserLocation?
    var currentlocation = CLLocation()
    let testLocation = CLLocation(latitude: 33.774884, longitude: -89.396416)
    var count = 0
    var newImage = UIImage()
    let vision = Vision.vision()
    var listOfPricesCurrent = [Float]()
    
    var buttonBeingPressed = false
    @IBAction func centerMapToCurrentLocation(_ sender: Any) {
        centerMapOnLocation(location: currentlocation)
    }
    @IBAction func showCameraViewController(_ sender: Any) {
        buttonBeingPressed = true
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        // create the alert
        //https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { action in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { action in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        

        // show the alert
        self.present(alert, animated: true, completion: nil)
        buttonBeingPressed = false
        
    }
    @IBAction func segmentedControlAction(_ sender: Any) {
        switch ((sender as AnyObject).selectedSegmentIndex) {
            case 0:
                mapView.mapType = .standard
            case 1:
                mapView.mapType = .satellite
            default:
                mapView.mapType = .hybrid
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        cameraButton.backgroundColor = .clear
//        cameraButton.layer.cornerRadius = 5
//        cameraButton.layer.borderWidth = 1
//        cameraButton.layer.borderColor = UIColor.black.cgColor
        count = 0
        //navigationItem.title = "Root View"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
        checkLocationServices()
        fetchStadiumsOnMap(gasStations)
        if (CLLocationManager.locationServicesEnabled())
        {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//            self.centerMapOnLocation(location: self.currentlocation)
//        })
        
    }
    
    
    
    
    //hides nav bars
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the Navigation Bar
        if buttonBeingPressed == false {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        buttonBeingPressed = false
    }
    
    
    
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
          checkLocationAuthorization()
        } else {
          // Show alert letting the user know they have to turn this on.
        }
    }
    
    func checkLocationAuthorization() {
      switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            self.currentlocation = locationManager.location ?? testLocation
        
      // For these case, you need to show a pop-up telling users what's up and how to turn on permisneeded if needed
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
        case .restricted:
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            self.currentlocation = locationManager.location ?? testLocation
        @unknown default:
            fatalError()
        }
    }
    //https://www.ioscreator.com/tutorials/take-photo-ios-tutorial
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let someImage = info[.originalImage] as? UIImage
        newImage = someImage!
        //let image = UIImage(named: "text.jpg")
        let textRecognizer = vision.cloudTextRecognizer()
        let visionImage = VisionImage(image: newImage)
        textRecognizer.process(visionImage) { result, error in
          guard error == nil, let result = result else {
            // ...
            print("error help")
            let alert = UIAlertController(title: "Uh oh!", message: "Make sure a gas station sign is in the frame.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
                self.buttonBeingPressed = true
                self.imagePicker =  UIImagePickerController()
                self.imagePicker.delegate = self
                // create the alert
                //https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { action in
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true, completion: nil)
                    
                }))
                alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { action in
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                

                // show the alert
                self.present(alert, animated: true, completion: nil)
                self.buttonBeingPressed = false
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            

            // show the alert
            self.present(alert, animated: true, completion: nil)
            return
          }
            let resultText = result.text
            for block in result.blocks {
                let blocktext = block.text
                
            }
            var textList = [String]()
            var priceList = [String]()
            var priceListFloat = [Float]()
            var priceList2 = [Float]()
            for block in result.blocks {
                let blocktext = block.text
                textList.append(blocktext)
            }
            for item in textList {
                var fullNameArr = item.components(separatedBy: " ")
                if let index = textList.firstIndex(of: item) {
                    textList.remove(at: index)
                }
                let count4 = fullNameArr.count
                var counter4 = 0
                while counter4 < count4 {
                    textList.append(fullNameArr[counter4])
                    counter4 += 1
                }
            }
            
            for item in textList {
                var itemHere = item
                var copyitem = [String]()
                var hasLetter = false
                for character in item {
                    
                    if character.isLetter {
                        hasLetter = true
                    }
                }
                if hasLetter == false{
                    if item.count>=3{
                        
                    
                    let dollarSign: Set<Character> = ["$", "'"]
                    itemHere.removeAll(where: {dollarSign.contains($0)})
                    itemHere = itemHere.trim()
                    priceList.append(itemHere)
                
                    }
                }
            
                
            }
            var counter = 0
            do {
                for prices in priceList {
                    if prices.contains(".") {

                        let prices2 = prices.prefix(4)
                        priceListFloat.insert(Float(prices2)!, at: counter)
                        counter+=1
                    
                    }
                    else if !(prices.contains(".")) {
                        var pricesOk = String(prices)
                        pricesOk = pricesOk[0..<1] + "." + pricesOk[1..<3]
                        priceListFloat.insert(Float(pricesOk)!, at: counter)
                        counter+=1
                    }
                    
                    }
                for things in priceListFloat {
                    if !(priceList2.contains(things)) {
                        priceList2.append(things)
                    }
                    
                }
                print(self.listOfPricesCurrent.count, "!")
                if priceList2.count > 0 {
                    self.listOfPricesCurrent = priceList2
                    self.gasStations.append(GasStation(prices: self.listOfPricesCurrent, lattitude: self.currentlocation.coordinate.latitude, longtitude: self.currentlocation.coordinate.longitude))
                    let annotations = MKPointAnnotation()
                    
                    annotations.title = self.listOfPricesCurrent.map({"\($0)"}).joined(separator:", ")
                    annotations.coordinate = CLLocationCoordinate2D(latitude: self.currentlocation.coordinate.latitude, longitude: self.currentlocation.coordinate.longitude)
                    self.mapView.addAnnotation(annotations)
                    self.fetchStadiumsOnMap(self.gasStations)
                    print(self.gasStations)
                } else {
                    let alert = UIAlertController(title: "Uh oh!", message: "Make sure a gas station sign is in the frame.", preferredStyle: UIAlertController.Style.alert)

                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
                        self.buttonBeingPressed = true
                        self.imagePicker =  UIImagePickerController()
                        self.imagePicker.delegate = self
                        // create the alert
                        //https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
                        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.alert)

                        // add the actions (buttons)
                        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { action in
                            self.imagePicker.sourceType = .camera
                            self.present(self.imagePicker, animated: true, completion: nil)
                            
                        }))
                        alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { action in
                            self.imagePicker.sourceType = .photoLibrary
                            self.present(self.imagePicker, animated: true, completion: nil)
                            
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                        

                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        self.buttonBeingPressed = false
                        
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
          // Recognized text
        }
        
        
        //imageView.image = info[.originalImage] as? UIImage
    }
    
    // https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            
            if (count == 0) {
                currentlocation = location
                centerMapOnLocation(location: self.currentlocation )
                count += 1
            }
            currentlocation = location
            
            //let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            //self.mapView.setRegion(region, animated: true)
            
        }
        
    }
    
    func fetchStadiumsOnMap(_ gasStation: [GasStation]) {
        for gasStation in gasStation {
            let annotations = MKPointAnnotation()
            
            annotations.title = gasStation.prices.map({"\($0)"}).joined(separator:", ")
            annotations.coordinate = CLLocationCoordinate2D(latitude: gasStation.lattitude, longitude: gasStation.longtitude)
            mapView.addAnnotation(annotations)
        }
        print("called")
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToCameraViewController" {
            if let nextViewController = segue.destination as? CameraViewController {
                    nextViewController.gasStationsForTable = gasStations //Or pass any values

            }
        }
    }


}

extension String
{
    func trim() -> String
   {
    
    return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
   }
   subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }

    subscript (range: Range<Int>) -> Substring {
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return self[startIndex..<stopIndex]
    }
}
