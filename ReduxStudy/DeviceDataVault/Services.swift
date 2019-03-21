//
//  Services.swift
//  ReduxStudy
//
//  Created by Pusca Ghenadie on 03/03/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(Error)
}

protocol QueueService {
    func fetchQueueData(deviceId: UInt, completion: (Result<[QueuedApp]>) -> Void)
    func removeAppFromQueue(appId: String, completion: (Result<Void>) -> Void)
}

protocol StoreAppService {
    func fetchDownloadHistory(deviceid: UInt, completion: (Result<[StoreApp]>) -> Void)
    func fetchUpdates(deviceId: UInt, completion: (Result<[AppUpdate]>) -> Void)
}

protocol DeviceInfoService {
    func getDeviceData(deviceId: UInt, completion: (Result<DeviceInfo>) -> Void)
}

protocol SyncService {
    func syncDevice(deviceId: UInt, completion: (Result<Void>) -> Void)
}

protocol DeviceConnectionService {
    var onDeviceChange: (_ deviceId: UInt) -> Void { get set }
}
