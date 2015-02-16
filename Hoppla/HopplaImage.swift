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
//NOTE: constraints were  removed, manual layout has better berformence when there is large amount of views
@IBDesignable  class HopplaImage: UIView {
    ///animation duration of animateHoppla or show/hide label
    var animDuration = 0.2;
    
    ///font size for label, changes also the label corner radius and padding
    @IBInspectable var fontSize:CGFloat = 20 {
        didSet{
            if(_labValue != nil){
                _labValue!.font = _labValue!.font.fontWithSize(fontSize)
                layoutLabel()
                //_heightUpdated()
            }
        }
    }
    
    ///enable or disable blur effect instad of opacity background of label (blur needs more resources while scrolling)
    @IBInspectable var blurEnabled:Bool = false{
        didSet{
            if(_labValueWrap != nil){
                if(blurEnabled){
                    _labValueWrap!.backgroundColor = nil
                    _effectView = UIVisualEffectView (effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
                    _labValueWrap!.addSubview(_effectView!)
                    _labValueWrap!.sendSubviewToBack(_effectView!)
                    //                    _layoutEffectView()
                }else{
                    _labValueWrap!.backgroundColor = UIColor(white: 1, alpha: 0.5)
                    _effectView?.removeFromSuperview()
                    _effectView = nil
                }
            }
        }
    }
    
    
    //main image view
    private var _imageView : UIImageView?
    
    ///name of image for main image view
    @IBInspectable var imageName:String?{
        didSet{
            if(imageName != nil){
                if(_imageView == nil){
                    _imageView = UIImageView(image: UIImage(named: imageName!))
                    addSubview(_imageView!)
                    _imageView!.contentMode = imgContentMode
                    sendSubviewToBack(_imageView!)
                    //                    _layoutImage()
                }else{
                    _imageView!.image = UIImage(named: imageName!)
                }
            }
        }
    }
    
    ///content mode attribute of main image view
    @IBInspectable var imgContentMode: UIViewContentMode = .ScaleAspectFit{
        didSet{
            _imageView?.contentMode = imgContentMode
        }
    }
    
    ///main image view padding in this view
    @IBInspectable var imagePadding: CGFloat = 0 {
        didSet{
            if(imagePadding != oldValue){
                setNeedsLayoutForce()
            }
        }
    }
    
    //labels components
    private var _labValueWrap: UIView?
    private var _effectView:UIVisualEffectView?
    private var _labValue:UILabel?
    
    ///whether the labale is shown or hidden
    @IBInspectable var labelHidden:Bool = true {
        didSet{
            if(labelHidden){
                if let lw = _labValueWrap{
                    lw.removeFromSuperview();
                    _labValueWrap = nil
                    _effectView = nil
                    _labValue = nil
                }
            }else{
                _labValueWrap = UIView()
                _labValue = UILabel()
                
                addSubview(_labValueWrap!)
                _labValueWrap!.clipsToBounds = true
                _labValueWrap!.addSubview(_labValue!)
                
                var old = blurEnabled //TODO invoke did set of blur enabled
                blurEnabled = old
                
                _labValue!.text = "\(value)"
                _labValueWrap!.layer.borderColor = UIColor.blackColor().CGColor
                _labValueWrap!.layer.borderWidth = 1
                _labValue!.textColor = UIColor.blackColor()
                _labValue!.font = UIFont.boldSystemFontOfSize(fontSize)
                
                _labValue!.numberOfLines = 1;
                _labValue!.textAlignment = NSTextAlignment.Center
                _labValue!.baselineAdjustment = UIBaselineAdjustment.AlignCenters
                
                bringSubviewToFront(_labValueWrap!)
                setNeedsLayoutForce()
            }
        }
    }
    //ability to hide label with animation
    func hideLabel(animate: Bool = true){
        if(_labValueWrap != nil){
            if(animate){
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self._labValueWrap!.alpha = 0
                    }, completion: { (f) -> Void in
                        self.labelHidden = true
                })
            }else{
                labelHidden = true
            }
        }
    }
    //ability to show label with animation
    func showLabel(animate:Bool = true){
        if(labelHidden){
            labelHidden = false
            if(animate){
                _labValueWrap!.alpha = 0
                layoutLabel()
                UIView.animateWithDuration(1, animations: { () -> Void in
                    self._labValueWrap!.alpha = 1
                    }, completion: { (f) -> Void in
                })
            }
        }
    }
    
    ///view can cald the value, label displays it
    var value:Int = 0{
        didSet{
            _labValue?.text = "\(value)"
            layoutLabel()
            
        }
    }
    ///set value with ability to animate increase or decrase
    func setValue(value:Int, withAnimation:Bool = true){
        if(value != self.value){
            if(withAnimation){
                animateHoppla(value>self.value)
            }
            self.value = value
        }
    }
    
    func setNeedsLayoutForce() {
        _w = 0
        setNeedsLayout()
    }
    
    //MARK - helpers and layout
    private var _w:CGFloat = 0, _h:CGFloat = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        if(bounds.width != _w || bounds.height != _h){
            _w = bounds.width
            _h = bounds.height
            
            //image
            layoutImg()
            
            //label
            layoutLabel()
        }
    }
    private func layoutImg(){
        if let iv = _imageView{
            iv.frame = CGRect(x: imagePadding, y: imagePadding, width: bounds.width - 2*imagePadding, height: bounds.height - 2*imagePadding)
        }
    }
    private func layoutLabel(){
        //labelwrap
        
        if let lw = _labValueWrap{
            if let lv = _labValue{
                lv.sizeToFit()
                var h = ceil(lv.bounds.height/3)
                lw.layer.cornerRadius = h
                //lv frame
                lv.frame.origin.x = h
                lv.frame.origin.y = 0
                
                //lw frame
                lw.frame.size.width = lv.bounds.width + 2*h
                lw.frame.size.height = lv.bounds.height
                lw.frame.origin.x = bounds.size.width - lw.bounds.width
                lw.frame.origin.y = bounds.size.height - lw.bounds.height
                
            }
            if let ev = _effectView{
                ev.frame = lw.bounds
            }
        }
    }
    
    
    //MARK: - animation (positive or negativ hoppla)
    func animateHoppla(positive: Bool){
        if(_imageView != nil){
            var t = CGAffineTransformIdentity
            var t2 = CGAffineTransformIdentity
            var t3 = CGAffineTransformIdentity
            if positive {
                t = CGAffineTransformScale(t, 1.4, 1.4)
                t2 = CGAffineTransformScale(t2, 0.9, 0.9)
                
            }else{
                t = CGAffineTransformScale(t, 0.6, 0.6)
                t2 = CGAffineTransformScale(t2, 1.1, 1.1)
            }
            UIView.animateWithDuration(animDuration,
                delay: 0.0,
                options: .CurveEaseIn ,
                animations: {
                    self._imageView!.transform = t
                },
                completion: {
                    finished in
                    UIView.animateWithDuration(self.animDuration,
                        delay: 0.0,
                        options: .CurveEaseOut ,
                        animations: {
                            self._imageView!.transform = t2
                        },
                        completion:{
                            finished in
                            UIView.animateWithDuration(self.animDuration,
                                delay: 0.0,
                                options: .CurveEaseOut,
                                animations: {
                                    self._imageView!.transform = t3
                                },
                                completion:{
                                    finished in
                                    self.layoutImg()
                                }
                            )
                        }
                    )
                }
            )
        }
    }
    
}

