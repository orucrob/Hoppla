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


class HopplaBoard: UIView{
    enum Mode{
        case NORMAL, DETAIL
    }
    var _rightPadding = 10
    var _els:[[HopplaImage]] = [[HopplaImage]]()
    
    @IBInspectable var animationDuration = 0.3
    
    var itemProvider: HopplaBoardItemProvider?{
        didSet{
            //reload
            //clean
            while(_els.count != 0){
                _removeLastLevel()
            }
            //add
            if(itemProvider != nil){
                while(_els.count != _levels){
                    _addLastLevel()
                }
            }
            
        }
    }
    private var _levels = 0
    @IBInspectable var levels: Int{
        get{
            return _levels
        }
        set(v){
            if(itemProvider != nil && _els.count != v){
                while(_els.count != v){
                    if (_els.count > v){
                        //level remove
                        _removeLastLevel()
                    }else if (_els.count < v){
                        //level add
                        _addLastLevel()
                    }
                }
            }
            _levels = v
        }
    }
    private var _indexesInLevel = 0
    @IBInspectable var indexesInLevel:Int{
        get{
            return _indexesInLevel
        }
        set(v){
            let oldVal = _indexesInLevel
            if( itemProvider != nil && levels > 0 && oldVal != v){
                for(var idx = 0; idx < levels; ++idx){
                    if( v < oldVal){
                        //removing
                        while(_els[idx].count != v){
                            _els[idx].removeLast().removeFromSuperview()
                        }
                    }else if (v > oldVal){
                        //adding
                        while(_els[idx].count != v){
                            var el = itemProvider!.hopplaBoardGetItem(self, levelIdx: idx, idxInLevel: _els[idx].count)
                            addSubview(el)
                            el.frame.size = itemProvider!.hopplaBoardGetSize(self, levelIdx: idx, idxInLevel: _els[idx].count)
                            _els[idx].append(el)
                        }
                    }
                    
                }
            }
            _indexesInLevel = v
            
        }
    }
    
    private var _mode:Mode = .NORMAL
    var mode:Mode {
        get{
            return _mode
        }
        set(v){
            setMode(v, animate:false)
        }
    }
    func setMode(mode:Mode, animate:Bool=true){
        if (mode == .DETAIL){
            _transformAllLevelsToDetail(animate: animate)
        }else if (mode == .NORMAL){
            _transformAllLevelsToNormal(animate: animate)
        }
        _mode = mode
    }
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: _cW, height: _cH)
    }
    
    private var _cH:CGFloat = UIViewNoIntrinsicMetric
    private var _cW:CGFloat = UIViewNoIntrinsicMetric
    private var _h:CGFloat = 0, _w:CGFloat = 0
    override func layoutSubviews() {
        if(_h != bounds.height || _w != bounds.width){
            super.layoutSubviews()
            _h = bounds.height; _w = bounds.width
            
            let margin = CGFloat(10)
            let b = bounds
            _cH = 0
            _cW = 0
            for(var level = 0 ; level < levels; ++level){
                var cH:CGFloat = 0
                var cW:CGFloat = 0
                for (idx, el) in enumerate(_els[level]){
                    el.transform = CGAffineTransformIdentity
                    if(level == 0){
                        el.frame.origin.y = margin
                    }else{
                        el.frame.origin.y = _els[level-1][0].frame.origin.y + _els[level-1][0].frame.height + margin
                    }
                    if(idx == 0){
                        el.frame.origin.x = b.width - el.bounds.width - margin
                    }else{
                        el.frame.origin.x = _els[level][idx-1].frame.origin.x - el.bounds.width - margin
                    }
                    cH = max(cH, el.bounds.height+margin)
                    cW += el.bounds.width + margin
                }
                _cH += cH
                _cW = max(_cW, cW)
            }
            invalidateIntrinsicContentSize()
            
            if(mode == .DETAIL){
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self._transformAllLevelsToDetail(animate: false)
                })
            }
        }
        
    }
    
    private func _transformAllLevelsToDetail(animate:Bool = false){
        var l = levels
        while ( l-- > 0){
            _transformLevelToDetal(l, animate: animate)
        }
    }
    private func _transformAllLevelsToNormal(animate:Bool = false){
        var l = levels
        while ( l-- > 0){
            _transformLevelToNormal(l, animate: animate)
        }
    }
    private var _lastTransformH:CGFloat = 0.0
    private var _lastTransformW:CGFloat = 0.0
    private func _transformLevelToDetal(level:Int, animate:Bool = false){
        if(level == 0){
            for (idx, el) in enumerate(_els[level]){
                el.transform = CGAffineTransformIdentity //just be sure to start from normal position
                var move = getTargetTransformPosition(idx)
                var t = CGAffineTransformTranslate(CGAffineTransformIdentity, move.x, move.y)
                t = CGAffineTransformScale(t, 1.5, 1.5)
                if(animate){
                    UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                        el.transform = t
                    })
                }else{
                    el.transform = t
                }
            }
        }else{
            for (idx, el) in enumerate(_els[level]){
                var t = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5)
                if(animate){
                    UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                        el.transform = t
                        el.alpha = 0
                    })
                }else{
                    el.transform = t
                    el.alpha = 0
                }
            }
        }
    }
    private func _transformLevelToNormal(level:Int, animate:Bool = false){
        for (idx, el) in enumerate(_els[level]){
            var t = CGAffineTransformIdentity
            if(animate){
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    el.transform = t
                    el.alpha = 1
                })
            }else{
                el.transform = t
                el.alpha = 1
                
            }
        }
    }
    
    private func getTargetTransformPosition(idx:Int) -> CGPoint{
        if(levels>0 && indexesInLevel>0){
            var el = _els[0][idx]
            var elW = el.bounds.width
            var elH = el.bounds.height
            _lastTransformH = bounds.height
            _lastTransformW = bounds.width
            //absolute
            var tW = _lastTransformW/CGFloat(indexesInLevel)*(CGFloat(indexesInLevel-idx-1) + 0.5)-elW/2
            var tH = _lastTransformH - (elH*1.5)
            
            //relative
            return CGPoint(x: tW - el.frame.origin.x, y: tH - el.frame.origin.y)
        }else{
            return CGPointZero
        }
        
        
    }
    
    
    //remove last level from _els
    private func _removeLastLevel(){
        var level = _els.removeLast()
        while(level.count == 0){
            level.removeLast().removeFromSuperview()
        }
    }
    
    //add level to the end of levels
    private func _addLastLevel() -> [HopplaImage]{
        var levelEl = [HopplaImage]()
        _els.append(levelEl)
        for(var idx2=0; idx2<indexesInLevel; ++idx2){
            var el = _addEl(_els.count-1, idxInLevel: idx2)
            levelEl = _els.removeLast() //TODO toto je uchylne...
            levelEl.append(el)
            _els.append(levelEl)
        }
        return levelEl
    }
    
    //create (get) element, add to as subview and laout it
    private func _addEl(levelIdx: Int, idxInLevel: Int) -> HopplaImage{
        var el = itemProvider!.hopplaBoardGetItem(self, levelIdx: levelIdx, idxInLevel: idxInLevel)
        addSubview(el)
        el.frame.size = itemProvider!.hopplaBoardGetSize(self, levelIdx: levelIdx, idxInLevel: idxInLevel)
        return el
    }
    
}

protocol HopplaBoardItemProvider{
    func hopplaBoardGetItem(hb:HopplaBoard, levelIdx:Int, idxInLevel:Int) -> HopplaImage
    func hopplaBoardGetSize(hb:HopplaBoard, levelIdx:Int, idxInLevel:Int) -> CGSize
}
