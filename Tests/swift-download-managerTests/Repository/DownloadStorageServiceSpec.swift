//
//  DownloadStorageServiceSpec.swift
//  DownloadManagerTests
//
//  Created by Vincent Berihuete on 17/03/2022.
//

@testable import swift_download_manager
import Foundation
import Quick
import Nimble

final class DownloadStorageServiceSpec: QuickSpec {
    override func spec() {
        describe("activeDownload") {
            it("sets and retrieves properly") {
                let builder = Builder()
                let storage = builder.makeStorage()

                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)

                expect(storage.activeDownloads).to(beEmpty())
                storage.activeDownloads = [download1, download2]

                expect(storage.activeDownloads) == [download1, download2]
            }
        }

        describe("interruptedDownloads") {
            it("sets and retrieves properly") {
                let builder = Builder()
                let storage = builder.makeStorage()

                let url = URL(string: "https://someurl.com")!
                let data = Data()
                let interrupted1 = InterruptedDownload(download: .init(identifier: "1", url: url), resumeData: data)
                let interrupted2 = InterruptedDownload(download: .init(identifier: "2", url: url), resumeData: data)

                expect(storage.interruptedDownloads).to(beEmpty())
                storage.interruptedDownloads = [interrupted1, interrupted2]

                expect(storage.interruptedDownloads) == [interrupted1, interrupted2]
            }
        }

        describe("completedDownloads") {
            it("sets and retrieves properly") {
                let builder = Builder()
                let storage = builder.makeStorage()

                let url = URL(string: "https://someurl.com")!
                let localUrl = URL(string: "user:/local")!.absoluteString
                let completed1 = CompletedDownload(download: .init(identifier: "1", url: url), localPath: localUrl)
                let completed2 = CompletedDownload(download: .init(identifier: "2", url: url), localPath: localUrl)

                expect(storage.completedDownloads).to(beEmpty())
                storage.completedDownloads = [completed1, completed2]

                expect(storage.completedDownloads) == [completed1, completed2]
            }
        }

        describe("downloadProgress") {
            it("sets and retrieves properly") {
                let builder = Builder()
                let storage = builder.makeStorage()

                let download1 = Download(identifier: "test", url: URL(string: "https://google.com/1")!)
                let download2 = Download(identifier: "tes2", url: URL(string: "https://google.com/2")!)

                storage.downloadProgress[download1] = 0.2

                expect(storage.downloadProgress) == [download1: 0.2]

                storage.downloadProgress[download1] = 0.4
                storage.downloadProgress[download2] = 0.1

                expect(storage.downloadProgress) == [download1: 0.4, download2: 0.1]
            }
        }
    }
}

private final class Builder {
    func makeStorage() -> DownloadStorageService {
        UserDefaults.standard.removePersistentDomain(forName: "DownloadStorageServiceSpec")
        let userDefaults = UserDefaults(suiteName: "DownloadStorageServiceSpec")!

        return .init(storage: userDefaults)
    }
}
