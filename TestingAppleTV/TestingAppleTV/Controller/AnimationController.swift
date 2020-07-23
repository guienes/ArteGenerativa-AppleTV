//
//  AnimationController.swift
//  TestingAppleTV
//
//  Created by Lia Kassardjian on 22/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//

import UIKit

class AnimationController {
    
    private var animator: UIViewPropertyAnimator
    private var timer: Timer?
    private var duration: TimeInterval
    public var isVisible: Bool
    
    private weak var view: UIView?
    
    private var animation: () -> ()
    private var completion: ((UIViewAnimatingPosition) -> ())?
    
    init(view: UIView, duration: TimeInterval) {
        animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
        isVisible = false
        
        self.view = view
        self.duration = duration
        self.animation = {}
    }
    
    public func setAnimation(animation: @escaping () -> ()) {
        self.animation = animation
    }
    
    public func animate(delay: TimeInterval, reverts: Bool, with completion: ((UIViewAnimatingPosition) -> ())?) {
        timer?.invalidate()
        
        animator.stopAnimation(true)
        animator.addAnimations(animation)
               
        self.completion = completion
        
        animator.startAnimation()
        isVisible = true
        
        if reverts {
            setTimer(with: delay)
        }
    }
    
    public func setTimer(with duration: TimeInterval) {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
            timeInterval: duration,
            target: self,
            selector: #selector(self.showReverseAnimation),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc private func showReverseAnimation() {
        animator.stopAnimation(true)
        animator.addAnimations(animation)
        
        if let completion = self.completion {
            animator.addCompletion(completion)
        }
        
        animator.startAnimation()
        isVisible = !isVisible
        
        if isVisible {
            setTimer(with: duration)
        }
    }
    
    public func fadeInOut() {
        view?.alpha = isVisible ? 0 : 1
    }
    
    
}
