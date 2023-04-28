//
//  OMComboGiftDisplayOperation.swift
//  GifttingBannerDemo
//
//  Created by kevin on 2023/4/28.
//

import Foundation

class OMComboGiftDisplayOperation: Operation {

    typealias Task = (OMComboGiftDisplayOperation) -> Void

    override var isAsynchronous: Bool { false }

    private var _isExecuting: Bool = false {
        willSet {
           willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    override var isExecuting: Bool { _isExecuting }

    private var _isFinished: Bool = false {
        willSet {
           willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    override var isFinished: Bool { _isFinished }

    private let semaphore = DispatchSemaphore(value: 1)

    private var task: Task?

    init(task: Task?) {
        self.task = task
        super.init()
    }

    override func start() {
        semaphore.wait()
        defer { semaphore.signal()}

        if isCancelled {
            return
        }

        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?._start()
        }
        _isExecuting = true
    }

    private func _start() {
        task?(self)
    }

    func finish() {
        semaphore.wait()
        defer { semaphore.signal()}

        if isCancelled {
            return
        }

        _isFinished = true
        _isExecuting = false
    }

    override func cancel() {
        semaphore.wait()
        defer { semaphore.signal()}

        if isFinished {
            return
        }

        super.cancel()
        _isFinished = true
        _isExecuting = false
    }

}
