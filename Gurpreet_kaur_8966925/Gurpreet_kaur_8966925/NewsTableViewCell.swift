
import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    func setupCell(data: NewsData) {
        authorLabel.text = "Author: \(data.author ?? "")"
        sourceLabel.text = "Source: \(data.source ?? "")"
        titleLabel.text = "Title: \(data.title ?? "")"
        fromLabel.text = "From: \(data.from ?? "")"
        contentLabel.text = "Content: \(data.content ?? "")"
        cityNameLabel.text = "City Name: \(data.cityName ?? "")"
    }

}
