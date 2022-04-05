//
//  ObservableURlDownloadTaskInteractorSpec.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

@testable import swift_download_manager
import Foundation
import Quick
import Nimble

class ObservableURLDownloadTaskInteractorSpec: QuickSpec {
    override func spec() {
        describe("#download(from url:_)") {
            it("calls url session for download task") {
                let builder = Builder()
                let interactor = builder.makeInteractor()
                let url = URL(string: "https://google.com/1/2")!
                let task = URLSession.shared.downloadTask(with: url)

                builder.urlSessionService.downloadTaskMock.returns(task)
                expect(interactor.download(from: url)) === task
            }
            context("delegate") {
                func prepare() -> (builder: Builder, task: URLSessionDownloadTask) {
                    let builder = Builder()
                    let interactor = builder.makeInteractor()
                    let url = URL(string: "https://google.com/1/2")!
                    let task = URLSession.shared.downloadTask(with: url)

                    builder.urlSessionService.downloadTaskMock.returns(task)
                    _ = interactor.download(from: url)
                    return (builder: builder, task: task)
                }
                describe("#urlSession(_, _, didFinishDownloadingTo location:_)") {
                    it("sends callback .finished") {
                        let (builder, task) = prepare()
                        let localUrl = URL(string: "file://local/1/2/3")!
                        builder.urlSessionService.downloadTaskMock.input.1.urlSession(
                            URLSession.shared,
                            downloadTask: task,
                            didFinishDownloadingTo: localUrl
                        )

                        expect(builder.actions) == [.finished(downloadTask: task, location: localUrl)]
                    }
                }
                describe("#urlSession(_, _, didWriteData:_, totalBytesWritten:_, totalBytesExpectedToWrite:_)") {
                    it("sends callback .progress") {
                        let (builder, task) = prepare()
                        builder.urlSessionService.downloadTaskMock.input.1.urlSession?(
                            .shared,
                            downloadTask: task,
                            didWriteData: 0,
                            totalBytesWritten: 500,
                            totalBytesExpectedToWrite: 1000
                        )

                        expect(builder.actions) == [.progress(downloadTask: task, progress: 0.5)]
                    }
                }
                describe("#urlSession(_, _, didCompleteWithError error:_)") {
                    context("error contains key NSURLSessionDownloadTaskResumeData") {
                        it("sends callback .error with resume data") {
                            let (builder, task) = prepare()
                            let resumeData = Data()
                            let error = NSError(
                                domain: "Observable.error",
                                code: 1,
                                userInfo: [NSURLSessionDownloadTaskResumeData: resumeData]
                            )
                            builder.urlSessionService.downloadTaskMock.input.1.urlSession?(
                                .shared,
                                task: task,
                                didCompleteWithError: error
                            )

                            expect(builder.actions) == [.error(downloadTask: task, resumeData: resumeData)]
                        }
                    }
                    context("error doesn't have key for resume data") {
                        it("sends callback .error with resume data nil") {
                            let (builder, task) = prepare()
                            builder.urlSessionService.downloadTaskMock.input.1.urlSession?(
                                .shared,
                                task: task,
                                didCompleteWithError: DownloadError.generic
                            )

                            expect(builder.actions) == [.error(downloadTask: task, resumeData: nil)]
                        }
                    }
                }
            }
        }

        describe("#resumeDownload(data:_)") {
            it("calls url session for resume download") {
                let builder = Builder()
                let interactor = builder.makeInteractor()
                let data = Data()
                let task = URLSession.shared.downloadTask(withResumeData: data)

                builder.urlSessionService.resumeDownloadMock.returns(task)
                expect(interactor.resumeDownload(data: data)) === task
            }
            context("delegate") {
                func prepare() -> (builder: Builder, task: URLSessionDownloadTask) {
                    let builder = Builder()
                    let interactor = builder.makeInteractor()
                    let data = Data()
                    let task = URLSession.shared.downloadTask(withResumeData: data)

                    builder.urlSessionService.resumeDownloadMock.returns(task)
                    _ = interactor.resumeDownload(data: data)
                    return (builder: builder, task: task)
                }
                describe("#urlSession(_, _, didFinishDownloadingTo location:_)") {
                    it("sends callback .finished") {
                        let (builder, task) = prepare()
                        let localUrl = URL(string: "file://local/1/2/3")!
                        builder.urlSessionService.resumeDownloadMock.input.1.urlSession(
                            URLSession.shared,
                            downloadTask: task,
                            didFinishDownloadingTo: localUrl
                        )

                        expect(builder.actions) == [.finished(downloadTask: task, location: localUrl)]
                    }
                }
                describe("#urlSession(_, _, didWriteData:_, totalBytesWritten:_, totalBytesExpectedToWrite:_)") {
                    it("sends callback .progress") {
                        let (builder, task) = prepare()
                        builder.urlSessionService.resumeDownloadMock.input.1.urlSession?(
                            .shared,
                            downloadTask: task,
                            didWriteData: 0,
                            totalBytesWritten: 500,
                            totalBytesExpectedToWrite: 1000
                        )

                        expect(builder.actions) == [.progress(downloadTask: task, progress: 0.5)]
                    }
                }
                describe("#urlSession(_, _, didCompleteWithError error:_)") {
                    context("error contains key NSURLSessionDownloadTaskResumeData") {
                        it("sends callback .error with resume data") {
                            let (builder, task) = prepare()
                            let resumeData = Data()
                            let error = NSError(
                                domain: "Observable.error",
                                code: 1,
                                userInfo: [NSURLSessionDownloadTaskResumeData: resumeData]
                            )
                            builder.urlSessionService.resumeDownloadMock.input.1.urlSession?(
                                .shared,
                                task: task,
                                didCompleteWithError: error
                            )

                            expect(builder.actions) == [.error(downloadTask: task, resumeData: resumeData)]
                        }
                    }
                    context("error doesn't have key for resume data") {
                        it("sends callback .error with resume data nil") {
                            let (builder, task) = prepare()
                            builder.urlSessionService.resumeDownloadMock.input.1.urlSession?(
                                .shared,
                                task: task,
                                didCompleteWithError: DownloadError.generic
                            )

                            expect(builder.actions) == [.error(downloadTask: task, resumeData: nil)]
                        }
                    }
                }
            }
        }
    }
}

private final class Builder {
    let urlSessionService = URLSessionServiceMock()
    var actions: [ObservableDownloadAction] = []
    func makeInteractor() -> ObservableURLDownloadTaskInteractor {
        let interactor = ObservableURLDownloadTaskInteractor(urlSessionService: urlSessionService)
        interactor.didReportAction = {
            self.actions.append($0)
        }
        return interactor
    }
}
