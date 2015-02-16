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

class HopplaDoubleView: UIView, HopplaDelegate {
    private var _firstHV:HopplaView?
    private var _secondHV:HopplaView?
    
    var hopplaProvider:HopplaDoubleViewProvider?{
        didSet{
            reinitialize()
        }
    }
    private var _gap:CGFloat = 0 {
        didSet{
            if(_gap != oldValue){
                if let gc = _gapConstr{
                    gc.constant = _gap
                }
            }
        }
    }
    
    var onlySingle:Bool = false{
        didSet{
            reinitialize()
        }
    }
    
    private func reinitialize(){
        _firstHV?.removeFromSuperview()
        _secondHV?.removeFromSuperview()
        if let hp = hopplaProvider{
            _firstHV = hp.hopplaDoubleViewGetFirst(self)
            _firstHV!.delegate = self
            addSubview(_firstHV!)
            if(onlySingle){
                _secondHV = nil
            }else{
                _secondHV = hp.hopplaDoubleViewGetSecond(self)
                _secondHV!.delegate = self
                _secondHV!.collapse(animate: false)
                addSubview(_secondHV!)
                sendSubviewToBack(_secondHV!)
            }
            _layout()
        }
    }
    
    func hopplaViewOpenDidStart(hp: HopplaView) {
        if(hp == _firstHV){
            _secondHV?.collapse()
        }else{
            _firstHV?.collapse()
        }
        bringSubviewToFront(hp)
    }
    
    //MARK: - layout
    var _gapConstr:NSLayoutConstraint?
    private func _layout(){
        var allC = [AnyObject]()
        _firstHV!.setTranslatesAutoresizingMaskIntoConstraints(false)

        allC.append(NSLayoutConstraint(item: _firstHV!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
        allC.append(NSLayoutConstraint(item: _firstHV!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        allC.append(NSLayoutConstraint(item: _firstHV!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
        
        if(onlySingle){
            allC.append(NSLayoutConstraint(item: _firstHV!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
            _gapConstr = nil
        }else{
            _secondHV!.setTranslatesAutoresizingMaskIntoConstraints(false)
            allC.append(NSLayoutConstraint(item: _secondHV!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
            allC.append(NSLayoutConstraint(item: _secondHV!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
            allC.append(NSLayoutConstraint(item: _secondHV!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
            _gapConstr = NSLayoutConstraint(item: _secondHV!, attribute: .Bottom, relatedBy: .Equal, toItem: _firstHV, attribute: .Bottom, multiplier: 1, constant: 0)
            allC.append(_gapConstr!)
        }
        addConstraints(allC)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //update gap
        if let sh = _secondHV{
            _gap = sh.labCountWrap.bounds.height
        }
    }

}
//MARK: - Provider of first and second hoppla view
protocol HopplaDoubleViewProvider{
    func hopplaDoubleViewGetFirst(hdv:HopplaDoubleView) -> HopplaView
    func hopplaDoubleViewGetSecond(hdv:HopplaDoubleView) -> HopplaView
}

//MARK: - BasicStarProvider
///Basic implamentation of HopplaItemProvider as a star selector
class BasicHopplaDoubleViewProvider:NSObject, HopplaDoubleViewProvider {
    func hopplaDoubleViewGetFirst(hdv:HopplaDoubleView) -> HopplaView{
        var hv = HopplaView(rows: 4, count: 10, keyItem: 0)
        hv.itemProvider = BasicStarProvider()
        //hv.backgroundColor = UIColor.redColor()
        return hv
    }
    func hopplaDoubleViewGetSecond(hdv:HopplaDoubleView) -> HopplaView{
        var hv = HopplaView(rows: 3, count: 10, keyItem: 8)
        hv.itemProvider = BasicStarProvider()
        //hv.backgroundColor = UIColor.orangeColor()
        return hv
    }
}
