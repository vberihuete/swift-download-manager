//
//  EntityDownloadInteractor.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 25/03/2022.
//

import Foundation
import RealityKit

@available(iOS 13, *)
final class EntityDownloadInteractor {
    private let downloadInteractor: DownloadInteractorProtocol

    init(
        downloadInteractor: DownloadInteractorProtocol = DownloadInteractor()
    ) {
        self.downloadInteractor = downloadInteractor
    }

    func getOrDownloadEntity(remoteUrl url: URL, completion: @escaping (Result<ModelEntity, DownloadError>) -> Void) {
        if let localUrl = downloadInteractor.getDownloadDataUrl(with: url.absoluteString) {
            loadEntity(url: localUrl, completion: completion)
        } else {
            let download = Download(identifier: url.absoluteString, url: url)
            downloadInteractor.startOrResume(download: download) { [weak self] result in
                switch result {
                case .success:
                    if let localUrl = self?.downloadInteractor.getDownloadDataUrl(with: url.absoluteString) {
                        self?.loadEntity(url: localUrl, completion: completion)
                    } else {
                        completion(.failure(.loadEntity))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func loadEntity(url: URL, completion: @escaping (Result<ModelEntity, DownloadError>) -> Void) {
        DispatchQueue.main.async {
            do {
                try completion(.success(ModelEntity.loadModel(contentsOf: url)))
            } catch {
                completion(.failure(.loadEntity))
            }
        }
    }
}
