//
//  ImageDownloaderInteractor.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 23/03/2022.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public final class ImageDownloaderInteractor {
    private let downloadInteractor: DownloadInteractorProtocol

    public convenience init() {
        self.init(downloadInteractor: DownloadInteractor())
    }

    init(
        downloadInteractor: DownloadInteractorProtocol = DownloadInteractor()
    ) {
        self.downloadInteractor = downloadInteractor
    }

    public func getImage(with identifier: String) -> UIImage? {
        downloadInteractor.getDownloadedData(with: identifier).flatMap {
            UIImage(data: $0)
        }
    }

    public func getOrDownloadImage(remoteUrl url: URL, completion: @escaping (Result<UIImage, DownloadError>) -> Void) {
        if let image = getImage(with: url.absoluteString) {
            completion(.success(image))
        } else {
            let download = Download(identifier: url.absoluteString, url: url)
            downloadInteractor.startOrResume(download: download) { [weak self] result in
                switch result {
                case let .success(completedDownload):
                    if let image = self?.getImage(with: completedDownload.download.identifier) {
                        completion(.success(image))
                    } else {
                        completion(.failure(.generic))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
}
