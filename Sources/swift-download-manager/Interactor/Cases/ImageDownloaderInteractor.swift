//
//  ImageDownloaderInteractor.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 23/03/2022.
//

import Foundation
import UIKit
// same should work for 3d assets, search only how to parse a 3d asset to a data model

final class ImageDownloaderInteractor {
    private let downloadInteractor: DownloadInteractorProtocol

    init(
        downloadInteractor: DownloadInteractorProtocol = DownloadInteractor()
    ) {
        self.downloadInteractor = downloadInteractor
    }

    // review this methods later.. I'm writting them at the last minute of my working day

    func getImage(with identifier: String) -> UIImage? {
        downloadInteractor.getDownloadedData(with: identifier).flatMap {
            UIImage(data: $0)
        }
    }

    func getOrDownloadImage(remoteUrl url: URL, completion: @escaping (Result<UIImage, DownloadError>) -> Void) {
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
