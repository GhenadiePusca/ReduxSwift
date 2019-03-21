//
//  DeviceDataVault.swift
//  ReduxStudy
//
//  Created by Pusca Ghenadie on 03/03/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import Foundation

enum DeviceDataVaultAction {
    case deviceDidChange(deviceId: UInt)
    case deviceDidSync(deviceId: UInt)
    case appDidUploadToQueue(deviceId: UInt, appId: String)
    case appUninstalled(deviceId: UInt, appId: String)
    case appDeleted(deviceId: UInt, appId: String)
    case setQueueApps(Loadable<[QueuedApp]>)
    case setDeviceInfo(Loadable<DeviceInfo>)
    case setStoreApps(Loadable<[StoreApp]>)
    case setAppUpdates(Loadable<[AppUpdate]>)
}

typealias DispatchFunction = (DeviceDataVaultAction) -> Void

final class DeviceDataVault {
    typealias Subscription = (DeviceSettingsData) -> Void

    private var subscriptions = [Subscription]()

    private var data = DeviceSettingsData(queuedApps: .initial,
                                           deviceInfo: .initial,
                                           storeApps: .initial,
                                           appUpdates: .initial)
    {
        didSet {
            subscriptions.forEach { $0(data) }
        }
    }
    
    private let middlewares: [Middleware]
    init(middlewares: [Middleware]) {
        self.middlewares = middlewares
    }
    
    func dispatch(action: DeviceDataVaultAction) {
        let midlewareApi = MiddlewareContext(dispatchFunction: { [weak self] in
            self?.dispatch(action: $0)
        },
                                             state: { [weak self] in self?.data })
        middlewares.forEach { middleware in
            middleware(action, midlewareApi)
        }
        data = reducer(state: data, action: action)
    }

    func subscribe(_ subcribtion: Subscription) {
        subscriptions.append(contentsOf: subscriptions)
    }
}
