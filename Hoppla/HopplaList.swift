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

class HopplaList: UIView, DetailButtonDelegate {
    ///holds items in list
    var _els = [HopplaItem]()
    
    var itemPadding:CGFloat = 15
    
    var delegate: HopplaListDelegate?
    
    ///Hoppla Item is wraper for particulat items in list
    class HopplaItem: UIView {
        var id:String?
        var topConstr: NSLayoutConstraint?
        var bottomConstr: NSLayoutConstraint?
        var inner = UIView()
        var innerSett: UIView?
        var _innerConst = [NSLayoutConstraint]()
        var _innerSettConst = [NSLayoutConstraint]()
        
        private var bttDelegate: DetailButtonDelegate?
        
        lazy var closeDetailBtt:HopplaButton = self.initCloseDetailBtt()
        lazy var closeSettBtt:HopplaButton = self.initCloseSettBtt()
        lazy var openSettBtt:HopplaButton = self.initOpenSettBtt()
        
        func pauseInnerConstrain(){
            removeConstraints(_innerConst)
            inner.setTranslatesAutoresizingMaskIntoConstraints(true)
            removeConstraints(_innerSettConst)
            innerSett?.setTranslatesAutoresizingMaskIntoConstraints(true)
        }
        func resumeInnerConstrain(){
            inner.setTranslatesAutoresizingMaskIntoConstraints(false)
            addConstraints(_innerConst)
            innerSett?.setTranslatesAutoresizingMaskIntoConstraints(false)
            addConstraints(_innerSettConst)
        }
        weak var item:UIView?{
            didSet{
                if(inner.superview == nil){
                    
                    //init inner
                    addSubview(inner)
                    var binding = ["inner":inner]
                    inner.setTranslatesAutoresizingMaskIntoConstraints(false)
                    var c = NSLayoutConstraint.constraintsWithVisualFormat("H:|[inner]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                    var c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[inner]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                    for i in c{ _innerConst.append(i as NSLayoutConstraint) }
                    for i in c2{ _innerConst.append(i as NSLayoutConstraint) }
                    addConstraints(_innerConst)
                    
                    layer.backgroundColor = UIColor.whiteColor().CGColor
                    layer.shadowColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1).CGColor
                    layer.shadowOffset = CGSize(width: 0, height: 2)
                    layer.shadowOpacity = 1
                    layer.shadowRadius = 5
                    
                }
                if(item != oldValue){
                    if(oldValue != nil){
                        oldValue!.removeFromSuperview()
                    }
                    if(item != nil){
                        inner.addSubview(item!)
                        var binding = ["item": item!]
                        item!.setTranslatesAutoresizingMaskIntoConstraints(false)
                        var c = NSLayoutConstraint.constraintsWithVisualFormat("H:|[item]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                        var c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[item]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                        for i in c2{ c.append(i) }
                        addConstraints(c)
                    }
                }
            }
        }
        
        weak var itemSett:UIView?{
            didSet{
                if(innerSett == nil){
                    //init inner
                    innerSett = UIView()
                    addSubview(innerSett!)
                    var binding = ["inner":innerSett!]
                    innerSett!.setTranslatesAutoresizingMaskIntoConstraints(false)
                    var c = NSLayoutConstraint.constraintsWithVisualFormat("H:|[inner]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                    var c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[inner]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                    for i in c{ _innerSettConst.append(i as NSLayoutConstraint) }
                    for i in c2{ _innerSettConst.append(i as NSLayoutConstraint) }
                    addConstraints(_innerSettConst)
                    innerSett?.hidden = true
                    
                    //TODO this is duplicate
                    layer.backgroundColor = UIColor.whiteColor().CGColor
                    layer.shadowColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1).CGColor
                    layer.shadowOffset = CGSize(width: 0, height: 2)
                    layer.shadowOpacity = 1
                    layer.shadowRadius = 5
                    
                }
                if(itemSett != oldValue){
                    oldValue?.removeFromSuperview()
                    if(itemSett != nil){
                        innerSett!.addSubview(itemSett!)
                        var binding = ["item": itemSett!]
                        itemSett!.setTranslatesAutoresizingMaskIntoConstraints(false)
                        var c = NSLayoutConstraint.constraintsWithVisualFormat("H:|[item]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                        var c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[item]|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
                        for i in c2{ c.append(i) }
                        addConstraints(c)
                    }
                }
            }
        }
        
        func initCloseDetailBtt() -> HopplaButton{
            var btt = HopplaButton(frame: CGRectNull)
            btt.setAwesomeTitle("\u{f060}")
            inner.addSubview(btt)
            var binding = ["btt":btt]
            btt.setTranslatesAutoresizingMaskIntoConstraints(false)
            var c = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[btt(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
            var c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[btt(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
            for i in c2{ c.append(i as NSLayoutConstraint) }
            inner.addConstraints(c)
            btt.addTarget(self, action: "bttCloseDetailAction:", forControlEvents: UIControlEvents.TouchUpInside)
            return btt
        }
        func bttCloseDetailAction(btt:AnyObject){
            bttDelegate?.closeDetail()
        }
        func initOpenSettBtt() -> HopplaButton{
            var btt = HopplaButton(frame: CGRectNull)
            btt.setAwesomeTitle("\u{f013}")
            inner.addSubview(btt)
            var binding = ["btt":btt]
            btt.setTranslatesAutoresizingMaskIntoConstraints(false)
            var c = NSLayoutConstraint.constraintsWithVisualFormat("H:[btt(40)]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
            var c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[btt(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
            for i in c2{ c.append(i as NSLayoutConstraint) }
            inner.addConstraints(c)
            btt.addTarget(self, action: "bttOpenSettAction:", forControlEvents: UIControlEvents.TouchUpInside)
            return btt
        }
        func bttOpenSettAction(btt:AnyObject){
            bttDelegate?.openSett()
        }
        func initCloseSettBtt() -> HopplaButton{
            var btt = HopplaButton(frame: CGRectNull)
            btt.setAwesomeTitle("\u{f00c}")
            innerSett?.addSubview(btt)
            var binding = ["btt":btt]
            btt.setTranslatesAutoresizingMaskIntoConstraints(false)
            var c = NSLayoutConstraint.constraintsWithVisualFormat("H:[btt(40)]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
            var c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[btt(40)]", options: NSLayoutFormatOptions(0), metrics: nil, views: binding)
            for i in c2{ c.append(i as NSLayoutConstraint) }
            innerSett?.addConstraints(c)
            btt.addTarget(self, action: "bttCloseSettAction:", forControlEvents: UIControlEvents.TouchUpInside)
            return btt
        }
        func bttCloseSettAction(btt:AnyObject){
            innerSett?.endEditing(true)
            bttDelegate?.closeSett()
        }
        
        
        private var _heightConstr:NSLayoutConstraint?
        var height: CGFloat?{
            didSet{
                if(oldValue != height){
                    if(height != nil){
                        if(_heightConstr != nil){
                            _heightConstr!.constant = height!
                        }else{
                            _heightConstr = NSLayoutConstraint(item: inner, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 0, constant: height!)
                            addConstraint(_heightConstr!)
                        }
                    }else{
                        if(_heightConstr != nil){
                            removeConstraint(_heightConstr!)
                            _heightConstr = nil
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - detail
    class DetailView: UIView {
        var hi = HopplaItem()
        var itemPadding:CGFloat = 15
        
        override init() {
            super.init()
        }
        required init(coder aDecoder: NSCoder) {
            super.init(coder:aDecoder)
            doInit()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            doInit()
        }
        func doInit(){
            addSubview(hi)
            hi.layer.shadowRadius = 0
            
            layer.shadowColor = UIColor(red: 0.26, green: 0.26, blue: 0.26, alpha: 1).CGColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = 1
            layer.shadowRadius = 8
            
            hi.clipsToBounds = true
            
            hidden = true
        }
        private var _lastBounds = CGRectNull
        override func layoutSubviews() {
            super.layoutSubviews()
            if(bounds != _lastBounds){
                _lastBounds = bounds
                hi.frame = hiFrame(bounds) //TODO now we suppose that bounds are finish frame
            }
        }
        
        func hiFrame(detFrame:CGRect) -> CGRect {
            var targetFrame = detFrame
            targetFrame.origin.x = itemPadding
            targetFrame.origin.y = itemPadding
            targetFrame.size.width -= 2*itemPadding
            targetFrame.size.height -= 2*itemPadding
            return targetFrame
        }
        func open(startFrame:CGRect, finishFrame:CGRect, animate:Bool=true, completion: ((Bool) -> Void)? = nil){
            frame = startFrame
            hi.frame = hiFrame(startFrame)
            hidden = false
            var finishHiFrame = hiFrame(finishFrame)
            
            hi.closeDetailBtt.alpha = 0
            bringSubviewToFront(hi.closeDetailBtt)
            if(hi.itemSett != nil){
                hi.openSettBtt.hidden = false
                hi.openSettBtt.alpha = 0
                bringSubviewToFront(hi.openSettBtt)
            }else{
                hi.openSettBtt.hidden = true
            }
            
            
            UIView.animateWithDuration(animate ? 0.3 : 0, animations: { () -> Void in
                self.frame = finishFrame
                self.hi.frame = finishHiFrame
                self.hi.closeDetailBtt.alpha = 1
                self.hi.openSettBtt.alpha = 1
                }, completion: completion)
        }
        func close(finishFrame:CGRect, animate:Bool=true ,  completion: ((Bool) -> Void)? = nil){
            hi.pauseInnerConstrain()
            var finishHiFrame = hiFrame(finishFrame)
            self.hi.closeDetailBtt.alpha = 1
            self.hi.openSettBtt.alpha = 1
            UIView.animateWithDuration(animate ? 0.3 : 0, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.frame = finishFrame
                self.hi.frame = finishHiFrame
                self.hi.closeDetailBtt.alpha = 0
                self.hi.openSettBtt.alpha = 0
                }, completion: { (f) -> Void in
                    self.hi.resumeInnerConstrain()
                    self.hidden = true
                    completion?(f)
            })
            
        }
        var isSettingsOpen:Bool = false
        func openSett(){
            if(hi.innerSett != nil){
                isSettingsOpen = true
                bringSubviewToFront(hi.closeSettBtt)
                
                UIView.transitionFromView(hi.inner, toView: hi.innerSett!, duration: 0.6, options: .TransitionFlipFromRight | .ShowHideTransitionViews, completion: nil)
            }
        }
        func closeSett(){
            if(self.hi.innerSett != nil){
                self.isSettingsOpen = false
                UIView.transitionFromView(self.hi.innerSett!, toView: self.hi.inner, duration: 0.6, options: .TransitionFlipFromLeft | .ShowHideTransitionViews, completion: nil)
            }
        }
        
    }
    
    private var _detail:DetailView?
    ///detail view (lazy loading)
    var detail:DetailView{
        get{
            if(_detail == nil){
                _detail = DetailView()
                addSubview(_detail!)
                clipsToBounds = true
                _detail!.hi.bttDelegate = self
            }
            return _detail!
        }
    }
    func clearDetail(){
        _detail?.removeFromSuperview()
        _detail = nil
    }
    
    func _idToIdx(id:String) -> Int{
        for (idx, el) in enumerate(_els){
            if( el.id == id){
                return idx
            }
        }
        return -1
    }
    
    private var _sv:UIScrollView?
    ///main scroll view (lazy loading)
    var sv:UIScrollView{
        get{
            if(_sv == nil){
                _sv = UIScrollView()
                addSubview(_sv!)
                _layoutSv()
            }
            return _sv!
        }
    }
    
    /// item provider, creates particulat items in list
    var itemProvider: HopplaListItemProvider?{
        didSet{
            while(_els.count>0){
                _els.removeLast().removeFromSuperview()
                //TODO remove also item from hopplaitem?
            }
            if let ip = itemProvider{
                var count = ip.hopplaListGetNumberOfItems(self)
                while(_els.count < count){
                    let idx = _els.count
                    let el = ip.hopplaListGetItem(self, idx: idx)
                    let h = ip.hopplaListHeightForItem(self, idx: idx)
                    let id = ip.hopplaListIdForItem(self, idx: idx)
                    let hEl = HopplaItem()
                    hEl.item = el
                    hEl.height = h
                    hEl.id = id
                    
                    var gr = UITapGestureRecognizer(target: self, action: "handleItemTap:")
                    hEl.addGestureRecognizer(gr)
                    
                    sv.addSubview(hEl)
                    _els.append(hEl)
                    _layoutItem(hEl, idx: idx, isLast: _els.count == count)
                    
                }
            }
        }
    }
    
    func handleItemTap(gr: UITapGestureRecognizer){
        if( gr.view != nil && gr.view is HopplaItem){
            if var idx = find(_els, (gr.view as HopplaItem)){
                openDetail(idx)
            }
        }
    }
    func refreshList() {
        var ip = itemProvider
        itemProvider = nil
        itemProvider = ip
    }
    func refreshDetail(){
        if(isDetailOpen){
            if let id = detail.hi.id{
                clearDetail()
                openDetail(_idToIdx(id), animate: false)
            }else{
                clearDetail()
            }
        }else{
            clearDetail()
        }
        
    }
    //////////////////////////////////////////////////////////////////
    //MARK: - layouts
    var c = 1
    private var _lastBounds = CGRectNull
    override func layoutSubviews() {
        super.layoutSubviews()
        if(bounds != _lastBounds){
            _lastBounds = bounds
            _detail?.frame = bounds
        }
    }
    
    /// layout Hoppla Items
    private func _layoutItem(el: HopplaItem, idx:Int, isLast:Bool = false){
        el.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if(idx == 0){
            el.topConstr = NSLayoutConstraint(item: el, attribute: .Top, relatedBy: .Equal, toItem: sv, attribute: .Top, multiplier: 1, constant: itemPadding)
        }else{
            el.topConstr = NSLayoutConstraint(item: el, attribute: .Top, relatedBy: .Equal, toItem: _els[idx-1], attribute: .Bottom, multiplier: 1, constant: itemPadding)
        }
        
        if(isLast){
            el.bottomConstr = NSLayoutConstraint(item: el, attribute: .Bottom, relatedBy: .Equal, toItem: sv, attribute: .Bottom, multiplier: 1, constant: -itemPadding)
            sv.addConstraint(el.bottomConstr!)
        }
        
        let cr = NSLayoutConstraint(item: el, attribute: .CenterX, relatedBy: .Equal, toItem: sv, attribute: .CenterX, multiplier: 1, constant: 0)
        let cl = NSLayoutConstraint(item: el, attribute: .Width, relatedBy: .Equal, toItem: sv, attribute: .Width, multiplier: 1, constant: -2*itemPadding)
        
        sv.addConstraints([el.topConstr!,cr, cl])
        
    }
    private func _layoutSv(){
        _sv!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let cl = NSLayoutConstraint(item: _sv!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let cr = NSLayoutConstraint(item: _sv!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let ct = NSLayoutConstraint(item: _sv!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let cb = NSLayoutConstraint(item: _sv!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        addConstraints([cl, cr, ct, cb])
    }
    
    //MARK: - open / close features
    
    func getFrameOfItemInViewSystem(idx: Int) -> CGRect{
        var el = _els[idx]
        var frame = el.frame
        frame.origin.y -= sv.contentOffset.y
        //NOTE: adjusting only y while scrollview fill self
        return frame
    }
    func getFrameOfItemInViewSystemForDetail(idx: Int) -> CGRect{
        var frame = getFrameOfItemInViewSystem(idx)
        //remove padding because detail is outer View
        frame.origin.x -= itemPadding
        frame.origin.y -= itemPadding
        frame.size.width += 2*itemPadding
        frame.size.height += 2*itemPadding
        
        return frame
    }
    var isDetailOpen:Bool{
        get{
            return _detail != nil && !detail.hidden
        }
    }
    //OPEN detail
    func openDetail(idx:Int, animate:Bool=true){
        var el = _els[idx]
        detail.hi.item = itemProvider?.hopplaListGetDetailItem(self, idx: idx)
        detail.hi.itemSett = itemProvider?.hopplaListGetSettingsItem(self, idx: idx)
        detail.hi.id = itemProvider?.hopplaListIdForItem(self, idx: idx)
        
        self.bringSubviewToFront(self.detail)
        self.delegate?.hopplaListAboutToOpenDetail?(self, idx: idx)
        detail.open(getFrameOfItemInViewSystemForDetail(idx), finishFrame: bounds, animate:animate) { (f) -> Void in
            self.delegate?.hopplaListDidOpenDetail?(self, idx: idx)
            el.hidden = true //TODO wtf? why compiler error?
        }
        el.hidden = true
    }
    
    //MARK: - DetailButtonDelegate
    //CLOSE detail
    func closeDetail(){
        if(detail.hi.id != nil){
            var idx = _idToIdx(detail.hi.id!)
            var el = _els[idx]
            self.delegate?.hopplaListAboutToCloseDetail?(self, idx: idx)
            detail.close(getFrameOfItemInViewSystemForDetail(idx), completion: { (f) -> Void in
                self.delegate?.hopplaListDidCloseDetail?(self, idx: idx)
                el.hidden = false
            })
        }
    }
    private func closeSett() {
        detail.closeSett()
    }
    private func openSett() {
        detail.openSett()
    }
}


//MARK: Protocols
private protocol DetailButtonDelegate{
    func closeSett() -> Void
    func openSett() -> Void
    func closeDetail() -> Void
}

protocol HopplaListItemProvider{
    func hopplaListGetItem(hl: HopplaList, idx: Int) -> UIView
    func hopplaListGetDetailItem(hl: HopplaList, idx: Int) -> UIView
    func hopplaListGetSettingsItem(hl: HopplaList, idx: Int) -> UIView?
    func hopplaListHeightForItem(hl: HopplaList, idx: Int) -> CGFloat?
    func hopplaListIdForItem(hl: HopplaList, idx: Int) -> String
    func hopplaListGetNumberOfItems(hl: HopplaList) -> Int
}
@objc protocol HopplaListDelegate{
    optional func hopplaListAboutToOpenDetail(hl: HopplaList, idx: Int)
    optional func hopplaListDidOpenDetail(hl: HopplaList, idx: Int)
    optional func hopplaListAboutToCloseDetail(hl: HopplaList, idx: Int)
    optional func hopplaListDidCloseDetail(hl: HopplaList, idx: Int)
}