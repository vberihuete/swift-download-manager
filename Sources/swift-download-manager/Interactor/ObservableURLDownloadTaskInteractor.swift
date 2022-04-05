//
//  ObservableURLDownloadTaskInteractor.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 21/03/2022.
//

import Foundation

protocol ObservableURLDownloadTaskInteractorProtocol: AnyObject {
    var didReportAction: (ObservableDownloadAction) -> Void { get set }
    func download(from url: URL) -> URLSessionDownloadTask
    func resumeDownload(data: Data) -> URLSessionDownloadTask
}

final class ObservableURLDownloadTaskInteractor: NSObject, ObservableURLDownloadTaskInteractorProtocol {
    private let urlSessionService: URLSessionServiceProtocol

    init(
        urlSessionService: URLSessionServiceProtocol
    ) {
        self.urlSessionService = urlSessionService
    }
    var didReportAction: (ObservableDownloadAction) -> Void = { _ in }

    func download(from url: URL) -> URLSessionDownloadTask {
        return urlSessionService.downloadTask(with: url, delegate: self)
    }

    func resumeDownload(data: Data) -> URLSessionDownloadTask {
        return urlSessionService.resumeDownload(data: data, delegate: self)
    }
}

// MARK: - URL Session Delegate
extension ObservableURLDownloadTaskInteractor: URLSessionDownloadDelegate {
    /// Called when download is finished
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        didReportAction(.finished(downloadTask: downloadTask, location: location))
    }

    /// Called when download gets progress
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        didReportAction(.progress(downloadTask: downloadTask, progress: progress))
    }

    /// Called when download's interrupted
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask, let error = error else { return }
        let resumeData = (error as NSError?)?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data

        didReportAction(.error(downloadTask: downloadTask, resumeData: resumeData))
    }
}

// MARK: - Actions
enum ObservableDownloadAction: Equatable {
    case finished(downloadTask: URLSessionDownloadTask, location: URL)
    case progress(downloadTask: URLSessionDownloadTask, progress: Double)
    case error(downloadTask: URLSessionDownloadTask, resumeData: Data?)
}
