# swift-download-manager

A download manager with pure swift code.

Stores to device's file system and keeps track of active, completed and interrupted downloads.

The code provides a general structure for download and current version has implementation for:
 - ImageDownloaderInteractor
 - EntityDownloadInteractor


sample usage of `ImageDownloaderInteractor`:

```swift
import swift_download_manager
...
...
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
