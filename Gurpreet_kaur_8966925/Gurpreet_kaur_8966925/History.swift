
import UIKit
import CoreData

class History: UITableViewController {
    
    var dataSource: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DataType.allCases.forEach { type in
            fetchRecordsAndProcess(entityType: type.rawValue)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataObject = dataSource[indexPath.row]
        
        if let directionsData = dataObject as? DirectionsData {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell", for: indexPath) as? MapTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setup(data: directionsData)
            return cell
            
        } else if let newsData = dataObject as? NewsData {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell else { return UITableViewCell() }
            cell.setupCell(data: newsData)
            cell.selectionStyle = .none
            return cell
            
        } else if let weatherData = dataObject as? WeatherCoreData {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell else { return UITableViewCell() }
            cell.setup(data: weatherData)
            cell.selectionStyle = .none
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let objectToDelete = dataSource.remove(at: indexPath.row)
            
            let context = appDelegate.persistentContainer.viewContext
            context.delete(objectToDelete as! NSManagedObject)
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save after delete. \(error), \(error.userInfo)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func fetchRecordsAndProcess(entityType: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityType)
        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { result in
                dataSource.append(result)
            }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
