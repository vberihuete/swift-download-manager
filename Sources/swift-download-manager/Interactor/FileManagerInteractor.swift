//
//  FileManagerInteractor.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 25/03/2022.
//

import Foundation

protocol FileManagerInteractorProtocol {
    func saveToDocumentsDirectory(orignalUrl url: URL, tempLocation location: URL) -> URL?
    func getFileUrl(lastPathComponent pathComponent: String) -> URL?
}

final class FileManagerInteractor: FileManagerInteractorProtocol {
    func saveToDocumentsDirectory(orignalUrl url: URL, tempLocation location: URL) -> URL? {
        guard let savedURL = getDocumentsDirectory()?.appendingPathComponent(url.lastPathComponent) else { return nil }
        try? FileManager.default.moveItem(at: location, to: savedURL)
        return savedURL
    }

    func getFileUrl(lastPathComponent pathComponent: String) -> URL? {
        getDocumentsDirectory()?.appendingPathComponent(pathComponent)
    }
}

private extension FileManagerInteractor {
    private func getDocumentsDirectory() -> URL? {
        try? FileManager.default.url(
            for: .documentDirectory,
               in: .userDomainMask,
               appropriateFor: nil,
               create: false
        )
    }
}
