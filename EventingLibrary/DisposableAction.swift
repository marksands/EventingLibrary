public final class DisposableAction: Disposable {
    private let action: () -> ()
    public var isDisposed = false

    public init(_ action: @escaping () -> ()) {
        self.action = action
    }

    public func dispose() {
        guard !isDisposed else { return }
        action()
        isDisposed = true
    }
}
