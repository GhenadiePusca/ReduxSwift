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
        let midlewareApi = MiddlewareContext(dispatchFunction: dispatchFunction,
                                             state: { [weak self] in self?.data })
        middlewares.forEach { middleware in
            middleware(action, midlewareApi)
        }
        data = reducer(state: data, action: action)
    }

    func subscribe(_ subcribtion: Subscription) {
        subscriptions.append(contentsOf: subscriptions)
    }

    private func reducer(state: DeviceSettingsData,
                         action: DeviceDataVaultAction) -> DeviceSettingsData {
        return DeviceSettingsData(queuedApps: queuedAppReducer(state.queuedApps, action),
                                  deviceInfo: deviceInfoReducer(state.deviceInfo, action),
                                  storeApps: storeAppsReducer(state.storeApps, action),
                                  appUpdates: appUpdatesReducer(state.appUpdates, action))
    }
    
    private func queuedAppReducer(_ state: Loadable<[QueuedApp]>,
                                  _ action: DeviceDataVaultAction) -> Loadable<[QueuedApp]> {
        switch action {
        case .setQueueApps(let value):
            return value
        default:
            return state
        }
    }
    
    private func deviceInfoReducer(_ state: Loadable<DeviceInfo>,
                                  _ action: DeviceDataVaultAction) -> Loadable<DeviceInfo> {
        switch action {
        case .setDeviceInfo(let value):
            return value
        default:
            return state
        }
    }
    
    private func storeAppsReducer(_ state: Loadable<[StoreApp]>,
                                   _ action: DeviceDataVaultAction) -> Loadable<[StoreApp]> {
        switch action {
        case .setStoreApps(let value):
            return value
        case .appDeleted(_, let appId):
            guard case .value(let storeApps) = state else {
                return state
            }
            
            return .value(storeApps.filter { $0.id != appId })
        default:
            return state
        }
    }
    
    private func appUpdatesReducer(_ state: Loadable<[AppUpdate]>,
                                  _ action: DeviceDataVaultAction) -> Loadable<[AppUpdate]> {
        switch action {
        case .setAppUpdates(let value):
            return value
        case .appUninstalled(_, let appId):
            guard case .value(let appUpdates) = state else {
                return state
            }
            
            return .value(appUpdates.filter { $0.id != appId })
        default:
            return state
        }
    }
}
