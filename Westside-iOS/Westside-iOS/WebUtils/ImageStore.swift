import Foundation
import UIKit

/**
 This class exposes a simple interface for fetching images over HTTP and caching them on the local filesystem.
 */
public class ImageStore: NSObject, URLSessionDelegate {
    ///
    public typealias CompletionBlock = (_ image: UIImage?) -> Void
    
    /**
     This is the singleton instance of ImageStore.
     */
    public static let store = ImageStore()
    
    private static let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "imagecache"
    
    /**
     This determines the maximum number of downloads that will occur at once. Defaults to 3. More simultaneous downloads
     means that a burst of fetches will cause all fetches to slow down. Less simultaneous downloads means that large
     images can clog up the image store so that other images must wait until they are finished.
     */
    public var maxSimultaneousDownloads = 3
    
    /**
     If an image fails to download, the store will not attempt to refetch that image even if it is asked for again until
     `refetchTimeInterval` seconds have elapsed.
     */
    public var refetchTimeInterval: TimeInterval = 120
    
    private var fetchSession: URLSession!
    private var failedFetchMap = Dictionary<String, Date>()
    private var throttleQueue = Array<URLSessionDownloadTask>()
    private var activeQueue = Array<URLSessionDownloadTask>()
    private var callbackMap = Dictionary<URL, Array<ImageStore.CompletionBlock>>()
    
    private override init() {
        super.init()
        
        try! FileManager.default.createDirectory(atPath: ImageStore.cachePath, withIntermediateDirectories: true, attributes: nil)
        fetchSession = URLSession(
            configuration: URLSessionConfiguration.ephemeral,
            delegate: self,
            delegateQueue: OperationQueue.main
        )
    }
    
    deinit {
        fetchSession.invalidateAndCancel()
    }
    
    /**
     Will attempt to fetch an image from the location url, which must have an `http://` or `https://` protocol
     specifier. If the image store had previously fetched this image and cached it, the cached image will be returned.
     Images fetched from the network through this method are automatically cached to the filesystem. The image is delivered
     through the completion block. If the image could not be fetched, the completion block will be called with `nil` as
     the parameter.
     
     - parameter urlString: The URL of the image.
     - parameter completion: A block in which the requested image is returned.
     - returns: `true` if the image was cached, `false` if there was no cached image. It does not indicate the
     availability of the image whatsoever
     */
    @discardableResult public func fetchImage(for urlString: String, completion: ImageStore.CompletionBlock? = nil) -> Bool {
        guard let url = URL(string: urlString) else {
            completion?(nil)
            return true
        }
        
        if let cachedImage = cachedImage(for: urlString) {
            completion?(cachedImage)
            return true
        }
        
        let cachedImagePath = cachePath(for: urlString)
        
        // Check to see if fetched within the `refetchTimeInterval`. If longer than `refetchTimeInterval` and
        // failed, try again.
        if let lastFailedDate = failedFetchMap[cachedImagePath] {
            if Date().timeIntervalSince(lastFailedDate) < refetchTimeInterval {
                completion?(nil)
                return true
            }
            
            failedFetchMap.removeValue(forKey: cachedImagePath)
        }
        
        if var existingCallbacks = callbackMap[url] {
            if let completion = completion {
                existingCallbacks.append(completion)
                callbackMap[url] = existingCallbacks
            }
        } else {
            if let completion = completion {
                callbackMap[url] = [completion]
            } else {
                callbackMap[url] = []
            }
            
            var downloadTaskRef: URLSessionDownloadTask! = nil
            let downloadTask = fetchSession.downloadTask(with: url) { (location, response, error) -> Void in
                let image: UIImage?
                if let realizedLocation = location, error == nil {
                    do {
                        if FileManager.default.fileExists(atPath: cachedImagePath) {
                            try FileManager.default.removeItem(atPath: cachedImagePath)
                        }
                        try FileManager.default.moveItem(at: realizedLocation, to: URL(fileURLWithPath: cachedImagePath))
                        image = UIImage(contentsOfFile: cachedImagePath)
                    } catch {
                        self.failedFetchMap[cachedImagePath] = Date()
                        image = nil
                    }
                } else {
                    self.failedFetchMap[cachedImagePath] = Date()
                    image = nil
                }
                
                self.activeQueue.remove(at: self.activeQueue.index(of: downloadTaskRef)!)
                
                if let completions = self.callbackMap[url] {
                    completions.forEach { $0(image) }
                    self.callbackMap.removeValue(forKey: url)
                }
                
                self.dequeue()
            }
            
            downloadTaskRef = downloadTask
            throttleQueue.append(downloadTask)
            
            dequeue()
        }
        
        return false
    }
    
    /**
     Will return a cached image previously downloaded from the location url. If no image has previously been cached, this
     method returns `nil`.
     
     - parameter url: The URL of the image.
     
     - returns: A cached image or `nil`.
     */
    public func cachedImage(for url: String) -> UIImage? {
        let cachedImagePath = cachePath(for: url)
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: cachedImagePath)) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    /**
     This will clear the filesystem cache of all images it has created.
     */
    public func deleteAllCachedImages() {
        let fileManager = FileManager.default
        try! fileManager.removeItem(atPath: ImageStore.cachePath)
        try! fileManager.createDirectory(atPath: ImageStore.cachePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    // MARK: - Helpers
    
    private func dequeue() {
        if activeQueue.count < maxSimultaneousDownloads {
            if let queuedTask = throttleQueue.first {
                activeQueue.append(queuedTask)
                throttleQueue.removeFirst()
                
                queuedTask.resume()
            }
        }
    }
    
    private func cachePath(for url: String) -> String {
        return URL(fileURLWithPath: ImageStore.cachePath).appendingPathComponent(safeString(for: url)).path
    }
    
    private func safeString(for url: String) -> String {
        return url
            .replacingOccurrences(of: "https?://", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "[^0-9A-Za-z_-]", with: "", options: .regularExpression, range: nil)
    }
    
    // MARK: - Deprecated
    
    @available(*, deprecated: 2.0, renamed: "fetchImage(for:completion:)")
    public func fetchImageForURLString(_ urlString: String, completion: @escaping ImageStore.CompletionBlock) -> Bool {
        return fetchImage(for: urlString, completion: completion)
    }
    @available(*, deprecated: 2.0, renamed: "cachedImage(for:)")
    public func cachedImageForURLString(_ url: String) -> UIImage? {
        return cachedImage(for: url)
    }
}

