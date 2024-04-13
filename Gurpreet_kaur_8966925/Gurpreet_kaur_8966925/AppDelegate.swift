
import UIKit
import CoreData

enum DataType: String, CaseIterable {
    case directions = "DirectionsData"
    case news = "NewsData"
    case weather = "WeatherCoreData"
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        firstLaunchSetup()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Hitesh_kumra_8966327")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveDirection(cityName: String, distance: String, from: String, method: String, startPoint: String, endPoint: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let direction = DirectionsData(context: context)
        direction.cityName = cityName
        direction.distance = distance
        direction.from = from
        direction.method = method
        direction.dataType = DataType.directions.rawValue
        direction.startPoint = startPoint
        direction.endPoint = endPoint
        do {
            try context.save()
        } catch {
            print("Failed to save direction: \(error.localizedDescription)")
        }
    }

    func saveNews(author: String, cityName: String, content: String, from: String, source: String, title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let news = NewsData(context: context)
        news.author = author
        news.cityName = cityName
        news.content = content
        news.from = from
        news.source = source
        news.title = title
        news.dataType = DataType.news.rawValue

        do {
            try context.save()
        } catch {
            print("Failed to save news: \(error.localizedDescription)")
        }
    }

    func saveWeather(cityName: String, date: String, humidity: String, temp: String, time: String, wind: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let weather = WeatherCoreData(context: context)
        weather.cityName = cityName
        weather.date = date
        weather.humidity = humidity
        weather.temp = temp
        weather.time = time
        weather.wind = wind
        weather.dataType = DataType.weather.rawValue
        
        do {
            try context.save()
        } catch {
            print("Failed to save weather: \(error.localizedDescription)")
        }
    }

    func firstLaunchSetup() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            // Set the flag to true so this block doesn't get executed again
            defaults.set(true, forKey: "hasLaunchedBefore")
            defaults.synchronize()

            // List of cities to save
            let cities = ["Toronto", "Vancouver", "Montreal", "Calgary", "Ottawa"]

            // Sample data for demonstration purposes
            for city in cities {
                saveWeather(cityName: city, date: Date.getCurrentDate(), humidity: "60%", temp: "15°C", time: Date().currentTime(), wind: "5 km/h")
            }
        }
    }
}

func showCityInputAlert(on viewController: UIViewController, title: String, message: String, callback: @escaping (String) -> Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

    alertController.addTextField { textField in
        textField.placeholder = "City name"
    }

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        if let textField = alertController.textFields?.first, let cityName = textField.text {
            callback(cityName)
        }
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertController.addAction(okAction)
    alertController.addAction(cancelAction)

    viewController.present(alertController, animated: true)
}

func mapWeatherConditionToSymbol(_ id: Int) -> String {
    switch id {
    case 200...232: return "cloud.bolt.rain.fill"
    case 300...321: return "cloud.drizzle.fill"
    case 500...531: return "cloud.rain.fill"
    case 600...622: return "cloud.snow.fill"
    case 701...781: return "cloud.fog.fill"
    case 800: return "sun.max.fill"
    case 801...804: return "cloud.fill"
    default: return "questionmark.circle"
    }
}

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

extension Date {
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: Date())
    }
    
    func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
