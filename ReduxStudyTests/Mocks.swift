//
//  Mocks.swift
//  ReduxStudyTests
//
//  Created by Pusca Ghenadie on 03/03/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation
@testable import ReduxStudy

class QueueServiceMock: QueueService {
    var fetchingForDeviceId: UInt = 0
    var fetchResponse: Result<[QueuedApp]> = .error(NSError())
    
    var removingAppWithId: String = ""
    var removeAppResponse: Result<Void> = .error(NSError())
    
    func fetchQueueData(deviceId: UInt, completion: (Result<[QueuedApp]>) -> Void) {
        fetchingForDeviceId = deviceId
        completion(fetchResponse)
    }
    
    func removeAppFromQueue(appId: String, completion: (Result<Void>) -> Void) {
        removingAppWithId = appId
        completion(removeAppResponse)
    }
}

class DeviceInfoServiceMock: DeviceInfoService {
    var fetchingDataForDeviceId: UInt = 0
    var fetchResponse: Result<DeviceInfo> = .error(NSError())
    
    var uninstallingForDeviceId: UInt = 0
    var uninstallingAppWithId: String = ""
    var uninstallingResponse: Result<Void> = .error(NSError())

    func getDeviceData(deviceId: UInt, completion: (Result<DeviceInfo>) -> Void) {
        fetchingDataForDeviceId = deviceId
        completion(fetchResponse)
    }
    
    func uninstallApp(deviceId: UInt, appId: String, completion: (Result<Void>) -> Void) {
        uninstallingForDeviceId = deviceId
        completion(uninstallingResponse)
    }
}

class StoreServiceMock: StoreAppService {    
    var fetchingDownloadHistoryForDeviceId: UInt = 0
    var fetchDownloadHistoryResponse: Result<[StoreApp]> = .error(NSError())

    var fetchingUpdatesForDeviceId: UInt = 0
    var fetchUpdatesResponse: Result<[AppUpdate]> = .error(NSError())
    
    var installingAppForDeviceId: UInt = 0
    var installingAppWithId: String = ""
    var installingAppResponse: Result<Void> = .error(NSError())

    var updatingAppForDeviceId: UInt = 0
    var updatingAppWithId: String = ""
    var updatingAppResponse: Result<Void> = .error(NSError())
    
    var deletingAppForDeviceId: UInt = 0
    var deletingAppWithId: String = ""
    var deletingAppResponse: Result<Void> = .error(NSError())
    
    func fetchDownloadHistory(deviceid: UInt, completion: (Result<[StoreApp]>) -> Void) {
        fetchingDownloadHistoryForDeviceId = deviceid
        completion(fetchDownloadHistoryResponse)
    }
    
    func fetchUpdates(deviceId: UInt, completion: (Result<[AppUpdate]>) -> Void) {
        fetchingUpdatesForDeviceId = deviceId
        completion(fetchUpdatesResponse)
    }
    
    func installApp(deviceId: UInt, appId: String, completion: (Result<Void>) -> Void) {
        installingAppForDeviceId = deviceId
        installingAppWithId = appId
        completion(installingAppResponse)
    }
    
    func deleteApp(deviceId: UInt, appId: String, completion: (Result<Void>) -> Void) {
        deletingAppForDeviceId = deviceId
        deletingAppWithId = appId
        completion(deletingAppResponse)
    }
    
    func updateApp(deviceId: UInt, appId: String, completion: (Result<Void>) -> Void) {
        updatingAppForDeviceId = deviceId
        updatingAppWithId = appId
        completion(updatingAppResponse)
    }
}

class SyncServiceMock: SyncService {
    var syncStartedForDeviceId: UInt = 0
    var syncResult: Result<Void> = .error(NSError())
    func syncDevice(deviceId: UInt, completion: (Result<Void>) -> Void) {
        syncStartedForDeviceId = deviceId
        completion(syncResult)
    }
}

class DeviceConnectionServiceMock: DeviceConnectionService {
    var onDeviceChange: (UInt) -> Void = { _ in }
}
