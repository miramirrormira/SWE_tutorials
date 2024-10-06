import Foundation

let dispatchGroup = DispatchGroup()

for i in 0..<3 {
    dispatchGroup.enter()
    DispatchQueue.global().async {
        // download something ...
        dispatchGroup.leave()
    }
}

dispatchGroup.wait() //wait for all tasks in the group to finish
// do something when all tasks are finished
