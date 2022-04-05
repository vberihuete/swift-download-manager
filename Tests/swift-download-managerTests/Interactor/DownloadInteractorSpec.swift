//
//  DownloadInteractorSpec.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

@testable import swift_download_manager
import Quick
import Nimble
import Foundation

final class DownloadInteractorSpec: QuickSpec {
    override func spec() {
        describe("#startOrResume(download:_, completion:_)") {
            context("download exists as interrupted") {
                it("should call resume") {
                    let builder = Builder().deinitMocks
                    let interactor = builder.makeInteractor()
                    let download = Download(identifier: "123", url: .init(string: "https://goog.com/1/2")!)
                    let data = Data()
                    let interruptedDownload = InterruptedDownload(download: download, resumeData: data)
                    let task = URLSession.shared.downloadTask(withResumeData: data)

                    builder.downloadRepository.getInterruptedDownloadsMock.returns([interruptedDownload])
                    builder.downloadRepository.resumeInterruptedDownloadMock.returns(())
                    builder.observableDownloadInteractor.resumeDownloadMock.returns(task)

                    interactor.startOrResume(download: download, completion: { _ in })

                    expect(builder.downloadRepository.resumeInterruptedDownloadMock.parameters) == [interruptedDownload]
                    expect(builder.observableDownloadInteractor.resumeDownloadMock.parameters) == [data]
                }
            }
            context("download doesn't exists as interrupted meaning is new") {
                it("should add download to repo and call observable download for download") {
                    let builder = Builder().deinitMocks
                    let interactor = builder.makeInteractor()
                    let download = Download(identifier: "123", url: .init(string: "https://goog.com/1/2")!)
                    let download2 = Download(identifier: "2", url: .init(string: "https://goog.com/1")!)
                    let interruptedDownload = InterruptedDownload(download: download2, resumeData: Data())
                    let task = URLSession.shared.downloadTask(with: download.url)

                    builder.downloadRepository.getInterruptedDownloadsMock.returns([interruptedDownload])
                    builder.downloadRepository.addDownloadMock.returns(())
                    builder.observableDownloadInteractor.downloadMock.returns(task)

                    interactor.startOrResume(download: download, completion: { _ in })

                    expect(builder.downloadRepository.addDownloadMock.parameters) == [download]
                    expect(builder.observableDownloadInteractor.downloadMock.parameters) == [download.url]
                }
            }
        }

        describe("#resume") {
            it("should call repo resume interrupted download and observable download for resume") {
                let builder = Builder().deinitMocks
                let interactor = builder.makeInteractor()
                let download = Download(identifier: "123", url: .init(string: "https://goog.com/1/2")!)
                let data = Data()
                let interruptedDownload = InterruptedDownload(download: download, resumeData: data)
                let task = URLSession.shared.downloadTask(withResumeData: data)

                builder.downloadRepository.getInterruptedDownloadsMock.returns([interruptedDownload])
                builder.downloadRepository.resumeInterruptedDownloadMock.returns(())
                builder.observableDownloadInteractor.resumeDownloadMock.returns(task)

                interactor.resume(interruptedDownload: interruptedDownload, completion: { _ in })

                expect(builder.downloadRepository.resumeInterruptedDownloadMock.parameters) == [interruptedDownload]
                expect(builder.observableDownloadInteractor.resumeDownloadMock.parameters) == [data]
            }
        }

        describe("#getDownloadedData(with identifier:_)") {
            context("completed download with identifier exists") {
                it("Creates data from file url") {
                    let builder = Builder().deinitMocks
                    let interactor = builder.makeInteractor()
                    let download = Download(identifier: "123", url: .init(string: "https://goog.com/1/2")!)
                    let localPath = "/local/1/2/3"
                    let completedDownload = CompletedDownload(download: download, localPath: localPath)
                    let localUrl = URL(string: "somelocal://directory")

                    builder.fileManager.getFileUrlMock.returns(localUrl)
                    builder.downloadRepository.getCompletedDownloadsMock.returns([completedDownload])

                    expect(interactor.getDownloadedData(with: "123")).to(beNil())
                    expect(builder.downloadRepository.getCompletedDownloadsMock.invokedCount) == 1
                    expect(builder.fileManager.getFileUrlMock.parameters) == [localPath]
                }
            }
            context("completed download with identifier not available") {
                it("returns nil for fileManager getFileUrl") {
                    let builder = Builder().deinitMocks
                    let interactor = builder.makeInteractor()
                    let download = Download(identifier: "123", url: .init(string: "https://goog.com/1/2")!)
                    let localPath = "/local/1/2/3"
                    let completedDownload = CompletedDownload(download: download, localPath: localPath)
                    let localUrl = URL(string: "somelocal://directory")

                    builder.fileManager.getFileUrlMock.returns(localUrl)
                    builder.downloadRepository.getCompletedDownloadsMock.returns([completedDownload])

                    expect(interactor.getDownloadedData(with: "456")).to(beNil())
                    expect(builder.downloadRepository.getCompletedDownloadsMock.invokedCount) == 1
                    expect(builder.fileManager.getFileUrlMock.invokedCount) == 0
                }
            }
        }

        describe("#getDownloadDataUrl(with identifier:_)") {
            context("completed download with identifier exists") {
                it("Gives back file url") {
                    let builder = Builder().deinitMocks
                    let interactor = builder.makeInteractor()
                    let download = Download(identifier: "123", url: .init(string: "https://goog.com/1/2")!)
                    let localPath = "/local/1/2/3"
                    let completedDownload = CompletedDownload(download: download, localPath: localPath)
                    let localUrl = URL(string: "somelocal://directory")

                    builder.fileManager.getFileUrlMock.returns(localUrl)
                    builder.downloadRepository.getCompletedDownloadsMock.returns([completedDownload])

                    expect(interactor.getDownloadDataUrl(with: "123")) == localUrl
                    expect(builder.downloadRepository.getCompletedDownloadsMock.invokedCount) == 1
                    expect(builder.fileManager.getFileUrlMock.parameters) == [localPath]
                }
            }
            context("completed download with identifier not available") {
                it("returns nil for fileManager getFileUrl") {
                    let builder = Builder().deinitMocks
                    let interactor = builder.makeInteractor()
                    let download = Download(identifier: "123", url: .init(string: "https://goog.com/1/2")!)
                    let localPath = "/local/1/2/3"
                    let completedDownload = CompletedDownload(download: download, localPath: localPath)
                    let localUrl = URL(string: "somelocal://directory")

                    builder.fileManager.getFileUrlMock.returns(localUrl)
                    builder.downloadRepository.getCompletedDownloadsMock.returns([completedDownload])

                    expect(interactor.getDownloadDataUrl(with: "456")).to(beNil())
                    expect(builder.downloadRepository.getCompletedDownloadsMock.invokedCount) == 1
                    expect(builder.fileManager.getFileUrlMock.invokedCount) == 0
                }
            }
        }

        describe("deinit") {
            // TODO: add test for deini
        }
    }
}

private final class Builder {
    let downloadRepository = DownloadRepositoryMock()
    let observableDownloadInteractor = ObservableURLDownloadTaskInteractorMock()
    let fileManager = FileManagerInteractorMock()

    func makeInteractor() -> DownloadInteractor {
        .init(
            downloadRepository: downloadRepository,
            observableDownloadInteractor: observableDownloadInteractor,
            fileManager: fileManager
        )
    }

    var deinitMocks: Self {
        downloadRepository.getActiveDownloadsMock.returns([])
        return self
    }
}
