//
//  StopViewModel.swift
//  OneBusAway
//
//  Created by Aaron Brethorst on 5/23/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit
import IGListKit

class StopViewModel: NSObject {
    let name: String
    let stopID: String
    let direction: String

    init(name: String, stopID: String, direction: String) {
        self.name = name
        self.stopID = stopID
        self.direction = direction
        super.init()
    }
}

// MARK: - Helpers
extension StopViewModel {
    var nameWithDirection: String {
        get {
            return "\(name) (\(direction))"
        }
    }
}

// MARK: - ListDiffable
extension StopViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return "stop_\(stopID)" as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? StopViewModel else { return false }
        return name == object.name && stopID == object.stopID && direction == object.direction
    }
}
