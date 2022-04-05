//
//  File.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

@testable import swift_download_manager
import Foundation

final class ObservableURLDownloadTaskInteractorMock: ObservableURLDownloadTaskInteractorProtocol {
    var didReportAction: (ObservableDownloadAction) -> Void = { _ in }

    lazy var downloadMock = MockFunc.mock(for: download)
    func download(from url: URL) -> URLSessionDownloadTask {
        downloadMock.callAndReturn(url)
    }

    lazy var resumeDownloadMock = MockFunc.mock(for: resumeDownload)
    func resumeDownload(data: Data) -> URLSessionDownloadTask {
        resumeDownloadMock.callAndReturn(data)
    }
}
