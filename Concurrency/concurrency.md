## [Async and Sync](https://www.donnywals.com/dispatching-async-or-sync-the-differences-explained/)

### Async
When you use a dispatch queue's `async` method, you are asking it to perform the work in your closure, but you are also telling it that you don't need the work to be performed right now, and you don't want to wait for the work to be done.

#### Dispatching asynchronously from one queue to another
The resteraunt analogy:
Waiter is the main queue, it takes orders from customers; sends orders to the kitchen; and brings the prepared food to the customer when the kitchen finishes preparing them. 
Kitchen is a background queue, it receives orders from the waiter, prepares the orders, and notifies the waiter when the food is ready.

When the waiter sends a order to the kitchen, the waiter is dispatching work asynchronously to the kitchen. The waiter will go take more orders from other customers while the kitchen is working on the current order.

#### Dispatching asynchronously within the same queue
When you dispatch work asynchronously within the same queue, the queue will finish whatever it is currently working on, then move on to the work that is asynchronously dispatched.

The resteraunt analogy:
The waiter is currently delivering food to customer A, the waiter past a table and said to customer B: "I will be right with you." The waiter asynchronously dispatched the work (taking the order from customer B) to themselves, while continued with their current work, which is delivering the food to customer A.

### Sync
When you dispatch a body of work using `sync`, the current queue will wait for the body of work to complete until it can continue doing any work.

The resteraunt analogy:
The waiter sent an order to the kitchen and then stood there waiting for the kitchen to finish preparing the food.

#### When to use sync
Avoid multithreading problems, ensure multithread safety
```
class DateFormatterCache {
  private var formatters = [String: DateFormatter]()
  private let queue = DispatchQueue(label: "DateFormatterCache: \(UUID().uuidString)")

  func formatter(using format: String) -> DateFormatter {
    return queue.sync { [unowned self] in
      if let formatter = self.formatters[format] {
        return formatter
      }

      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = format
      self.formatters[format] = formatter

      return formatter
    }
  }
}
```

`Dispatch queue` is serial by default, which means only one task at a time that access the `formatters` dictionary. 
Without this serial queue, it will be thread unsafe when multiple threads are calling the `formatter(using:)` method to read/write the `formatter` dictionary at the same time. This means that we could end up creating the same `formatter` multiple time, or the `formatters` dictionary could go missing from the cache entirely.
With this serial queue, when multiple threads are calling the `formatter(using:)` method at the same time, the work will be performed one by one. Since the work is dispatched synchronously, each thread will wait until the dispatched work is done, and get the returned `formatter`

## [Deadlocks](https://www.donnywals.com/understanding-how-dispatchqueue-sync-can-cause-deadlocks/)
A deadlock happens when the system is waiting for some resource to free up but logically it's impossible for that resource to become available. The resource can be almost anything, e.g. a database handle, a file on the filesystem, or even time to run code on the CPU.

Error message:
```
EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
```

#### Deadlock within the same queue
In a serial queue, tasks are performed one by one. If you synchronously dispatch task A within task B, then task B will wait for task A to finish, but task A will not start until task B finishes since both tasks are on a serial queue where tasks are performed one by one.
```
let serialQueue = DispatchQueue(label: "serial")
serialQueue.sync {
    print("task B") // task B will not finish because it will be waiting for task A
    serialQueue.sync {
        print("task A") // task A will not start because task B has to finish before it starts
    }
}

serialQueue.async {
    print("task B") // task B will not finish because it will be waiting for task A
    serialQueue.sync {
        print("task A") // task A will not start because task B has to finish before it starts
    }
}

serialQueue.sync {
    print("task B") // task B will finish because it doesn't have to wait for task A to finish
    serialQueue.async {
        print("task A") // task A will start once task B finishes
    }
}
```


#### Deadlock with two queues
The waiter queue synchronously dispatched the task of preparing the soup to the chef queue, and starts waiting for the chef to finish. The chef queue synchronously dispatched a task to the waiter queue for asking what kind of soup does the customer want, and expects the answer in order to prepare the food. But the waiter queue will never start the task of asking for what kind of soup, because the waiter is waiting for the chef to finish preparing the food, the waiter queue is a serial queue, it will not start the next task before the previous task is done. 

```
let waiter = DispatchQueue(label: "waiter")
let chef = DispatchQueue(label: "chef")

// synchronously order the soup
waiter.sync {
  print("Waiter: hi chef, please make me 1 soup.")

  // synchronously prepare the soup
  chef.sync {
    print("Chef: sure thing! Please ask the customer what soup they wanted.")

    // synchronously ask for clarification
    waiter.sync {
      print("Waiter: Sure thing!")
      print("Waiter: Hello customer. What soup did you want again?")
    }
  }
}
```

#### Avoid deadlock in practice
The above example is not likely the case in real production code. In practice, a deadlock is hard to unravel when you use `sync` a lot.

##### Avoid running tasks from external party
In `run(closure:)`, you are having `myQueue` synchronously run a block of code (`closure`) from an external party. `closure` could contain code that causes deadlock, e.g. another `run(closure:)`
```
func run(_ closure: @escaping () -> Void) {
  myQueue.sync {
    closure()
  }
}
```
##### make the queue private
In the `DateFormatterCache` example, `queue` is private property. It's impossible for other actors to dispatch to this queue.

## Asynchronous operations



## Avoiding excessive thread creation
After reading this blog post it might be tempting to create a lot of queues to gain better performance in your app. Unfortunately, creating threads comes with a cost and you should, therefore, avoid excessive thread creation.

There are two common scenarios in which excessive thread creation occurs:

1. Too many blocking tasks are added to concurrent queues forcing the system to create additional threads until the system runs out of threads for your app
2. Too many private concurrent dispatch queues exist that all consume thread resources.

### why does it consume thread resources when creating many concurrent queues?
NEED ANSWER!

### How to prevent excessive thread creation?
It’s best practice to make use of the global concurrent dispatch queues. This prevents you from creating too many private concurrent queues. Apart from this, you should still be conscious of executing long-blocking tasks.

You can make use of the global concurrent queue as follows:
```
DispatchQueue.global().async {
    /// Concurrently execute a task using the global concurrent queue. Also known as the background queue.
}
```
This global concurrent queue is also known as the background queue and used next to the DispatchQueue.main.