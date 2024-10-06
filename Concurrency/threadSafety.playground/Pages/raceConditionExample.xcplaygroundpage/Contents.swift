import Foundation

// in our example, a race condition will happen when updating value
var value: Int = 0

/* Race Condition:
 Race condition happens when the value is updated CONCURRENTLY. 
 
 Let's say at a given moment, our value is equal to 10. Two different threads are trying to add 1 to our value, i.e. mutating our value. Each of the two threads are going to make a copy of our value, which is equal to 10, then add 1 to it. Both of the two threads are going to get 11 and write it back to the value's address. At the end, our value will be equal to 11, but it should be equal to 12.
 
 The above example described a scenario where race condition happened while mutating value concurrently. It means value is not thread safe. When an object or a value is not thread safe, then it is subject to race condition. To be thread safe is to be race condition proof.
 */

// a simple function that adds one to our value
func increaseValue() {
    value += 1
}

// let's call increaseValue CONCURRENTLY for 10,000 times, without race condition, our value should be 10,000 at the end of the process
// execute the code multiple times, you will find that "print(value)" will print values NOT equal to 10,000.
// Why is that?

let dispatchGroup = DispatchGroup() //dispatch group is not used for creating the race condition, it is used to make sure that when "print(value)" is executed, every increaseValue() function has finished execution. "dispatchGroup.wait()" is to guarantee it.
for i in 0..<10000 {
    dispatchGroup.enter()
    DispatchQueue.global().async { // using the global concurrent queue
        increaseValue()
        dispatchGroup.leave()
    }
}

dispatchGroup.wait()
print("raceConditionExample, value = ", value)
