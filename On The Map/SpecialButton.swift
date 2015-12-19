//
//  SpecialButton.swift
//  On The Map
//
//  Created by Manish Sharma on 12/6/15.
//  Copyright © 2015 CelG Mobile LLC. All rights reserved.
//

import Foundation
import UIKit 


class SpecialButton: UIButton {
    //Define properties
    
    // Congigurations and Constants
    let udacityMain = UIColor(red: 1.00, green: 0.60, blue: 0.0, alpha: 1.0)
    let udacityLight = UIColor(red: 0.96, green: 0.70, blue: 0.42, alpha: 1.0)
    let darkBlue = UIColor(red: 0.00, green: 0.298, blue: 0.686, alpha: 1.0)
    let lightBlue = UIColor(red: 0.00, green: 0.501, blue: 0.839, alpha: 1.0)
    let titleLabelFontSize: CGFloat = 17.0
    let specialButtonHeight: CGFloat = 44.0
    let specialButtonCornerRadius: CGFloat = 4.0
    let specialButtonExtraPadding: CGFloat = 14.0
    
    var backingColor: UIColor? = nil
    var highlightedBackingColor: UIColor? = nil
    
    // Mark: Initiazation
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.themeBorderedButton()
    }
    
    func themeBorderedButton() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = specialButtonCornerRadius
        self.highlightedBackingColor = darkBlue
        self.backingColor = lightBlue
        self.backingColor = lightBlue
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: titleLabelFontSize)
    }
    
    // Mark: Setters
    
    private func setBackingColor(backingColor : UIColor) -> Void {
        if self.backingColor != nil {
            self.backingColor = backingColor
            self.backgroundColor = backingColor
        }
    }
    
    private func setHighlightedBackingColor(highlightedBackingColor: UIColor) -> Void {
        if self.highlightedBackingColor != nil {
            self.highlightedBackingColor = highlightedBackingColor
            self.backingColor = highlightedBackingColor
        }
    }
    
    // Mark: Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        self.backgroundColor = highlightedBackingColor
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        self.backgroundColor = backingColor
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        self.backgroundColor = backingColor
    }
    
    // Mark: Layout
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let extraPadding: CGFloat = specialButtonExtraPadding
        var sizeThatFits = CGSizeZero
        sizeThatFits.width = super.sizeThatFits(size).width + extraPadding
        sizeThatFits.height = self.specialButtonHeight
        return sizeThatFits
    }
}

