//
//  DefaultDownloadInteractor.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

import Foundation

public final class DefaultDownloadInteractor {
    private let downloadInteractor: DownloadInteractorProtocol

    public convenience init() {
        self.init(downloadInteractor: DownloadInteractor())
    }

    init(
        downloadInteractor: DownloadInteractorProtocol = DownloadInteractor()
    ) {
        self.downloadInteractor = downloadInteractor
    }

    func getOrDownload(remoteUrl url: URL, completion: @escaping (Result<URL, DownloadError>) -> Void) {
        if let localUrl = downloadInteractor.getDownloadDataUrl(with: url.absoluteString) {
            completion(.success(localUrl))
        } else {
            let download = Download(identifier: url.absoluteString, url: url)
            downloadInteractor.startOrResume(download: download) { [weak self] result in
                switch result {
                case .success:
                    if let localUrl = self?.downloadInteractor.getDownloadDataUrl(with: url.absoluteString) {
                        completion(.success(localUrl))
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

