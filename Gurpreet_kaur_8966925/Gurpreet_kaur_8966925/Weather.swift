

import UIKit

class Weather: UIViewController {

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.title = "Weather"
        fetchWeatherData(for: "Waterloo")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(rightBarButtonTapped))
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func rightBarButtonTapped() {
        showCityInputAlert(on: self, title: "Enter City Name", message: "Please enter the name of the city:") { [weak self] cityName in
            self?.fetchWeatherData(for: cityName)
        }
    }
    
    
    
    private func fetchWeatherData(for city: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=3ee1e322385410153c7856355e3dd3fb&units=metric") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let weatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    self?.updateUI(with: weatherData)
                }
            } catch {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func saveWeather(data: WeatherModel) {
        DispatchQueue.main.async {
            self.appDelegate.saveWeather(cityName: data.name,
                                    date: Date.getCurrentDate(),
                                    humidity: "\(data.main.humidity)%",
                                    temp: "\(Int(data.main.temp))°C",
                                    time: Date().currentTime(),
                                    wind: "\(data.wind.speed) km/h")
        }
    }
    
    private func updateUI(with weatherData: WeatherModel) {
        cityName.text = weatherData.name
        descLabel.text = weatherData.weather.first?.description ?? "N/A"
        tempLabel.text = "\(Int(weatherData.main.temp))°C"
        humidityLabel.text = "Humidity: \(weatherData.main.humidity)%"
        windLabel.text = "Wind: \(weatherData.wind.speed) km/h"
        
        saveWeather(data: weatherData)
    }
}
