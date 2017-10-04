/*
 Fixed-length ring buffer
 In this implementation, the read and write pointers always increment and
 never wrap around. On a 64-bit platform that should not get you into trouble
 any time soon.
 */
import Foundation

postfix operator ++!
postfix func ++!(value: inout Int64) {
    OSAtomicIncrement64(&value)
}

public struct RingBuffer<T> {
    private var array: [T?]
    private var writeIndex: Int64 = 0
    private var readIndex: Int64 = 0
    let resizeSemaphore = DispatchSemaphore(value: 1)
    
    public init() {
        array = [T?](repeating: nil, count: 16)
    }
    
    
    /* Write from one thread. */
    
    private var availableSpaceForWriting: Int64 {
        return Int64(array.count) - availableSpaceForReading
    }
    
    public var isFull: Bool {
        return availableSpaceForWriting == 0
    }

    public mutating func write(_ element: T) {
        if isFull {
            // block reading
            resizeSemaphore.wait()
            
            let count = array.count
            for i in 0..<count {
                array.append(array[i])
            }
            readIndex = readIndex % Int64(count)
            writeIndex = writeIndex % Int64(count)

            resizeSemaphore.signal()
        }
        
        array[Int(writeIndex) % array.count] = element
        writeIndex++!
    }
    
    
    /* Read from one other thread. */
    
    private var availableSpaceForReading: Int64 {
        return writeIndex - readIndex
    }
    
    public var isEmpty: Bool {
        return availableSpaceForReading == 0
    }
    
    mutating func read() -> T? {
        guard !isEmpty else {
            return nil
        }
        
        // read the array -- check we're not currently resizing it!
        resizeSemaphore.wait()
        let element = array[Int(readIndex) % array.count]
        readIndex += 1
        resizeSemaphore.signal()
        
        return element
    }
}
