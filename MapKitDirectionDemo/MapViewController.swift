//
//  MapViewController.swift
//  MapKitDirectionDemo
//
//  Created by Simon Ng on 18/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var restaurant:Restaurant!
    let locationManager = CLLocationManager()
    var currentPlacemark: CLPlacemark?
    var currentTransportType = MKDirectionsTransportType.Automobile
    var currentRoute: MKRoute?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.hidden = true
        
        // request for a user's authorization to use location services
        
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            
            // enable mapView to display current location of user (not enabled by default)
            
            mapView.showsUserLocation = true
        }

        mapView.delegate = self
        
        // Convert address to coordinate and annotate it on map
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.address, completionHandler: { placemarks, error in
            if error != nil {
                print(error)
                return
            }
            
            if let placemarks = placemarks {
                // Get the first placemark
                let placemark = placemarks[0]
                self.currentPlacemark = placemark
                
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.title = self.restaurant.name
                annotation.subtitle = self.restaurant.category
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    
                    // Display the annotation
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        })

    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        let leftIconView = UIImageView(frame: CGRectMake(0, 0, 53, 53))
        leftIconView.image = UIImage(named: restaurant.image)!
        annotationView?.leftCalloutAccessoryView = leftIconView
        
        // Pin color customization
        if #available(iOS 9.0, *) {
            annotationView?.pinTintColor = UIColor.orangeColor()
        }
        
        annotationView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("showSteps", sender: view)
    }
    
    @IBAction func showDirection(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: currentTransportType = MKDirectionsTransportType.Automobile
        case 1: currentTransportType = MKDirectionsTransportType.Walking
        default: break
        }
        
        segmentedControl.hidden = false
        
        guard let currentPlacemark = currentPlacemark else {
            
            return
        }
        
        let directionRequest = MKDirectionsRequest()
        
        // set the source and destination of the route
        
        directionRequest.source = MKMapItem.mapItemForCurrentLocation()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = currentTransportType
        
        // calculate the directions
        
        let directions = MKDirections(request: directionRequest)
        directions.calculateDirectionsWithCompletionHandler { (routeResponse, routeError) -> Void in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                
                return
            }
            
            let route = routeResponse.routes[0]
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            
            // scale mapView to include entire route in single view
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    // draw the route line
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .Automobile) ? UIColor.blueColor() : UIColor.orangeColor()
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // get the new view controller using segue.destinationViewController
        // pass the selected object to the new view controller
        
        if segue.identifier == "showSteps" {
            let routeTableViewController = segue.destinationViewController as! RouteTableViewController
            if let steps = currentRoute?.steps {
                routeTableViewController.routeSteps = steps
            }
        }
    }


}
