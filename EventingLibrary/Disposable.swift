import Foundation

public protocol Disposable {
    func dispose()
}

public final class DisposeBag: Disposable {
    private var disposables: [Disposable] = []
    
    public init() {
        
    }
    
    public func addDisposable(_ disposable: Disposable) {
        disposables.append(disposable)
    }
    
    public func dispose() {
        disposables.forEach { $0.dispose() }
        disposables.removeAll()
    }
}

public func += (disposeBag: DisposeBag, disposable: Disposable) {
    disposeBag.addDisposable(disposable)
}
