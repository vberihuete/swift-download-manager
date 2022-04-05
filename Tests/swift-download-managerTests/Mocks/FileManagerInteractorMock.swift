//
//  FileManagerInteractorMock.swift
//  
//
//  Created by Vincent Berihuete on 05/04/2022.
//

@testable import swift_download_manager
import Foundation

final class FileManagerInteractorMock: FileManagerInteractorProtocol {
    lazy var saveToDocumentsDirectoryMock = MockFunc.mock(for: saveToDocumentsDirectory)
    func saveToDocumentsDirectory(orignalUrl url: URL, tempLocation location: URL) -> URL? {
        saveToDocumentsDirectoryMock.callAndReturn((url, location))
    }

    lazy var getFileUrlMock = MockFunc.mock(for: getFileUrl)
    func getFileUrl(lastPathComponent pathComponent: String) -> URL? {
        getFileUrlMock.callAndReturn(pathComponent)
    }
}
