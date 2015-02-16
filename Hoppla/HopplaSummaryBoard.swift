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

class HopplaSummaryBoard: UIView {
    enum Mode{
        case NORMAL, DETAIL
    }
    
    
    var titleLabel : UILabel?{
        didSet{
            oldValue?.removeFromSuperview()
            if let t = titleLabel{
                addSubview(t)
                bringSubviewToFront(t)
                layoutTitle(skipSizing: false, forMode: mode)
            }
        }
        
    }
    
    /// duration for animation between modes
    @IBInspectable var animationDuration = 0.3
    
    ///board
    var board: HopplaBoard?{
        didSet{
            oldValue?.removeFromSuperview()
            if let b = board{
                addSubview(b)
                b.frame = bounds
                bringSubviewToFront(b)
            }
        }
    }
    
    ///title
    var title:String?{
        get{
            return titleLabel?.text
        }
        set(v){
            if(v == nil){
                titleLabel?.text = nil
            }else{
                if( titleLabel == nil){
                    titleLabel = UILabel()
                }
                titleLabel?.text = v
                layoutTitle(skipSizing: false, forMode: mode)
            }
        }
    }
    ///background view
    var backgroundView:UIView?{
        didSet{
            oldValue?.removeFromSuperview()
            if let b = backgroundView{
                addSubview(b)
                sendSubviewToBack(b)
                b.frame = bounds
            }
        }
    }
    ///display mode
    private var _mode:Mode = .NORMAL
    var mode:Mode {
        get{
            return _mode
        }
        set(v){
            setMode(v, animate:false)
        }
    }
    ///set mode with animate option
    func setMode(mode:Mode, animate:Bool=true){
        if (mode == .DETAIL){
            _transformToDetail(animate)
        }else if (mode == .NORMAL){
            _transformToNormal(animate)
        }
        _mode = mode
    }

//    ///MARK: - copy properties from board
//    private var _levels = 0
//    @IBInspectable var boardLevels: Int{
//        get{
//            return _levels
//        }
//        set(v){
//            _levels = v
//            _board?.levels = _levels
//        }
//    }
//    private var _indexesInLevel = 0
//    @IBInspectable var boardIndexesInLevel:Int{
//        get{
//            return _indexesInLevel
//        }
//        set(v){
//            _indexesInLevel = v
//            _board?.indexesInLevel = _indexesInLevel
//        }
//    }
//    
    
    ///MARK: - layout
    private var _h:CGFloat = 0, _w:CGFloat = 0
    override func layoutSubviews() {
        if(_h != bounds.height || _w != bounds.width){
            _h = bounds.height; _w = bounds.width
            board?.frame = bounds
            layoutTitle(skipSizing: false, forMode: mode)
            backgroundView?.frame = bounds
            
            if(mode == .DETAIL){
                _transformToDetail(false)//TODO double layout title
            }
            super.layoutSubviews()
        }
        
    }
    
    private func layoutTitle(skipSizing: Bool = false, forMode: Mode){
        if let t = titleLabel{
            if( !skipSizing){
                t.sizeToFit()
                if (t.bounds.size.width > bounds.width){
                    t.adjustsFontSizeToFitWidth = true
                    t.bounds.size.width = bounds.width
                }
            }
            if(forMode == .NORMAL){
                t.frame.origin = CGPoint(x: 8 , y: bounds.height/2 - t.bounds.height/2)
            }else{
                t.frame.origin = CGPoint(x: bounds.width/2 - t.bounds.width/2, y: 8)
            }
        }
    }
    
    ///MARK: - transformation between modes
    private func _transformToDetail(animate:Bool){
        board?.setMode(HopplaBoard.Mode.DETAIL, animate: animate)
        if(animate){
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    if let bv = self.backgroundView{
                        bv.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height/2)
                    }
                    self.layoutTitle(skipSizing: true, forMode: .DETAIL)
                })
        }else{
            if let bv = self.backgroundView{
                bv.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height/2)
            }
            layoutTitle(skipSizing: true, forMode: .DETAIL)
        }
    }
    private func _transformToNormal(animate:Bool){
        board?.setMode(HopplaBoard.Mode.NORMAL, animate: animate)
        if(animate){
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    if let bv = self.backgroundView{
                        bv.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
                    }
                    self.layoutTitle(skipSizing: true, forMode: .NORMAL)
                })
        }else{
            if let bv = self.backgroundView{
                bv.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            }
            layoutTitle(skipSizing: true, forMode: .NORMAL)
        }
    }
    

}