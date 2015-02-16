/*
The MIT License (MIT)

Copyright (c) 2015 Rob

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


import Foundation
import UIKit

/**
* Custom UIButton.
*/
@IBDesignable class HopplaButton: UIButton {
    @IBInspectable var fgColor:UIColor = UIColor(white: 1, alpha: 0.9)
    @IBInspectable var fgColorHighlighted:UIColor = UIColor(white: 0, alpha: 0.7)
    @IBInspectable var bgColor:UIColor = UIColor(white: 0, alpha: 0.8)
    @IBInspectable var bgColorHighlighted:UIColor = UIColor.orangeColor()
    
    private let bgLayer = CALayer()
    
    
    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            if newValue {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.1)
                bgLayer.backgroundColor = bgColorHighlighted.CGColor
                CATransaction.commit()
            }
            else {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.7)
                bgLayer.backgroundColor = bgColor.CGColor
                CATransaction.commit()
            }
            super.highlighted = newValue
        }
    }
    init(awesomeTitle:String){
        super.init(frame: CGRectNull)
        doInit()
        setAwesomeTitle(awesomeTitle)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }
    
    func doInit(){
        clipsToBounds = true
        layer.borderColor = fgColor.CGColor
        layer.borderWidth = 1
        
        bgLayer.backgroundColor = bgColor.CGColor
        setTitleColor(fgColor, forState: UIControlState.Normal)
        setTitleColor(fgColorHighlighted, forState: UIControlState.Highlighted)
        layer.addSublayer(bgLayer)

    }
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.width += 10
        return size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if(bounds.height>bounds.width){
            bounds.size.width = bounds.size.height
        }
        bgLayer.frame = bounds
        layer.cornerRadius = bounds.height/2
    }
    func setAwesomeTitle(title: String){
        setTitle(title, forState: .Normal)
        self.titleLabel?.font =  UIFont(name: "FontAwesome",size: 20)
    }
    
}