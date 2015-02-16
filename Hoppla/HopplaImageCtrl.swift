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



import UIKit

class HopplaImageCtrl: UIViewController {

    @IBOutlet weak var hopplaImg: HopplaImage!
    @IBOutlet weak var hopplaImgSmall: HopplaImage!
    @IBOutlet weak var manView: ManualView!
    

    private var _goingUpSmall:Bool = true
    @IBAction func tapImgSmallAction(sender: UITapGestureRecognizer) {
        if(sender.view is HopplaImage){
            var val = (sender.view as HopplaImage).value
            if (val == 20) {
                _goingUpSmall = false;
            }else if (val == 0){
                _goingUpSmall = true
            }
            val = _goingUpSmall ? (val + 1) : (val - 1)
            (sender.view as HopplaImage).setValue(val, withAnimation: true)
        }
    }
    private var _goingUp:Bool = true
    @IBAction func tapImgAction(sender: UITapGestureRecognizer) {
        if(sender.view is HopplaImage){
            var val = (sender.view as HopplaImage).value
            if (val == 20) {
                _goingUp = false;
            }else if (val == 0){
                _goingUp = true
            }
            val = _goingUp ? (val + 1) : (val - 1)
            (sender.view as HopplaImage).setValue(val, withAnimation: true)
        }
    }
    @IBAction func switchAction(sender: UISwitch) {
        if( sender.on){
            hopplaImg.showLabel(animate: true)
            hopplaImgSmall.showLabel(animate: true)
            manView.hv.showLabel(animate: true)
        }else{
            hopplaImg.hideLabel(animate: true)
            hopplaImgSmall.hideLabel(animate: true)
            manView.hv.hideLabel(animate: true)
        }
    }

}

class ManualView: UIView{
    let hv = HopplaImage()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }
    func doInit(){
        hv.imageName = "star.png"
        hv.value = 3
        hv.labelHidden = false
        addSubview(hv)
        //gr
        hv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tap:"))
    }
    func tap(gr: UITapGestureRecognizer){
        hv.setValue(hv.value+1, withAnimation: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hv.transform = CGAffineTransformIdentity
        hv.frame = bounds
        var t = CGAffineTransformTranslate(CGAffineTransformIdentity, -10, -10)
        t = CGAffineTransformScale(t, 1.1, 1.1)
        hv.transform = t
    }
    
}

