//
//  ReduxStudyTests.swift
//  ReduxStudyTests
//
//  Created by Pusca Ghenadie on 21/02/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import XCTest
@testable import ReduxStudy

/*
 - Identify models:
    - Device space and device apps for the device id
    - The download history for the device id
    - The queued apps for the device id
    - The available updates for the device id.
 
 - Mutate Actions:
    - Change the device -> - Need to refresh all the models.
                           - Refetch all the data
    - Device sync is done -> - The queue is consumed, refresh the queue
                             - The device apps and device space did update, refresh device info
                             - Refresh the updates list after the device info is refreshed.
                             - Download history should remain the same.
    - App uploaded to queue -> - The app is uploaded to queue (refetch the queue)
                               - If the app id is not in donwloaded apps refetch the downloaded history
                               - Sync with the device.
    - Uninstall app -> - The app is deleted from the device, refetch the device info.
                       - The download history remains the same.
                       - Remove the app for updates list if the app did have an update prior
                         to uninstalling.
                       - If an update was uploaded to queue for the uninstalled device,
                         remove the app from queue.
    - App deleted -> - Delete app from download history.
 
 - Services needed:
   - Current selected device provider.
   - Sync completion provider.
   - Install/delete/update api ops provider.
   - Uninstall app from device op provider.
 
 */
class ReduxStudyTests: XCTestCase {
    
    func testInitialStateIsCorrect() {
        let sut = DeviceDataVault(queueService: QueueServiceMock(),
                                  storeAppsService: StoreServiceMock(),
                                  deviceInfoService: DeviceInfoServiceMock(),
                                  syncService: SyncServiceMock(),
                                  deviceConnectionService: DeviceConnectionServiceMock())

        let data = sut.data
        XCTAssert(data.queuedApps.isInitial)
        XCTAssert(data.deviceInfo.isInitial)
        XCTAssert(data.storeApps.isInitial)
        XCTAssert(data.appUpdates.isInitial)
    }
    
    func testDeviceChanged_refreshCallsAreMade() {
        let queueService = QueueServiceMock()
        let storeService = StoreServiceMock()
        let deviceInfoService = DeviceInfoServiceMock()
        let syncService = SyncServiceMock()
        let deviceConnectionService = DeviceConnectionServiceMock()
        
        let sut = DeviceDataVault(queueService: queueService,
                                  storeAppsService: storeService,
                                  deviceInfoService: deviceInfoService,
                                  syncService: syncService,
                                  deviceConnectionService: deviceConnectionService)

        let deviceId: UInt = 5
        deviceConnectionService.onDeviceChange(deviceId)
        
        XCTAssert(queueService.fetchingForDeviceId == deviceId)
        XCTAssert(storeService.fetchingDownloadHistoryForDeviceId == deviceId)
        XCTAssert(storeService.fetchingUpdatesForDeviceId == deviceId)
        XCTAssert(deviceInfoService.fetchingDataForDeviceId == deviceId)
    }
    
    func testSyncMade_correctRefreshCallsAreMade() {
        /*
         - Device sync is done ->
            - The queue is consumed, refresh the queue
            - The device apps and device space did update, refresh device info
            - Refresh the updates list after the device info is refreshed.
            - Download history should remain the same.
        */

        
        let queueService = QueueServiceMock()
        let storeService = StoreServiceMock()
        let deviceInfoService = DeviceInfoServiceMock()
        let syncService = SyncServiceMock()
        let deviceConnectionService = DeviceConnectionServiceMock()
        
        let sut = DeviceDataVault(queueService: queueService,
                                  storeAppsService: storeService,
                                  deviceInfoService: deviceInfoService,
                                  syncService: syncService,
                                  deviceConnectionService: deviceConnectionService)
        let deviceId: UInt = 5
        
        sut.dispatch(action: action)
        XCTAssert(queueService.fetchingForDeviceId == deviceId)
        XCTAssert(storeService.fetchingDownloadHistoryForDeviceId == 0)
        XCTAssert(storeService.fetchingUpdatesForDeviceId == deviceId)
        XCTAssert(deviceInfoService.fetchingDataForDeviceId == deviceId)
    }
    
