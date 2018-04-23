public protocol Disposable {
    func dispose()
    var isDisposed: Bool { get }
}
