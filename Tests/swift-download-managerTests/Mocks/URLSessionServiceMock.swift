//
//  URLSessionServiceMock.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

@testable import swift_download_manager
import Foundation

final class URLSessionServiceMock: URLSessionServiceProtocol {
    lazy var downloadTaskMock = MockFunc.mock(for: downloadTask)
    func downloadTask(with url: URL, delegate: URLSessionDownloadDelegate) -> URLSessionDownloadTask {
        downloadTaskMock.callAndReturn((url, delegate))
    }

    lazy var resumeDownloadMock = MockFunc.mock(for: resumeDownload)
    func resumeDownload(data: Data, delegate: URLSessionDownloadDelegate) -> URLSessionDownloadTask {
        resumeDownloadMock.callAndReturn((data, delegate))
    }
}
