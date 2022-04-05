//
//  URLSessionService.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

import Foundation

protocol URLSessionServiceProtocol {
    func downloadTask(with url: URL, delegate: URLSessionDownloadDelegate) -> URLSessionDownloadTask
    func resumeDownload(data: Data, delegate: URLSessionDownloadDelegate) -> URLSessionDownloadTask
}
//struct Session {}
final class URLSessionService: URLSessionServiceProtocol {
    private func createSession(
        delegate: URLSessionDelegate
    ) -> URLSession {
        URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
    }

    func downloadTask(with url: URL, delegate: URLSessionDownloadDelegate) -> URLSessionDownloadTask {
        let urlSession = createSession(delegate: delegate)
        let task = urlSession.downloadTask(with: url)
        task.resume()
        urlSession.finishTasksAndInvalidate()
        return task
    }

    func resumeDownload(data: Data, delegate: URLSessionDownloadDelegate) -> URLSessionDownloadTask {
        let urlSession = createSession(delegate: delegate)
        let task = urlSession.downloadTask(withResumeData: data)
        task.resume()
        urlSession.finishTasksAndInvalidate()
        return task
    }
}
