//
//  ViewController.swift
//  WetherOrNot
//
//  Created by Joseph Szafarowicz on 7/18/22.
//

import UIKit
import CoreLocation

class ForecastVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var currentAlertsStackView: UIStackView!
    
    @IBOutlet weak var currentCardView: CurrentCardView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var currentSubheadCardView0: CurrentSubheadCardView!
    @IBOutlet weak var currentSubheadCardView1: CurrentSubheadCardView!
    @IBOutlet weak var currentSubheadCardView2: CurrentSubheadCardView!
    @IBOutlet weak var currentSubheadCardView3: CurrentSubheadCardView!
    
    @IBOutlet weak var day0CardView: DayCardView!
    @IBOutlet weak var day1CardView: DayCardView!
    @IBOutlet weak var day2CardView: DayCardView!
    @IBOutlet weak var day3CardView: DayCardView!
    @IBOutlet weak var day4CardView: DayCardView!
    @IBOutlet weak var day5CardView: DayCardView!
    @IBOutlet weak var day6CardView: DayCardView!
    @IBOutlet weak var day7CardView: DayCardView!
    @IBOutlet weak var day8CardView: DayCardView!
    @IBOutlet weak var day9CardView: DayCardView!
    
    @IBOutlet weak var currentSubheadCardConstraintTop: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    var fetcher = FetchWeather()
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSpinnerView()
        
        let locationTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.locationLabelTapped(_:)))
        self.locationNameLabel.addGestureRecognizer(locationTapGesture)
        
        let alertTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.alertLabelTapped(_:)))
        self.alertLabel.addGestureRecognizer(alertTapGesture)
        
        if CurrentAlerts.sharedInstance.isEmpty == false {
            currentAlertsStackView.isHidden = false
        } else {
            currentAlertsStackView.isHidden = true
        }
        
        if defaults.string(forKey: "recommendations") == "off" {
            descriptionLabel.isHidden = true
            currentSubheadCardConstraintTop.constant = -40
        } else {
            descriptionLabel.isHidden = false
            currentSubheadCardConstraintTop.constant = 40
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("User location found.", latitude, longitude)
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
                if let locationName = placeMark.locality  {
                    self.locationNameLabel.text = locationName
                }
            })
            
            self.locationManager.stopUpdatingLocation()
            DispatchQueue.main.async {
                Task {
                    await self.fetcher.fetch(vc: ForecastVC(),latitude: latitude, longitude: longitude)

                    setupCurrentCard(view: self.currentCardView)
                    setupCurrentSubheadCard(view: self.currentSubheadCardView0, type: "Wind")
                    setupCurrentSubheadCard(view: self.currentSubheadCardView1, type: "UV Index")
                    setupCurrentSubheadCard(view: self.currentSubheadCardView2, type: "Humidity")
                    setupCurrentSubheadCard(view: self.currentSubheadCardView3, type: "Pressure")
                    self.descriptionLabel.text = GlobalVariables.sharedInstance.description

                    setupDayCard(view: self.day0CardView, dayNumber: 0, data: self.fetcher)
                    setupDayCard(view: self.day1CardView, dayNumber: 1, data: self.fetcher)
                    setupDayCard(view: self.day2CardView, dayNumber: 2, data: self.fetcher)
                    setupDayCard(view: self.day3CardView, dayNumber: 3, data: self.fetcher)
                    setupDayCard(view: self.day4CardView, dayNumber: 4, data: self.fetcher)
                    setupDayCard(view: self.day5CardView, dayNumber: 5, data: self.fetcher)
                    setupDayCard(view: self.day6CardView, dayNumber: 6, data: self.fetcher)
                    setupDayCard(view: self.day7CardView, dayNumber: 7, data: self.fetcher)
                    setupDayCard(view: self.day8CardView, dayNumber: 8, data: self.fetcher)
                    setupDayCard(view: self.day9CardView, dayNumber: 9, data: self.fetcher)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("User location not found.")
    }
    
    func createSpinnerView() {
        let child = SpinnerViewController()

        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    @objc func locationLabelTapped(_ sender: UITapGestureRecognizer) {
        print("test")
    }
    
    @objc func alertLabelTapped(_ sender: UITapGestureRecognizer) {
        let alert = CurrentAlerts.sharedInstance.detailsURL
        if alert.isEmpty == false {
            if let url = URL(string: alert) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
}

