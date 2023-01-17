//
//  DayCardView.swift
//  CumulusWeather
//
//  Created by Joseph Szafarowicz on 9/1/22.
//

import UIKit

class DayCardView: UIView {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!
    @IBOutlet weak var lowTemperatureLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)!
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = CGFloat(GlobalVariables.sharedInstance.cornerRadius)
        setColor(view: self, value: defaults.integer(forKey: "color"))
    }
}

func setupDayCard(view: DayCardView, dayNumber: Int, data: FetchWeather) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let dayOfTheWeekString = dateFormatter.string(from: data.dailyForecastArray[dayNumber].day)
    
    let highTemp = Measurement(value: data.dailyForecastArray[dayNumber].highTemp, unit: UnitTemperature.celsius)
    let lowTemp = Measurement(value: data.dailyForecastArray[dayNumber].lowTemp, unit: UnitTemperature.celsius)
    if defaults.string(forKey: "temperatureUnits") == "F" {
        view.highTemperatureLabel.text = "\(Int(highTemp.converted(to: .fahrenheit).value))°"
        view.lowTemperatureLabel.text = "\(Int(lowTemp.converted(to: .fahrenheit).value))°"
    } else {
        view.highTemperatureLabel.text = "\(Int(highTemp.converted(to: .celsius).value))°"
        view.lowTemperatureLabel.text = "\(Int(lowTemp.converted(to: .celsius).value))°"
    }
    
    if dayNumber == 0 {
        view.dayLabel.text = "Today"
    } else {
        view.dayLabel.text = dayOfTheWeekString
    }

    view.precipitationLabel.text = "\(Int(data.dailyForecastArray[dayNumber].precipChance * 100))%"
    view.conditionImage.image = UIImage(systemName: "\(data.dailyForecastArray[dayNumber].symbol)")
}
