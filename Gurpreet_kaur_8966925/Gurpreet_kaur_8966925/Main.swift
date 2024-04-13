
import UIKit
import MapKit

class Main: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "My Final", style: .plain, target: nil, action: nil)
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    @IBAction func button3Tapped(_ sender: UIButton) {
        performSegue(withIdentifier: "gotoTab", sender: sender)
    }
    
    @IBAction func button2Tapped(_ sender: UIButton) {
        performSegue(withIdentifier: "gotoTab", sender: sender)
    }
    
    
    @IBAction func button1Tapped(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? UIButton else { return }
        if sender.tag == 2 {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
            }
        } else if sender.tag == 3 {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 2
            }
        }
    }
    
    private func updateUI(with data: WeatherModel) {
        tempratureLabel.text = "\(Int(data.main.temp))°C"
        windLabel.text = "Wind: \(data.wind.speed)Km/h"
        humidityLabel.text = "Humidity: \(data.main.humidity)"
        weatherImageView.image = UIImage(systemName: mapWeatherConditionToSymbol(data.weather.first?.id ?? 0))
    }
}


extension Main: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let hide = (viewController is Main)
        navigationController.setNavigationBarHidden(hide, animated: animated)
    }
}

extension Main: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        fetchWeatherData(for: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fetching location: \(error.localizedDescription)")
    }
    
    private func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        let apiKey = "3ee1e322385410153c7856355e3dd3fb"
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)&units=metric")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherModel.self, from: data)
                
                DispatchQueue.main.async {
                    self?.updateUI(with: weatherData)
                }
            } catch {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }.resume()
    }
}
