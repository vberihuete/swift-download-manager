//
//  DownloadStorageService.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 16/03/2022.
//

import Foundation

protocol DownloadStorageServiceProtocol: AnyObject {
    var activeDownloads: [Download] { get set }
    var interruptedDownloads: [InterruptedDownload] { get set }
    var completedDownloads: [CompletedDownload] { get set }
    var downloadProgress: [Download: Double] { get set }
}

final class DownloadStorageService: DownloadStorageServiceProtocol {
    enum Constant {
        static let downloadsKey = "storage.DownloadsKey"
        static let interruptedDownloadsKey = "storage.interruptedDownloadsKey"
        static let completedDownloadsKey = "storage.completedDownloadsKey"
        static let downloadProgressKey = "storage.DownloadProgressKey"
    }
    private let storage: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        storage: UserDefaults = .standard
    ) {
        self.storage = storage
    }

    var activeDownloads: [Download] {
        get {
            guard let data = storage.value(forKey: Constant.downloadsKey) as? Data else { return [] }
            return (try? decoder.decode([Download].self, from: data)) ?? []
        }
        set {
            guard let data = try? encoder.encode(newValue) else { return }
            storage.set(data, forKey: Constant.downloadsKey)
        }
    }

    var interruptedDownloads: [InterruptedDownload] {
        get {
            guard let data = storage.value(forKey: Constant.interruptedDownloadsKey) as? Data else { return [] }
            return (try? decoder.decode([InterruptedDownload].self, from: data)) ?? []
        }
        set {
            guard let data = try? encoder.encode(newValue) else { return }
            storage.set(data, forKey: Constant.interruptedDownloadsKey)
        }
    }

    var completedDownloads: [CompletedDownload] {
        get {
            guard let data = storage.value(forKey: Constant.completedDownloadsKey) as? Data else { return [] }
            return (try? decoder.decode([CompletedDownload].self, from: data)) ?? []
        }
        set {
            guard let data = try? encoder.encode(newValue) else { return }
            storage.set(data, forKey: Constant.completedDownloadsKey)
        }
    }

    var downloadProgress: [Download : Double] {
        get {
            guard let data = storage.value(forKey: Constant.downloadProgressKey) as? Data else { return [:] }
            return (try? decoder.decode([Download: Double].self, from: data)) ?? [:]
        }
        set {
            guard let data = try? encoder.encode(newValue) else { return }
            storage.set(data, forKey: Constant.downloadProgressKey)
        }
    }
}