    func testInstallApp_correctRefreshCallsAreMade() {
        /*
         - Install app ->
            - The app is uploaded to queue (refetch the queue)
            - Refetch the downloaded apps.
            - Updates should remain the same, as the app will be installed with the
              newest version.
            - The device info remain the same, the app will reach device after sync.
        */
        let queueService = QueueServiceMock()
        let storeService = StoreServiceMock()
        storeService.installingAppResponse = .success(())
        let deviceInfoService = DeviceInfoServiceMock()
        
        let sut = DeviceDataVault(queueService: queueService,
                                  storeAppsService: storeService,
                                  deviceInfoService: deviceInfoService)
        
        let deviceId: UInt = 5
        let appId: String = "\(10)"
        let action = DeviceDataVaultAction.installApp(deviceId: deviceId, appId: appId)
        
        sut.dispatch(action: action)
        XCTAssert(storeService.installingAppForDeviceId == deviceId)
        XCTAssert(storeService.installingAppWithId == appId)
        XCTAssert(queueService.fetchingForDeviceId == deviceId)
        XCTAssert(storeService.fetchingDownloadHistoryForDeviceId == deviceId)
    }
    
    func testUninstallApp_correctCallsAreMade() {
        /*
         - Uninstall app ->
            - The app is deleted from the device, refetch the device info.
            - The download history remains the same.
            - Remove the app for updates list if the app did have an update prior
                to uninstalling.
            - If an update was uploaded to queue for the uninstalled device,
              remove the app from queue.
         */
        let queueService = QueueServiceMock()
        let storeService = StoreServiceMock()
        let deviceInfoService = DeviceInfoServiceMock()
        deviceInfoService.uninstallingResponse = .success(())
        
        let sut = DeviceDataVault(queueService: queueService,
                                  storeAppsService: storeService,
                                  deviceInfoService: deviceInfoService)
        let deviceId: UInt = 5
        let appId: String = "\(10)"
        let action = DeviceDataVaultAction.uninstallApp(deviceId: deviceId, appId: appId)
        
        sut.dispatch(action: action)
        XCTAssert(deviceInfoService.uninstallingForDeviceId == deviceId)
        XCTAssert(deviceInfoService.uninstallingAppWithId == appId)
        XCTAssert(deviceInfoService.fetchingDataForDeviceId == deviceId)
        XCTAssert(queueService.removingAppWithId == appId)
        XCTAssert(!(sut.data.appUpdates.data?.contains { $0.id == appId } ?? true))
    }
    
    func testDeleteApp_correctCallsAreMade() {
        // - Delete app -> - Delete app from download history.
        let queueService = QueueServiceMock()
        let storeService = StoreServiceMock()
        storeService.deletingAppResponse = .success(())
        let deviceInfoService = DeviceInfoServiceMock()
        
        let sut = DeviceDataVault(queueService: queueService,
                                  storeAppsService: storeService,
                                  deviceInfoService: deviceInfoService)
        let deviceId: UInt = 5
        let appId: String = "\(10)"
        let action = DeviceDataVaultAction.deleteApp(deviceId: deviceId, appId: appId)
        sut.dispatch(action: action)
        XCTAssert(storeService.deletingAppForDeviceId == deviceId)
        XCTAssert(storeService.deletingAppWithId == appId)
    }
    
    func testUpdateApp_CorretCallsAreMade() {
        /*
         - Update app ->
            - The app is uploaded to queue, refresh the queue.
            - Download history remains the same.
            - The updated list and device info will be refreshed after the sync.
         */
        let queueService = QueueServiceMock()
        let storeService = StoreServiceMock()
        storeService.updatingAppResponse = .success(())
        let deviceInfoService = DeviceInfoServiceMock()
        
        let sut = DeviceDataVault(queueService: queueService,
                                  storeAppsService: storeService,
                                  deviceInfoService: deviceInfoService)
        let deviceId: UInt = 5
        let appId: String = "\(10)"
        let action = DeviceDataVaultAction.updateApp(deviceId: deviceId, appId: appId)
        sut.dispatch(action: action)
        XCTAssert(storeService.updatingAppForDeviceId == deviceId)
        XCTAssert(storeService.updatingAppWithId == appId)
    }
}
