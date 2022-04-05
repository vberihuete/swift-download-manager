# swift-download-manager

A download manager with pure swift code.

Stores to device's file system and keeps track of active, completed and interrupted downloads.

The code provides a general structure for download and current version has implementation for:
 - `ImageDownloaderInteractor`
 - `EntityDownloadInteractor`
 - `DefaultDownloadInteractor`


Sample usage of `ImageDownloaderInteractor`:

```swift
import swift_download_manager
// ...
override func viewDidAppear(_ animated: Bool) {
   super.viewDidAppear(animated)
   ImageDownloaderInteractor().getOrDownloadImage(remoteUrl: url) { result in
         switch result {
            case let .success(image):
            // use image
            case let .failure(error):
            // handle error
         }
    }
}
```
For such cases `ImageDownloaderInteractor` will try to start or resume an interrupted download of the image based on the given url.

Sample usage of `DefaultDownloadInteractor`:

```swift
import swift_download_manager
// ...
final class YourCustomDownloadInteractor {
  private let defaultDownloadInteractor = DefaultDownloadInteractor() // you should use protocols 😄 and dependency injection for testing
  // `YourSomething` can be anything you like an UIImage, a PDF whatever you need to download, etc
  // you would just need to use the local url provided in the completion of DefaultDownloadManager to cast/load 
  func getOrDownloadSomething(remoteUrl url: URL, completion: @escaping (Result<YourSomething>, DownloadError)) {
     defaultDownloadManager.getOrDownload(remoteUrl: url) { result in 
     // here for example URL is used to create a Data object and based on that get an UIImage
        completion(
          result.map { url in
             (try? Data(contentsOf: url)).map { UIImage(data: $0)}
          }
        )
     }
  }
}
```
