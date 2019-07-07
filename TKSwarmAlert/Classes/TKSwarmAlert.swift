//
//  SWAlert.swift
//  SWAlertView
//
//  Created by Takuya Okamoto on 2015/08/18.
//  Copyright (c) 2015年 Uniface. All rights reserved.
//

import UIKit

open class TKSwarmAlert: NSObject {
    
    open var durationOfPreventingTapBackgroundArea: TimeInterval = 0
    open var fadeOutDuration: TimeInterval = 0.2
    
    fileprivate var staticViews: [UIView] = []
    var animationView: FallingAnimationView?
    var blurView: TKSWBackgroundView?
    
    var type: TKSWBackgroundType!
    
    public override init() {
        super.init()
        self.type = .blur
    }
    
    public init(backgroundType: TKSWBackgroundType = .blur) {
        super.init()
        self.type = backgroundType
    }
    
    open func addNextViews(_ views:[UIView]) {
        self.animationView?.nextViewsList.append(views)
    }
    
    open func addSubStaticView(_ view:UIView) {
        view.tag = -1
        self.staticViews.append(view)
    }
    
    @objc public func hide(){
        self.animationView?.onTapSuperView()
    }
    
    @objc public func show(_ views:[UIView], completion: (() -> Void)? = nil) {
        let window:UIWindow? = UIApplication.shared.keyWindow
        if window != nil {
            let frame:CGRect = window!.bounds
            blurView = TKSWBackgroundView(frame: frame, type: self.type)
            animationView = FallingAnimationView(frame: frame)
            
            if durationOfPreventingTapBackgroundArea > 0 {
                animationView?.enableToTapSuperView = false
                Timer.schedule(delay: durationOfPreventingTapBackgroundArea) { [weak self] _ in
                    self?.animationView?.enableToTapSuperView = true
                }
            }
            
            let showDuration:TimeInterval = 0.2
            
            for staticView in staticViews {
                let originalAlpha = staticView.alpha
                staticView.alpha = 0
                animationView?.addSubview(staticView)
                UIView.animate(withDuration: showDuration) {
                    staticView.alpha = originalAlpha
                }
            }
            window!.addSubview(blurView!)
            window!.addSubview(animationView!)
            blurView?.show(duration: showDuration, didEnd: {[unowned self] () -> Void in
                self.spawn(views)
            })
            animationView?.willDissmissAllViews = {
                for v in self.staticViews {
                    UIView.animate(withDuration: self.fadeOutDuration, animations: {
                        v.alpha = 0
                    })
                }
                
                UIView.animate(withDuration: self.fadeOutDuration, animations: {[unowned self] in
                    self.blurView?.alpha = 0
                })
            }
            animationView?.didDissmissAllViews = {
                self.blurView?.removeFromSuperview()
                self.animationView?.removeFromSuperview()
                
                for staticView in self.staticViews {
                    staticView.alpha = 1
                }
                
                completion?()
            }
        }
    }
    
    @objc public func spawn(_ views:[UIView]) {
        self.animationView?.spawn(views: views)
    }
}
