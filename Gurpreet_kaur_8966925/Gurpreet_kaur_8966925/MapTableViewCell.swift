

import UIKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var distanceTravelledLabel: UILabel!
    @IBOutlet weak var methodOfTavel: UILabel!
    @IBOutlet weak var endPointLabel: UILabel!
    @IBOutlet weak var startPointLabel: UILabel!
    
    func setup(data: DirectionsData) {
        cityName.text = data.cityName ?? ""
        distanceTravelledLabel.text = data.distance ?? ""
        methodOfTavel.text = data.method
        endPointLabel.text = data.endPoint ?? ""
        startPointLabel.text = data.startPoint ?? ""
    }
}
