//
//  DownloadRepositoryMock.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

@testable import swift_download_manager

final class DownloadRepositoryMock: DownloadRepositoryProtocol {
    lazy var getActiveDownloadsMock = MockFunc.mock(for: getActiveDownloads)
    func getActiveDownloads() -> [Download] {
        getActiveDownloadsMock.callAndReturn(())
    }

    lazy var getInterruptedDownloadsMock = MockFunc.mock(for: getInterruptedDownloads)
    func getInterruptedDownloads() -> [InterruptedDownload] {
        getInterruptedDownloadsMock.callAndReturn(())
    }

    lazy var getCompletedDownloadsMock = MockFunc.mock(for: getCompletedDownloads)
    func getCompletedDownloads() -> [CompletedDownload] {
        getCompletedDownloadsMock.callAndReturn(())
    }


    lazy var addDownloadMock = MockFunc.mock(for: addDownload)
    func addDownload(_ download: Download) {
        addDownloadMock.callAndReturn(download)
    }

    lazy var addInterruptedDownloadMock = MockFunc.mock(for: addInterruptedDownload)
    func addInterruptedDownload(_ interruptedDownload: InterruptedDownload) {
        addInterruptedDownloadMock.callAndReturn(interruptedDownload)
    }

    lazy var addCompletedDownloadMock = MockFunc.mock(for: addCompletedDownload)
    func addCompletedDownload(_ completedDownload: CompletedDownload) {
        addCompletedDownloadMock.callAndReturn(completedDownload)
    }


    lazy var resumeInterruptedDownloadMock = MockFunc.mock(for: resumeInterruptedDownload)
    func resumeInterruptedDownload(_ interruptedDownload: InterruptedDownload) {
        resumeInterruptedDownloadMock.callAndReturn(interruptedDownload)
    }

    lazy var addDownloadProgressMock = MockFunc.mock(for: addDownloadProgress)
    func addDownloadProgress(download: Download, progress: Double) {
        addDownloadProgressMock.callAndReturn((download, progress))
    }

    lazy var getDownloadProgressMock = MockFunc.mock(for: getDownloadProgress)
    func getDownloadProgress(download: Download) -> Double? {
        getDownloadProgressMock.callAndReturn(download)
    }
}

