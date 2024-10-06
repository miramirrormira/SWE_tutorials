actor CustomSemaphore {
    private var count: Int
    private var waitingTasks: [CheckedContinuation<Void, Never>] = []
    
    init(value: Int) {
        self.count = value
    }
    
    func wait() async {
        // Check if the count is greater than 0, decrement and proceed
        if count > 0 {
            count -= 1
        } else {
            // Otherwise, wait for a signal
            await withCheckedContinuation { continuation in
                waitingTasks.append(continuation)
            }
        }
    }
    
    func signal() {
        // If there are waiting tasks, resume one
        if let continuation = waitingTasks.first {
            waitingTasks.removeFirst()
            continuation.resume()
        } else {
            // Otherwise, increment the count
            count += 1
        }
    }
}

// Example usage

func asyncTask(id: Int, semaphore: CustomSemaphore) async {
    await semaphore.wait()
    print("Task \(id) started")
    try? await Task.sleep(nanoseconds: 2_000_000_000) // Simulate a delay of 2 seconds
    print("Task \(id) finished")
    await semaphore.signal()
}

//@main
let semaphore = CustomSemaphore(value: 2)

// Creating multiple tasks
let tasks = (0..<5).map { id in
    Task {
        await asyncTask(id: id, semaphore: semaphore)
    }
}

// Await all tasks to complete
for task in tasks {
    await task.value
}
