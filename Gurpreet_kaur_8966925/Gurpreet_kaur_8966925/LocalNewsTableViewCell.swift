
import UIKit

class LocalNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    func setupUI(article: Article) {
        authorLabel.text = "Author: \(article.author ?? "Unknown")"
        sourceLabel.text = "Source: \(article.source?.name ?? "")"
        titleLabel.text = "Title: \(article.title ?? "")"
        contentLabel.text = "Content: \(article.description ?? "")"
    }
}
