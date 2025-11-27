//
//  Date+TimeAgo.swift
//  ShareARecipe
//
//  Created by user286005 on 11/17/25.
//

import Foundation

public func timeAgoSince(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter.localizedString(for: date, relativeTo: Date())
}

