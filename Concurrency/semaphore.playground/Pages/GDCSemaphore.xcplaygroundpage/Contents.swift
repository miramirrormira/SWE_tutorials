import Foundation

let semaphore = DispatchSemaphore(value: 5)

func downloadImage(_ i: Int) {
    // simulate download image task
    semaphore.wait()
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Double(Int.random(in: 0..<3))) {
        // download image
        
        print("finished downloading image \(i)")
        semaphore.signal()
    }
}


for i in 0..<100 {
    downloadImage(i)
}

