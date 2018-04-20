final class CleanupSubscriber<T>: SubscriberBase<T> {
    private let disposeAction: DisposableAction
    
    init(_ action: DisposableAction) {
        self.disposeAction = action
        super.init(handler: { _ in })
    }

    override func dispose() {
        super.dispose()
        disposeAction.dispose()
    }
}
