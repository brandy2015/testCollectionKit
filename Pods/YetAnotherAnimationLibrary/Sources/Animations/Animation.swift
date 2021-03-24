// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// Base animation class
/// Provides start/finish/cancel/stop functions to an animation
/// 
open class Animation: NSObject, Animatable {
    public private(set) var isRunning: Bool = false
    public private(set) var completionHandler: ((Bool) -> Void)?

    public func start(_ completionHandler: ((Bool) -> Void)? = nil) {
        if let oldCompletion = self.completionHandler {
            oldCompletion(false)
            self.completionHandler = completionHandler
        }
        self.completionHandler = completionHandler
        if isRunning { return }
        isRunning = true
        willStart()
        Animator.shared.add(animation: self)
    }

    public func finish() {
        if !isRunning { return }
        isRunning = false
        Animator.shared.remove(animation: self)
        didEnd(finished: true)
    }

    public func cancel() {
        if !isRunning { return }
        isRunning = false
        Animator.shared.remove(animation: self)
        didEnd(finished: false)
    }

    public func stop() {
        cancel()
    }

    // override point for subclass
    open func willUpdate() { }
    open func update(dt: TimeInterval) { }
    open func didUpdate() { }
    open func willStart() { }
    open func didEnd(finished: Bool) {
        completionHandler?(finished)
        completionHandler = nil
    }

    // called by animator
    internal final func displayTick(dt: TimeInterval) {
        willUpdate()
        update(dt: dt)
        didUpdate()
    }
}
