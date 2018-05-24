//
//  ForecastCell.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 5/22/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import OBAKit
import UIKit
import SnapKit

class ForecastCell: SelfSizingCollectionCell {

    // MARK: - Properties
    fileprivate static let titleFont = OBATheme.largeTitleFont!
    fileprivate static let summaryFont = OBATheme.footnoteFont!

    fileprivate let temperatureLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.numberOfLines = 1
        label.font = ForecastCell.titleFont
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    fileprivate let summaryLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.numberOfLines = 1
        label.font = ForecastCell.summaryFont
        return label
    }()

    fileprivate let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        let labelStack = UIStackView.init(arrangedSubviews: [temperatureLabel, summaryLabel, UIView()])
        labelStack.axis = .vertical
        let labelWrapper = labelStack.oba_embedInWrapper()

        let outerStack = UIStackView.init(arrangedSubviews: [weatherImageView, labelWrapper])
        outerStack.axis = .horizontal
        let outerWrapper = outerStack.oba_embedInCardWrapper()

        contentView.addSubview(outerWrapper)
        outerWrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(OBATheme.defaultEdgeInsets)
        }

        contentView.backgroundColor = OBATheme.mapTableBackgroundColor

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 0.2
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Data Loading

    var forecast: WeatherForecast? {
        didSet {
            guard let forecast = forecast else {
                return
            }
            let truncatedTemperature = Int(forecast.currentTemperature)
            temperatureLabel.text = "\(truncatedTemperature)º"
            summaryLabel.text = forecast.currentSummary
            weatherImageView.image = UIImage(named: forecast.currentSummaryIconName)
        }
    }
}
