import UIKit

class StockLogoProvider {
    
    var imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {
            DispatchQueue.global(qos: .utility).async {
                let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
                let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                    
                    guard error == nil,
                          data != nil,
                          let response = response as? HTTPURLResponse,
                          response.statusCode == 200,
                          let strongSelf = self else {
                        completion(nil)
                        return
                    }
                    
                    if let image = UIImage(data: data!) {
                        strongSelf.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    } else {
                        completion(nil)
                    }
                }
                dataTask.resume()
            }
        }
    }
}
