//
//  ViewController.swift
//  MapPinPLiist
//
//  Created by 이영완 on 2017. 9. 17..
//  Copyright © 2017년 이영완. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var segueItem: UISegmentedControl!

    @IBOutlet weak var myMapView: MKMapView!
    var inDelta = 0.8
    var locationManager = CLLocationManager()
    var item:[String:String] = [:]
    var items:[[String:String]] = []
    
    //var annotations = [MKPointAnnotation]()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        zoomToRegion()
        
        /////////////////////////////
        self.title = "부산 전통시장"
        
        let path = Bundle.main.path(forResource: "marketData", ofType: "plist")
        print("path = \(String(describing: path))")
        
        let contents = NSArray(contentsOfFile: path!)
        print("path = \(String(describing: contents))")
        
        items = NSArray(contentsOfFile: path!) as! [[String : String]]
        //print(items)
        var annotations = [MKPointAnnotation]()
        
        // optional binding
        if let myItems = contents {
            // Dictionary Array에서 값 뽑기
            for item in myItems {
                let lat = (item as AnyObject).value(forKey: "latitude")
                let long = (item as AnyObject).value(forKey: "longitude")
                let title = (item as AnyObject).value(forKey: "name")
                let subTitle = (item as AnyObject).value(forKey: "addrJibun")
                //let img = (item as AnyObject).value(forKey: "img")
                
                let annotation = MKPointAnnotation()
                
                print("lat = \(String(describing: lat))")
                if lat == nil || long == nil {
                    
                }else {
                let myLat = (lat as! NSString).doubleValue
                let myLong = (long as! NSString).doubleValue
                let myTitle = title as! String
                let mySubTitle = subTitle as! String
                
                print("myLat = \(myLat)")
                
                annotation.coordinate.latitude = myLat
                annotation.coordinate.longitude = myLong
                annotation.title = myTitle
                annotation.subtitle = mySubTitle
                
                annotations.append(annotation)
                
                myMapView.delegate = self
                }
            }
        } else {
            print("contents의 값은 nil")
        }
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        myMapView.showsUserLocation = true
        
        // 전체 핀이 지도에 보이도록 함
        myMapView.showAnnotations(annotations, animated: true)
        
        //핀 하나가 자동으로 탭되도록 처리
        //myMapView.selectAnnotation(annotations[0], animated: true)
        
        myMapView.addAnnotations(annotations)

    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        let center = locationManager.location?.coordinate
        inDelta = (sender as AnyObject).value / 60
        print("indelta : \(inDelta)")
        let span = MKCoordinateSpan(latitudeDelta: inDelta, longitudeDelta: inDelta)
        let region = MKCoordinateRegionMake(center!, span)
        myMapView.setRegion(region, animated: true)

    }

    @IBAction func test(_ sender: Any) {
        zoomToRegion()
    }
    
    func zoomToRegion() {
        // 35.162685, 129.064238
        let center = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!, (locationManager.location?.coordinate.longitude)!)
        //let center = CLLocationCoordinate2DMake(35.162685, 129.064238)
        var span = MKCoordinateSpanMake(0.010, 0.1)
        
        switch segueItem.selectedSegmentIndex {
        case 0:
            span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegionMake(center, span)
            
            myMapView.setRegion(region, animated: true)
        case 1:
            span = MKCoordinateSpanMake(0.010, 0.010)
            let region = MKCoordinateRegionMake(center, span)
            
            myMapView.setRegion(region, animated: true)
        case 2:
            span = MKCoordinateSpanMake(0.034, 0.44)
            let region = MKCoordinateRegionMake(center, span)
            
            myMapView.setRegion(region, animated: true)
            //        case 3:
        //            span = MKCoordinateSpanMake(0.35, 0.44)
        default:
            span = MKCoordinateSpanMake(0.010, 0.1)
            let region = MKCoordinateRegionMake(center, span)
            
            myMapView.setRegion(region, animated: true)
        }


    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        var  annotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            

        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        
        return annotationView
        
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        
//        print("callout Accessory Tapped!")
//        
//        let viewAnno = view.annotation
//        let viewTitle: String = ((viewAnno?.title)!)!
//        let viewSubTitle: String = ((viewAnno?.subtitle)!)!
//        
//        print("\(viewTitle) \(viewSubTitle)")
//        
//        let ac = UIAlertController(title: viewTitle, message: viewSubTitle, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//       
//        present(ac, animated: true, completion: nil)
//    }
    var selectedAnnotation: MKPointAnnotation!
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
            performSegue(withIdentifier:"Detail_info", sender: view)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_info" {
            let detailVC = segue.destination as! TableViewController
            detailVC.annoTitle = (sender as! MKAnnotationView).annotation!.title as! String
            detailVC.tItems = items
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        //print(userLocation)
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
        
        //myMapView.setRegion(region, animated: true)
    }

}

