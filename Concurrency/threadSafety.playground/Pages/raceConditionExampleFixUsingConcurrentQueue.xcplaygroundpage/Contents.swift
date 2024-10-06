import Foundation

var value: Int = 0

/* FIX:
 We can make `value` thread safe -- prevent race conditions, using a concurrent queue. The concurrent queue will allow concurrent read operations on `value`, e.g. `readValue` function. When executing a write operation, we will apply barrier flag to the concurrent queue, which means the write operation will be executed after finishing all tasks that's already scheduled in the concurrent queue, and while executing the write operation, the concurrent queue will not work on any other task, essentially acting as a serial queue, preventing race condition.
 */

let concurrentQueue = DispatchQueue(label: "concurrent", attributes: [.concurrent])
func increaseValue() {
    // apply flag barrier to the concurrent queue. The block of code dispatched to the concurrent queue with flag barrier will be executed as if being executed using a serial queue, which prevents race condition
    concurrentQueue.async(flags: .barrier) {
        value += 1
    }
}

func readValue() -> Int {
    // concurrently read the value
    concurrentQueue.sync {
        value
    }
}

let dispatchGroup = DispatchGroup()
for i in 0..<10000 {
    dispatchGroup.enter()
    DispatchQueue.global().async {
        increaseValue()
        dispatchGroup.leave()
    }
}

dispatchGroup.wait()
// `value` will always be 10,000 here
print("raceConditionExampleFixUsingConcurrentQueue, value = ", readValue())
