//
//  URLSessionDelegateMock.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

import Foundation

final class URLSessionDelegateMock: NSObject, URLSessionDownloadDelegate {
    var urlSessionDidFinishMock = MockFunc<(URLSession, URLSessionDownloadTask, URL), ()>()
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        urlSessionDidFinishMock.callAndReturn((session, downloadTask, location))
    }

    var urlSessionDidWriteMock = MockFunc<(URLSession, URLSessionDownloadTask, Int64, Int64, Int64), ()>()
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        urlSessionDidWriteMock.callAndReturn((session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite))
    }

    var urlSessionCompletedWithErrorMock = MockFunc<(URLSession, URLSessionTask, Error?), ()>()
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        urlSessionCompletedWithErrorMock.callAndReturn((session, task, error))
    }
}
