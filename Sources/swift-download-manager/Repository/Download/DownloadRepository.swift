//
//  DownloadRepository.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 16/03/2022.
//

import Foundation

protocol DownloadRepositoryProtocol {
    func getActiveDownloads() -> [Download]
    func getInterruptedDownloads() -> [InterruptedDownload]
    func getCompletedDownloads() -> [CompletedDownload]
    func addDownload(_ download: Download)
    func addInterruptedDownload(_ interruptedDownload: InterruptedDownload)
    func addCompletedDownload(_ completedDownload: CompletedDownload)
    func resumeInterruptedDownload(_ interruptedDownload: InterruptedDownload)
    func addDownloadProgress(download: Download, progress: Double)
    func getDownloadProgress(download: Download) -> Double?
}

struct DownloadRepository: DownloadRepositoryProtocol {
    private let storage: DownloadStorageServiceProtocol

    init(
        storage: DownloadStorageServiceProtocol = DownloadStorageService()
    ) {
        self.storage = storage
    }

    func getActiveDownloads() -> [Download] {
        storage.activeDownloads
    }
    func getInterruptedDownloads() -> [InterruptedDownload] {
        storage.interruptedDownloads
    }
    func getCompletedDownloads() -> [CompletedDownload] {
        storage.completedDownloads
    }

    func addDownload(_ download: Download) {
        storage.activeDownloads.insert(download, at: 0)
    }

    func addInterruptedDownload(_ interruptedDownload: InterruptedDownload) {
        var activeDownloads = storage.activeDownloads
        activeDownloads.removeAll(where: { $0 == interruptedDownload.download })
        storage.activeDownloads = activeDownloads
        storage.interruptedDownloads.insert(interruptedDownload, at: 0)
    }

    func addCompletedDownload(_ completedDownload: CompletedDownload) {
        var interruptedDownloads = storage.interruptedDownloads
        var activeDownloads = storage.activeDownloads

        interruptedDownloads.removeAll(where: { $0.download == completedDownload.download })
        activeDownloads.removeAll(where: { $0 == completedDownload.download })

        storage.completedDownloads.insert(completedDownload, at: 0)
        storage.interruptedDownloads = interruptedDownloads
        storage.activeDownloads = activeDownloads
        storage.downloadProgress.removeValue(forKey: completedDownload.download)
    }

    func resumeInterruptedDownload(_ interruptedDownload: InterruptedDownload) {
        var interruptedDownloads = storage.interruptedDownloads

        interruptedDownloads.removeAll(where: { $0 == interruptedDownload })

        storage.interruptedDownloads = interruptedDownloads
        storage.activeDownloads.insert(interruptedDownload.download, at: 0)
    }

    func addDownloadProgress(download: Download, progress: Double) {
        storage.downloadProgress[download] = progress
    }

    func getDownloadProgress(download: Download) -> Double? {
        storage.downloadProgress[download]
    }
}
