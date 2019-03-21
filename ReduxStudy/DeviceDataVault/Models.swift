//
//  Models.swift
//  ReduxStudy
//
//  Created by Pusca Ghenadie on 02/03/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

enum Loadable<T> {
    case initial
    case loading
    case value(T)
    case error(Error)
    
    var isInitial: Bool {
        switch self {
        case .initial:
            return true
        default:
            return false
        }
    }
    
    var data: T? {
        switch self {
        case .value(let data):
            return data
        default:
            return nil
        }
    }
}

struct QueuedApp {
    let id: String
}

struct DeviceInfo {
    let space: String
    let apps: [String] // app ids
}

struct StoreApp {
    let id: String
}

struct AppUpdate {
    let id: String
}

struct DeviceSettingsData {
    let queuedApps: Loadable<[QueuedApp]>
    let deviceInfo: Loadable<DeviceInfo>
    let storeApps: Loadable<[StoreApp]>
    let appUpdates: Loadable<[AppUpdate]>
}
