//
//  MasterViewController.swift
//  Weather
//
//  Created by David Chung on 8/1/18.
//

import UIKit
import CoreLocation
import Contacts
import OpenWeatherSwift
import SwiftyJSON

class CityListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temperature: UILabel!
}

class MasterViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var detailViewController: DetailViewController? = nil
    var objects = [CityWeather]()
    var searchBar: UISearchBar? = nil

    let locationManager = CLLocationManager()
    var currentZip: String = ""
    var currentCity: String = ""
    var currentState: String = ""
    
    let updateInterval: Double = 15
    var updateTimer: Timer?
    
    var weatherAPI =  OpenWeatherSwift(apiKey: "760398a616c967ff3806790d24617ca4", temperatureFormat: .Fahrenheit)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCurrentLocation(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        searchBar = UISearchBar.init()
        searchBar?.keyboardType = UIKeyboardType.numbersAndPunctuation
        searchBar?.enablesReturnKeyAutomatically = true
        searchBar?.placeholder = "Enter Zip Code"
        searchBar?.delegate = self
        navigationItem.titleView = self.searchBar
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .notDetermined
        {
            locationManager.requestWhenInUseAuthorization()
        } else {
            if CLLocationManager.locationServicesEnabled()
            {
                locationManager.requestLocation()
            }
        }

        loadCityData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)

        self.updateWeatherInCities()
        updateTimer = Timer.scheduledTimer(timeInterval: updateInterval*60, target: self, selector: #selector(updateWeatherInCities), userInfo: nil, repeats: true)
        
        if (objects.count > 0)
        {
            detailViewController?.detailItem = objects[0]
        }
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Data
    
    func saveCityData()
    {
        let data = NSKeyedArchiver.archivedData(withRootObject: self.objects)
        UserDefaults.standard.set(data, forKey: "cities")
    }
    
    func loadCityData()
    {
        if let data = UserDefaults.standard.object(forKey: "cities") as? Data {
            if let cities = NSKeyedUnarchiver.unarchiveObject(with: data) {
                self.objects = cities as! [CityWeather]
            }
        } else {
            // first run, pre-populate some major cities
            self.addPlaceToList("Los Angeles", "CA", "90001")
            self.addPlaceToList("Las Vegas", "NV", "89135")
            self.addPlaceToList("New York", "NY", "10001")
            self.addPlaceToList("Dallas", "TX", "75201")
            self.addPlaceToList("Chicago", "IL", "60601")
            self.addPlaceToList("Atlanta", "GA", "30301")
        }
    }
    
    // MARK: -
    
    @objc
    func updateWeatherInCities()
    {
        for city in self.objects
        {
            if city.lastUpdated.addingTimeInterval(updateInterval*60) < Date()
            {
                self.updateWeatherWithAPI(city.zip)
                print("Updated \(city.place()) : \(city.lastUpdated.convertToString())")
            }
        }
    }
    
    @objc
    func addCurrentLocation(_ sender: Any)
    {
        if self.currentZip.isEmpty
        {
            let alertMessage = UIAlertController.init(title: "Still Locating", message: "Try again in a little bit", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alertMessage.addAction(okAction)
            self.present(alertMessage, animated: true, completion: nil)
        } else {
            self.addPlaceToList(currentCity, currentState, currentZip)
        }
    }
    
    func addPlaceToList(_ city: String, _ state: String, _ zip: String)
    {
        let result = objects.filter { $0.place() == "\(city), \(state)"}
        
        if result.isEmpty
        {
            let cityWeather = CityWeather()
            cityWeather.city = city
            cityWeather.state = state
            cityWeather.zip = zip
            
            objects.insert(cityWeather, at: 0)
            
            self.updateWeatherWithAPI(zip)
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)

            searchBar?.text = ""

        } else {
            // warning message
            let alertMessage = UIAlertController.init(title: "Could Not Add", message: "\(city), \(state) is already in the list", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alertMessage.addAction(okAction)
            self.present(alertMessage, animated: true, completion: nil)
        }
    }
    
    func updateWeatherWithAPI(_ zip: String)
    {
        weatherAPI.currentWeatherByZIP(code: zip, countryCode: "us", completionHandler: { (result) in
        
            let weather = Weather(data: result as! JSON)
            let weatherResults = self.objects.filter { $0.zip == zip}
            
            if !weatherResults.isEmpty
            {
                weatherResults[0].temperature = String(weather.temperature)
                weatherResults[0].humidity = String(weather.humidity)
                weatherResults[0].pressure = String(format: "%.2f", Double(weather.airPressure) * 0.029529983071445)
                weatherResults[0].high = String(weather.high)
                weatherResults[0].low = String(weather.low)
                weatherResults[0].lastUpdated = Date.init()
                
                self.tableView.reloadData()
                self.saveCityData()
                
                if (self.objects.count > 0)
                {
                    self.detailViewController?.detailItem = self.objects[0]
                }
            }
        })
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showDetail"
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedAlways || status == .authorizedWhenInUse
        {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        CLGeocoder().reverseGeocodeLocation(locations.first!, completionHandler: {(placemarks, error) -> Void in
            if error != nil
            {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count == 1
            {
                let pm = placemarks![0]
                self.currentZip = pm.postalCode!
                self.currentState = pm.administrativeArea!
                self.currentCity = pm.locality!
                self.locationManager.stopUpdatingLocation()
                
            } else if placemarks!.count > 1 {
                print("More than 1 place")
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
   {
        print("Location Manager Fail: \(error)")
    }
    
    // MARK: - Search Delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        self.addCityAndStateForZip(searchBar.text)
     }
    
    func addCityAndStateForZip(_ zip: String?)
    {
        // add city & state cell
        CLGeocoder().geocodeAddressString(zip!, completionHandler: { (placemarks, error) in
            
            if let marks = placemarks
            {
                if marks.count > 1
                {
                    print("more than 1 city")
                }
                else if marks.count == 1
                {
                    if let result = placemarks?.first
                    {
                        guard let city = result.locality, let state = result.administrativeArea else
                        {
                            // bad results
                            self.showNoLocationAlert()
                            return
                        }
                        self.addPlaceToList(city, state, zip!)
                        return
                    }
                }
            }
            self.showNoLocationAlert()
        })
    }
    
    func showNoLocationAlert()
    {
        let alertMessage = UIAlertController.init(title: "Could Not Locate", message: "No city associated with that Zip", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alertMessage.addAction(okAction)
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CityListTableViewCell

        let object = objects[indexPath.row]
        cell.cityName?.text = object.place()
        cell.temperature?.text = object.temperature + "° F"

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        let movingCityWeather = objects[sourceIndexPath.row]
        objects.remove(at: sourceIndexPath.row)
        objects.insert(movingCityWeather, at: proposedDestinationIndexPath.row)
        saveCityData()
        return proposedDestinationIndexPath
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveCityData()
            clearDetailItem()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func clearDetailItem()
    {
        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "ClearDetails"), object: nil))
    }

}

