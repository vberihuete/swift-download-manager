//
//  DownloadRepositorySpec.swift
//  DownloadManagerTests
//
//  Created by Vincent Berihuete on 17/03/2022.
//

@testable import swift_download_manager
import Nimble
import Quick
import Foundation

final class DownloadRepositorySpec: QuickSpec {
    override func spec() {
        describe("#getActiveDownloads()") {
            it("gets active downloads from storage") {
                let builder = Builder()
                let repo = builder.makeRepository()

                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)

                builder.storage.activeDownloads = [download1, download2]

                expect(repo.getActiveDownloads()) == [download1, download2]
            }
        }

        describe("#getInterruptedDownloads()") {
            it("gets interrupted downloads from storage") {
                let builder = Builder()
                let repo = builder.makeRepository()
                let url = URL(string: "https://someurl.com")!
                let data = Data()
                let interrupted1 = InterruptedDownload(download: .init(identifier: "1", url: url), resumeData: data)
                let interrupted2 = InterruptedDownload(download: .init(identifier: "2", url: url), resumeData: data)

                builder.storage.interruptedDownloads = [interrupted1, interrupted2]

                expect(repo.getInterruptedDownloads()) == [interrupted1, interrupted2]
            }
        }

        describe("#getCompletedDownloads()") {
            it("gets completed downloads from storage") {
                let builder = Builder()
                let repo = builder.makeRepository()

                let url = URL(string: "https://someurl.com")!
                let localUrl = URL(string: "user:/local")!.absoluteString
                let completed1 = CompletedDownload(download: .init(identifier: "1", url: url), localPath: localUrl)
                let completed2 = CompletedDownload(download: .init(identifier: "2", url: url), localPath: localUrl)

                builder.storage.completedDownloads = [completed1, completed2]

                expect(repo.getCompletedDownloads()) == [completed1, completed2]
            }
        }

        describe("#addDownload(_ download:_)") {
            it("adds the download to the top") {
                let builder = Builder()
                let repo = builder.makeRepository()

                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)

                builder.storage.activeDownloads = [download1]
                repo.addDownload(download2)

                expect(repo.getActiveDownloads()) == [download2, download1]
            }
        }

        describe("#addInterruptedDownload(_ interruptedDownload:_)") {
            it("removes from active and adds to interrupted") {
                let builder = Builder()
                let repo = builder.makeRepository()

                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)
                let download3 = Download(identifier: "tes3", url: URL(string: "https://google.com/3")!)
                let interruptedDownload = InterruptedDownload(download: download2, resumeData: Data())

                builder.storage.activeDownloads = [download1, download2, download3]

                repo.addInterruptedDownload(interruptedDownload)

                expect(repo.getActiveDownloads()) == [download1, download3]
                expect(repo.getInterruptedDownloads()) == [interruptedDownload]
            }
        }

        describe("#addCompletedDownload(_ completedDownload:_)") {
            it("adds to completed and removes from interrupted, active and progress") {
                let builder = Builder()
                let repo = builder.makeRepository()

                let localUrl = URL(string: "user:/local")!.absoluteString
                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)
                let download3 = Download(identifier: "tes2", url: URL(string: "https://google.com/3")!)
                let interruptedDownload = InterruptedDownload(download: download2, resumeData: Data())
                let completed1 = CompletedDownload(download: download1, localPath: localUrl)
                let completed2 = CompletedDownload(download: download2, localPath: localUrl)

                builder.storage.activeDownloads = [download1, download3]
                builder.storage.interruptedDownloads = [interruptedDownload]
                builder.storage.downloadProgress[download2] = 0.3
                builder.storage.downloadProgress[download3] = 0.5

                repo.addCompletedDownload(completed1)
                repo.addCompletedDownload(completed2)

                expect(repo.getInterruptedDownloads()).to(beEmpty())
                expect(repo.getActiveDownloads()) == [download3]
                expect(repo.getDownloadProgress(download: download3)) == 0.5
                expect(repo.getDownloadProgress(download: download2)).to(beNil())
            }
        }

        describe("#resumeInterruptedDownload(_ interruptedDownload:_)") {
            it("adds to active and removes from interrupted") {
                let builder = Builder()
                let repo = builder.makeRepository()

                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)
                let download3 = Download(identifier: "tes2", url: URL(string: "https://google.com/3")!)
                let download4 = Download(identifier: "tes2", url: URL(string: "https://google.com/4")!)
                let interruptedDownload1 = InterruptedDownload(download: download1, resumeData: Data())
                let interruptedDownload2 = InterruptedDownload(download: download2, resumeData: Data())

                builder.storage.activeDownloads = [download4, download3]
                builder.storage.interruptedDownloads = [interruptedDownload1, interruptedDownload2]

                repo.resumeInterruptedDownload(interruptedDownload1)

                expect(repo.getInterruptedDownloads()) == [interruptedDownload2]
                expect(repo.getActiveDownloads()) == [download1, download4, download3]
            }
        }

        describe("#addDownloadProgress(download:_, progress:_)") {
            it("adds progress to downloads") {
                let builder = Builder()
                let repo = builder.makeRepository()

                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)

                repo.addDownloadProgress(download: download1, progress: 0.5)
                repo.addDownloadProgress(download: download2, progress: 0.8)

                expect(builder.storage.downloadProgress) == [download1: 0.5, download2: 0.8]
            }
        }

        describe("#getDownloadProgress(download:_)") {
            let builder = Builder()
            let repo = builder.makeRepository()

            let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
            let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)

            builder.storage.downloadProgress[download1] = 0.2
            builder.storage.downloadProgress[download2] = 0.7

            expect(repo.getDownloadProgress(download: download2)) == 0.7
            expect(repo.getDownloadProgress(download: download1)) == 0.2
        }
    }
}

private final class Builder {
    let storage = DownloadStorageServiceMock()

    func makeRepository() -> DownloadRepository {
        .init(storage: storage)
    }
}
