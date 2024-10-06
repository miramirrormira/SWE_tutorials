import Foundation

class SafeArray<T> {
    var array = [T]()
    let serialQueue = DispatchQueue(label: "com.uynguyen.queue")
    
    /// reading using the serial queue
    var last: T? {
        var result: T?
        self.serialQueue.sync {
            result = self.array.last
        }
        return result
    }
    
    /// writing using the serial queue
    func append(_ newElement: T) {
        self.serialQueue.async() {
            self.array.append(newElement)
        }
    }
}

