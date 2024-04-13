

import UIKit
import MapKit

class Map: UIViewController,
           MKMapViewDelegate,
           CLLocationManagerDelegate {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var destinationLocation: CLLocationCoordinate2D?
    var destinationCityName = ""
    var currentCityName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        setupSlider()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(rightBarButtonTapped))
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupSlider() {
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 0.5
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: CLLocationDistance(50000 - sender.value * 50000), longitudinalMeters: CLLocationDistance(50000 - sender.value * 50000))
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @objc func rightBarButtonTapped() {
        getCityName()
    }
    
    func getCityName() {
        showCityInputAlert(on: self,
                           title: "Enter City",
                           message: "Type the name of the city") { cityName in
            self.lookupCity(cityName: cityName)
            self.destinationCityName = cityName
        }
    }
    
    private func lookupCity(cityName: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { [weak self] (placemarks, error) in
            guard let strongSelf = self else { return }
            if let placemark = placemarks?.first, let location = placemark.location {
                strongSelf.destinationLocation = location.coordinate
                strongSelf.addAnnotationAtCoordinate(coordinate: location.coordinate)
                strongSelf.getDirections(transportType: .automobile)
            }
        }
    }
    
    private func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 50000/2, longitudinalMeters: 50000/2)
        mapView.setRegion(region, animated: true)
    }
    
    private func getDirections(transportType: MKDirectionsTransportType) {
        guard let startLocation = currentLocation, let endLocation = destinationLocation else { return }
        let startPlacemark = MKPlacemark(coordinate: startLocation)
        let endPlacemark = MKPlacemark(coordinate: endLocation)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = transportType
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let route = response?.routes.first {
                strongSelf.mapView.removeOverlays(strongSelf.mapView.overlays)
                strongSelf.mapView.addOverlay(route.polyline, level: .aboveRoads)
                let rect = route.polyline.boundingMapRect
                strongSelf.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                let distance = route.distance
                let distanceKm = distance / 1000
                let distanceString = String(format: "%.2f km", distanceKm)
                DispatchQueue.main.async {
                    strongSelf.appDelegate.saveDirection(cityName: endPlacemark.locality ?? "",
                                                         distance: distanceString,
                                                         from: "Map",
                                                         method: transportType == .automobile ? "Car" : "Walk",
                                                         startPoint: self?.currentCityName ?? "",
                                                         endPoint: self?.destinationCityName ?? "")
                }
            }
        }
    }
    
    // CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location.coordinate
            manager.stopUpdatingLocation()
            addAnnotationAtCoordinate(coordinate: location.coordinate)
            getCurrentCityName(for: location) { city in
                self.currentCityName = city ?? ""
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func getCurrentCityName(for location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error getting city name: \(error)")
                completion(nil)
            } else if let placemark = placemarks?.first {
                let city = placemark.locality
                completion(city)
            } else {
                print("Placemark not found")
                completion(nil)
            }
        }
    }

    
    @IBAction func carTapped(_ sender: Any) {
        getDirections(transportType: .automobile)
    }
    @IBAction func walkTapped(_ sender: Any) {
        getDirections(transportType: .walking)
    }
}
