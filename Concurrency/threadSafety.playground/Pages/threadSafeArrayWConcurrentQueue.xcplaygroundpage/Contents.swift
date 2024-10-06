
// thread safety with concurrent queue
class SafeArray2<T> {
    var array = [T]()
    let concurrentQueue = DispatchQueue(label: "com.uynguyen.queue", attributes: .concurrent)
    
    /// reading using the concurrent queue
    var last: T? {
        var result: T?
        self.concurrentQueue.sync {
            result = self.array.last
        }
        return result
    }
    
    /// writing using the concurrent queue with flag barrier
    func append(_ newElement: T) {
        self.concurrentQueue.async(flags: .barrier) {
            self.array.append(newElement)
        }
    }
}
