import Foundation

var value: Int = 0

/* FIX:
 We can make `value` thread safe -- prevent race conditions, using a serial queue. We can do this by having all read and write operations of `value` executed in the serial queue. Because serial queue only handle one task at a time, even if you are triggering the increaseValue function concurrently, the write operation of `value` will be handled one by one in the serial queue
 */

let serialQueue = DispatchQueue(label: "serial")
func increaseValue() {
    serialQueue.sync { // all write operations of `value` will be handled by serialQueue. It guarantees that tasks of increasing `value` by 1 will happen one after another, never simultaniously.
        value += 1
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
print("raceConditionExampleFixUsingConcurrentQueue, value = ", value)
