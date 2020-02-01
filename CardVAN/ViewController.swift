//
//  ViewController.swift
//  CardVAN
//
//  Created by abdullah  on 06/06/1441 AH.
//  Copyright © 1441 abdullah . All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum CardState  {
        case expanded
        case collapsed
    }
    
    
    var cardVC : CardVC!
    var visualEffectView : UIVisualEffectView!
    
    let cardHeight : CGFloat = 600
    let cardHandleAreaHeight : CGFloat = 65
    
    var cardVisible = false
    var nextState : CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningANS = [UIViewPropertyAnimator]()
    var animtionPRWD : CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCard()
        
    }
    
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        cardVC = CardVC(nibName : "CardVC" , bundle : nil)
        self.addChild(cardVC)
        self.view.addSubview(cardVC.view)
        cardVC.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        cardVC.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognzier:)))
        let pangestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognzier:)))
        
        cardVC.ActionView.addGestureRecognizer(tapGestureRecognizer)
        cardVC.ActionView.addGestureRecognizer(pangestureRecognizer)
        
    }
    
    @objc
    func handleCardTap(recognzier : UITapGestureRecognizer) {
        
        
        
    }
    
    @objc
    func handleCardPan(recognzier : UIPanGestureRecognizer) {
        switch recognzier.state {
        case .began :
            // startTransition
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed :
            // updateTransition
            let translation = recognzier.translation(in: self.cardVC.ActionView)
            var fractionCompleted = translation.y / cardHeight
            fractionCompleted = cardVisible ? fractionCompleted : -fractionCompleted
            updateInteractiveTransition(fractionCompleted: fractionCompleted)
        case .ended :
            // continueTransition
            continueInteractiveTransition()
            
        default:
            break
        }
        
        
    }
    
    func animateTRIfNeeded (state : CardState , duration : TimeInterval) {
        if runningANS.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case.expanded : self.cardVC.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed : self.cardVC.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningANS.removeAll()
            }
            frameAnimator.startAnimation()
            runningANS.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded :
                    self.cardVC.view.layer.cornerRadius = 12
                case .collapsed :
                    self.cardVC.view.layer.cornerRadius = 0
                    
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningANS.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded : self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed : self.visualEffectView.effect = nil
                    
                }
            }
            
            blurAnimator.startAnimation()
            runningANS.append(blurAnimator)
            
            
        }
        
        
        
    }
    
    func startInteractiveTransition(state : CardState , duration : TimeInterval) {
        if runningANS.isEmpty {
            // run animations
            animateTRIfNeeded(state: state, duration: duration)
            
        }
        for animator in runningANS {
            animator.pauseAnimation()
            animtionPRWD = animator.fractionComplete
        }
        
    }
    
    func updateInteractiveTransition(fractionCompleted : CGFloat) {
        for animator in runningANS {
            animator.fractionComplete = fractionCompleted + animtionPRWD
        }
        
        
        
    }
    
    func continueInteractiveTransition() {
        for animator in runningANS {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        
    }
    
    
    
    
    
}

