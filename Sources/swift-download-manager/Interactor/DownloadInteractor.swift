//
//  DownloadInteractor.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 21/03/2022.
//

import Foundation

protocol DownloadInteractorProtocol {
    func startOrResume(
        download: Download,
        completion: @escaping (Result<CompletedDownload, DownloadError>) -> Void
    )
    func resume(
        interruptedDownload: InterruptedDownload,
        completion: @escaping (Result<CompletedDownload, DownloadError>) -> Void
    )
    func getDownloadProgress(download: Download) -> Double
    func getDownloadedData(with identifier: String) -> Data?
    func getDownloadDataUrl(with identifier: String) -> URL?
}

final class DownloadInteractor: DownloadInteractorProtocol {
    private let downloadRepository: DownloadRepositoryProtocol
    private let observableURLDownloadTaskInteractor: ObservableURLDownloadTaskInteractorProtocol
    private let fileManager: FileManagerInteractorProtocol
    private var downloadTasks: [Download: DownloadTask] = [:]
    private var downloadProgress: [Download: Double] = [:]

    init(
        downloadRepository: DownloadRepositoryProtocol,
        observableDownloadInteractor: ObservableURLDownloadTaskInteractorProtocol,
        fileManager: FileManagerInteractorProtocol
    ) {
        self.downloadRepository = downloadRepository
        self.observableURLDownloadTaskInteractor = observableDownloadInteractor
        self.fileManager = fileManager
        self.setupActions()
    }

    convenience init() {
        self.init(
            downloadRepository: DownloadRepository(),
            observableDownloadInteractor: ObservableURLDownloadTaskInteractor(),
            fileManager: FileManagerInteractor()
        )
    }

    func startOrResume(
        download: Download,
        completion: @escaping (Result<CompletedDownload, DownloadError>) -> Void
    ) {
        if let interrupted = downloadRepository.getInterruptedDownloads().first(where: { $0.download == download }) {
            resume(interruptedDownload: interrupted, completion: completion)
        } else {
            downloadRepository.addDownload(download)
            downloadTasks[download] = DownloadTask(
                downloadTask: observableURLDownloadTaskInteractor.download(from: download.url),
                completion: completion
            )
        }

    }

    func resume(
        interruptedDownload: InterruptedDownload,
        completion: @escaping (Result<CompletedDownload, DownloadError>) -> Void
    ) {
        downloadRepository.resumeInterruptedDownload(interruptedDownload)
        downloadTasks[interruptedDownload.download] = DownloadTask(
            downloadTask: observableURLDownloadTaskInteractor.resumeDownload(data: interruptedDownload.resumeData),
            completion: completion
        )
    }

    func getDownloadedData(with identifier: String) -> Data? {
        return getDownloadDataUrl(with: identifier).flatMap { try? Data(contentsOf: $0) }
    }

    func getDownloadDataUrl(with identifier: String) -> URL? {
        let completedDownload = downloadRepository.getCompletedDownloads().first(
            where: { $0.download.identifier == identifier }
        )
        guard let localPath = completedDownload?.localPath else { return nil }
        return fileManager.getFileUrl(lastPathComponent: localPath)
    }

    func getDownloadProgress(download: Download) -> Double {
        downloadProgress[download] ?? 0.0
    }

    deinit {
        downloadTasks.forEach { downloadTask in
            downloadTask.value.downloadTask.cancel { [downloadRepository] data in
                guard
                    let url = downloadTask.value.downloadTask.originalRequest?.url?.absoluteString,
                    let download = downloadRepository.getActiveDownloads().first(where: { $0.url.absoluteString == url }),
                    let resumeData = data
                else { return }
                downloadRepository.addInterruptedDownload(.init(download: download, resumeData: resumeData))
            }

        }
    }
}

private extension DownloadInteractor {
    func setupActions() {
        observableURLDownloadTaskInteractor.didReportAction = { [weak self, downloadRepository, fileManager] action in
            func download(using downloadTask: URLSessionDownloadTask) -> Download? {
                guard let url = downloadTask.originalRequest?.url?.absoluteString else {
                    return nil
                }
                return downloadRepository.getActiveDownloads().first(where: { $0.url.absoluteString == url })
            }
            self?.logDownloadAction(action)
            switch action {
            case let .finished(downloadTask, location):
                guard
                    let download = download(using: downloadTask),
                    let savedURL = fileManager.saveToDocumentsDirectory(orignalUrl: download.url, tempLocation: location)
                else {
                    return
                }
                let completedDownload = CompletedDownload(download: download, localPath: savedURL.lastPathComponent)
                downloadRepository.addCompletedDownload(completedDownload)
                self?.downloadTasks[download]?.completion(.success(completedDownload))
            case let .progress(downloadTask, progress):
                guard let download = download(using: downloadTask) else { return }
//                self?.downloadProgress[download] = progress
                downloadRepository.addDownloadProgress(download: download, progress: progress)
            case let .error(downloadTask, resumeData):
                guard let download = download(using: downloadTask), let resumeData = resumeData else { return }
                downloadRepository.addInterruptedDownload(.init(download: download, resumeData: resumeData))
            }
        }
    }
}

private struct DownloadTask: Equatable {
    let downloadTask: URLSessionDownloadTask
    @IgnoreEquatable var completion: (Result<CompletedDownload, DownloadError>) -> Void
}

// MARK: - DEBUG
extension DownloadInteractor {
    func logDownloadAction(_ action: ObservableDownloadAction) {
    #if DEBUG
        func logDownloadIdentifier(_ task: URLSessionDownloadTask) {
            guard let url = task.originalRequest?.url?.absoluteString else { return }
            guard
                let download = downloadRepository.getActiveDownloads().first(where: { $0.url.absoluteString == url })
            else {
                print("-- --- Download not found for task")
                return
            }
            print("-- --- Identifier: \(download.identifier)")
        }
        print("DOWNLOAD TASK Action 👇🏼")
        switch action {
        case let .finished(downloadTask, location):
            print("-- finished")
            logDownloadIdentifier(downloadTask)
            print("-- --- location: \(location.absoluteString)")
        case let .progress(downloadTask, progress):
            print("-- progress")
            logDownloadIdentifier(downloadTask)
            print("-- --- progress: \(progress)")
        case let .error(downloadTask, resumeData):
            print("-- error")
            logDownloadIdentifier(downloadTask)
            print("-- --- resumeData: \(String(describing: resumeData))")
        }
    #endif
    }
}
