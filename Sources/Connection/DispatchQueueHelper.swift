import Foundation

extension DispatchQueue {
    func asyncIfNeeded(group: DispatchGroup? = nil, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute work: @escaping @convention(block) () -> Void) {
        if self === DispatchQueue.main && Thread.isMainThread {
            work()
        } else {
            async(group: group, qos: qos, flags: flags, execute: work)
        }
    }
}
