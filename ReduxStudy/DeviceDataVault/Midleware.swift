//
//  Midleware.swift
//  ReduxStudy
//
//  Created by Pusca Ghenadie on 03/03/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

typealias Middleware = (DeviceDataVaultAction, MiddlewareContext) -> Void

struct MiddlewareContext {
    let dispatchFunction: DispatchFunction
    let state: () -> DeviceSettingsData?
}

fileprivate func fetchQueue(queueAppService: QueueService, deviceId: UInt, dispatch: DispatchFunction) {
    dispatch(.setQueueApps(.loading))
    queueAppService.fetchQueueData(deviceId: deviceId, completion: { result in
        let state: Loadable<[QueuedApp]>
        switch result {
        case .success(let data): state = .value(data)
        case .error(let error): state = .error(error)
        }
        dispatch(.setQueueApps(state))
    })
}

fileprivate func fetchDownloadHistory(storeAppService: StoreAppService,
                                      deviceId: UInt,
                                      dispatch: DispatchFunction) {
    dispatch(.setStoreApps(.loading))
    storeAppService.fetchDownloadHistory(deviceid: deviceId, completion: { result in
        let state: Loadable<[StoreApp]>
        switch result {
        case .success(let data): state = .value(data)
        case .error(let error): state = .error(error)
        }
        dispatch(.setStoreApps(state))
    })
}

fileprivate func fetchDeviceData(deviceInfoService: DeviceInfoService,
                                 deviceId: UInt,
                                 dispatch: DispatchFunction) {
    dispatch(.setDeviceInfo(.loading))
    deviceInfoService.getDeviceData(deviceId: deviceId, completion: { result in
        let state: Loadable<DeviceInfo>
        switch result {
        case .success(let data): state = .value(data)
        case .error(let error): state = .error(error)
        }
        dispatch(.setDeviceInfo(state))
    })
}

fileprivate func syncDevice(deviceId: UInt,
                            syncService: SyncService,
                            queueAppService: QueueService,
                            deviceInfoService: DeviceInfoService,
                            dispatch: DispatchFunction) {
    syncService.syncDevice(deviceId: deviceId, completion: { result in
        switch result {
        case .success:
            fetchQueue(queueAppService: queueAppService, deviceId: deviceId, dispatch: dispatch)
            fetchDeviceData(deviceInfoService: deviceInfoService, deviceId: deviceId, dispatch: dispatch)
        case .error:
            break
        }
    })
}

func appDidUploadToQueue(storeAppService: StoreAppService,
                         queueAppService: QueueService,
                         deviceInfoService: DeviceInfoService,
                         syncService: SyncService) -> Middleware {
    return { action, context in
        guard case .appDidUploadToQueue(let deviceId, let appId) = action else {
            return
        }
        
        let appInDownloadHistory = context.state()?.storeApps.data?.contains { $0.id == appId } ?? false

        if !appInDownloadHistory {
            fetchDownloadHistory(storeAppService: storeAppService, deviceId: deviceId, dispatch: context.dispatchFunction)
        }
        fetchQueue(queueAppService: queueAppService, deviceId: deviceId, dispatch: context.dispatchFunction)
        syncDevice(deviceId: deviceId,
                   syncService: syncService,
                   queueAppService: queueAppService,
                   deviceInfoService: deviceInfoService,
                   dispatch: context.dispatchFunction)
    }
}

func appUninstalled(queueAppService: QueueService,
                    deviceInfoService: DeviceInfoService) -> Middleware {
    return { action, context in
        guard case .appUninstalled(let deviceId, _) = action else {
            return
        }
        fetchDeviceData(deviceInfoService: deviceInfoService,
                        deviceId: deviceId,
                        dispatch: context.dispatchFunction)
    }
}

func deviceDidChange(storeAppService: StoreAppService,
                     queueAppService: QueueService,
                     deviceInfoService: DeviceInfoService) -> Middleware {
    return { action, context in
        guard case .deviceDidChange(let deviceId) = action else {
            return
        }
        
        fetchQueue(queueAppService: queueAppService,
                   deviceId: deviceId,
                   dispatch: context.dispatchFunction)
        fetchDownloadHistory(storeAppService: storeAppService,
                             deviceId: deviceId,
                             dispatch: context.dispatchFunction)
        fetchDeviceData(deviceInfoService: deviceInfoService,
                        deviceId: deviceId,
                        dispatch: context.dispatchFunction)

    }
}

func deviceDidSync(storeAppService: StoreAppService,
                   queueAppService: QueueService,
                   deviceInfoService: DeviceInfoService) -> Middleware {
    return { action, context in
        guard case .deviceDidSync(let deviceId) = action else {
            return
        }
        
        fetchQueue(queueAppService: queueAppService, deviceId: deviceId, dispatch: context.dispatchFunction)
        fetchDeviceData(deviceInfoService: deviceInfoService, deviceId: deviceId, dispatch: context.dispatchFunction)
    }
}
