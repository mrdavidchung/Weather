//
//  DetailViewController.swift
//  Weather
//
//  Created by David Chung on 8/1/18.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var spacerView1: UIView!
    @IBOutlet weak var spacerView2: UIView!
    
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    
    var detailItem: CityWeather? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @objc
    func clear()
    {
        if let label = humidity {
            label.text = ""
        }
        if let label = pressure {
            label.text = ""
        }
        if let label = high {
            label.text = ""
        }
        if let label = low {
            label.text = ""
        }
        if let label = placeLabel {
            label.text = ""
        }
        if let label = temperatureLabel {
            label.text = ""
        }
        if let label = humidityLabel {
            label.text = ""
        }
        if let label = pressureLabel {
            label.text = ""
        }
        if let label = lowLabel {
            label.text = ""
        }
        if let label = highLabel {
            label.text = ""
        }
        if let label = lastUpdatedLabel {
            label.text = ""
        }
    }
    
    @objc
    func configureView()
    {
        // Update the user interface for the detail item.
        if let detail = detailItem
        {
            if let label = humidity {
                label.text = "Humidity"
            }
            if let label = pressure {
                label.text = "Pressure"
            }
            if let label = high {
                label.text = "High"
            }
            if let label = low {
                label.text = "Low"
            }
            if let label = placeLabel {
                label.text = detail.place()
            }
            if let label = temperatureLabel {
                label.text = detail.temperature + "°"
            }
            if let label = humidityLabel {
                label.text = detail.humidity + "%"
            }
            if let label = pressureLabel {
                label.text = detail.pressure + " inHg"
            }
            if let label = lowLabel {
                label.text = detail.low + "°"
            }
            if let label = highLabel {
                label.text = detail.high + "°"
            }
            if let label = lastUpdatedLabel {
                label.text = "Last Updated: " + DateFormatter.localizedString(from: detail.lastUpdated, dateStyle: .medium, timeStyle: .long)
            }
        } else {
            clear()
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        NotificationCenter.default.addObserver(self, selector: #selector(clear), name: Notification.Name.init("ClearDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configureView), name: Notification.Name.init("UpdateDetails"), object: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        self.adjustLayout()
    }
    
    func adjustLayout()
    {
        if self.traitCollection.verticalSizeClass == .compact
        {
            if let stackView = mainStackView {
                stackView.axis = .horizontal
            }
            if let view = spacerView1 {
                view.isHidden = true
            }
            if let view = spacerView2 {
                view.isHidden = false
            }
        } else {
            if let stackView = mainStackView {
                stackView.axis = .vertical
            }
            if let view = spacerView1 {
                view.isHidden = false
            }
            if let view = spacerView2 {
                view.isHidden = true
            }
        }
    }
}

