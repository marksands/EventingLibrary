public final class DisposableAction: Disposable {
    private let action: () -> ()

    public init(_ action: @escaping () -> ()) {
        self.action = action
    }

    public func dispose() {
        action()
    }
}
