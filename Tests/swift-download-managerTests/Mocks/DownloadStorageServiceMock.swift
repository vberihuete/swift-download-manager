//
//  DownloadStorageServiceMock.swift
//  DownloadManagerTests
//
//  Created by Vincent Berihuete on 17/03/2022.
//

@testable import swift_download_manager

final class DownloadStorageServiceMock: DownloadStorageServiceProtocol {
    var downloadProgress: [Download : Double] = [:]
    var activeDownloads: [Download] = []
    var interruptedDownloads: [InterruptedDownload] = []
    var completedDownloads: [CompletedDownload] = []
}
