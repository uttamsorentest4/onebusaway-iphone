//
//  WeatherCell.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 5/22/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    fileprivate static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    fileprivate static let titleFont = OBATheme.largeTitleFont!
    fileprivate static let summaryFont = OBATheme.footnoteFont!

    static var singleLineHeight: CGFloat {
        return titleFont.lineHeight + summaryFont.lineHeight + insets.top + insets.bottom
    }

    static func textHeight(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constrainedSize = CGSize(width: width - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [ NSAttributedStringKey.font: font ]
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let bounds = (text as NSString).boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
        return ceil(bounds.height) + insets.top + insets.bottom
    }

    fileprivate let temperatureLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.numberOfLines = 1
        label.font = WeatherCell.titleFont
        return label
    }()

    fileprivate let summaryLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.numberOfLines = 1
        label.font = WeatherCell.summaryFont
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(temperatureLabel)
        contentView.backgroundColor = OBATheme.mapTableBackgroundColor
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        temperatureLabel.frame = UIEdgeInsetsInsetRect(bounds, WeatherCell.insets)
    }

    var forecast: WeatherForecast? {
        didSet {
            guard let forecast = forecast else {
                return
            }
            let truncatedTemperature = Int(forecast.currentTemperature)
            temperatureLabel.text = "\(truncatedTemperature)º"
            summaryLabel.text = forecast.currentSummary
        }
    }
}

extension WeatherCell: ListBindable {

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? WeatherForecast else { return }
        let truncatedTemperature = Int(viewModel.currentTemperature)
        temperatureLabel.text = "\(truncatedTemperature)º"
        summaryLabel.text = viewModel.currentSummary
    }
}
