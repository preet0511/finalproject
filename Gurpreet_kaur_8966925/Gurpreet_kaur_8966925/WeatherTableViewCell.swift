
import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var cityName: UILabel!
    

    func setup(data: WeatherCoreData) {
        windLabel.text = "Wind: \(data.wind ?? "")"
        humidityLabel.text = "Humidity: \(data.humidity ?? "")"
        tempratureLabel.text = "Temp: \(data.temp ?? "")"
        timeLabel.text = "Time: \(data.time ?? "")"
        dateLabel.text = data.date ?? ""
        fromLabel.text = data.from ?? ""
        cityName.text = data.cityName ?? ""
    }
}
