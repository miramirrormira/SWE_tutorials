import Foundation

// Scenario 1: no dead lock
//let concurrentQueue = DispatchQueue(label: "concurrent", attributes: [.concurrent])
//concurrentQueue.sync {
//    print("1")
//    concurrentQueue.sync {
//        print("2")
//    }
//    print("3")
//}
//print("a------------------------")


// Scenario 2: deadlock!!!
//let serialQueue = DispatchQueue(label: "serial")
//serialQueue.sync {
//    print("1")
//    serialQueue.sync {
//        print("2")
//    }
//    print("3")
//}
//print("b------------------------")


// Scenario 3: deadlock!!!
//let serialQueue = DispatchQueue(label: "serial")
//serialQueue.async {
//    print("1")
//    serialQueue.sync {
//        print("2")
//    }
//    print("3")
//}
//print("c------------------------")

// Scenario 4: no dead lock
//let serialQueue = DispatchQueue(label: "serial")
//serialQueue.async {
//    print("1")
//    serialQueue.async {
//        print("2")
//    }
//    print("3")
//}
//print("f------------------------")


// Scenario 5: no dead lock
//let serialQueue1 = DispatchQueue(label: "serialQueue1")
//let serialQueue2 = DispatchQueue(label: "serialQueue2")
//serialQueue1.sync {
//    print("1")
//
//    serialQueue2.async {
//        print("2")
//
//        serialQueue1.sync {
//            print("3")
//        }
//    }
//}
//print("d-----------------------------")


// Scenario 6: deadlock!!!
//let serialQueue1 = DispatchQueue(label: "waiter")
//let serialQueue2 = DispatchQueue(label: "chef")
//serialQueue1.sync {
//    print("1")
//    
//    serialQueue2.sync {
//        print("2")
//        
//        serialQueue1.sync {
//            print("3")
//        }
//    }
//}
//print("e-----------------------------")
