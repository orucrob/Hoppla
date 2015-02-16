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

class HopplaView: UIView {
    
    let labCount = UILabel()
    let labCountWrap = UIView()
    var collapsedItem:UIView?
    
    //animation duration
    var duration = 0.3
    
    //provider for items
    var itemProvider: HopplaItemProvider?{
        didSet{
            reinitialize()
        }
    }
    //hide or show label
    @IBInspectable var labelHidden:Bool = false{
        didSet{
            labCount.hidden = labelHidden
        }
    }
    
    //delegate for hoppla view
    var delegate: HopplaDelegate?
    
    //value - how many stars are filled
    var value:Int{
        get{
            var val = 0;
            if let ip = itemProvider{
                for (idx,el) in enumerate(els){
                    val += ip.valueForItem(el, index: idx)
                }
            }
            return val
        }
        set{
            if let ip = itemProvider{
                var v = newValue
                if(v>count){
                    v = count
                }
                for (idx,el) in enumerate(els){
                    ip.setValueForItem(el, index: idx, value: (idx<v) ? 1: 0)
                }
                if(!isOpen){
                    labCount.text = "\(v)"
                }
            }
        }
    }
    
    //total amount of stars
    @IBInspectable var count:Int = 10 {
        didSet{
            reinitialize()
        }
    }
    
    //number of rows for items to be displayd in (0 (default) means, that calculate according to height and width to best fit)
    @IBInspectable var rows:Int = 0 {
        didSet{
            reinitialize()
        }
    }
    
    //recreate all elements and layouts
    private func reinitialize(){
        //remove
        labCount.removeFromSuperview();
        collapsedItem?.removeFromSuperview()
        while(subviews.count>0){
            self.subviews.last?.removeFromSuperview()
        }
        els.removeAll(keepCapacity: false)
        
        //add
        if let ip = itemProvider{
            for var index = 0; index < count; ++index {
                let el = ip.createItem(index);
                els.append(el)
                addSubview(el)
            }
            collapsedItem = ip.createCollapsedItem()
            labCountWrap.addSubview(labCount)
            labCountWrap.addSubview(collapsedItem!)
            addSubview(labCountWrap)
            bringSubviewToFront(els[keyItem])
        }
    }
    
    //which item is static (and it's not moved)
    var keyItem:Int = 0{
        didSet{
            reinitialize()
        }
    }
    
    //how many iteme has been hidden during hiding
    private var finishedValue:Int = 0{
        didSet{
            labCount.text = "\(finishedValue)"
        }
    }
    
    //holds all stars elements in order
    private var els = [UIView]()
    
    //is stars board open or closed?
    private var isOpen = true
    
    //handle tap on key elelement
    func doOpenCloseTap(gr: AnyObject){
        if(isOpen){
            collapse()
        }else{
            open()
        }
    }
    
    
    //MARK: - open / collapse
    ///can run collapse or open anim.
    private func _canAnim()->Bool{
        return els.count > 0 && _layDist.count > 0 && itemProvider != nil
    }
    
    ///collapse stars
    func collapse(animate:Bool = true){
        if (isOpen) {
            isOpen = false
            labCountWrap.hidden = false
            bringSubviewToFront(labCountWrap)
            
            if(_canAnim()){
                delegate?.hopplaViewCollapseDidStart?(self)
                
                UIView.animateWithDuration(animate ? duration/3 : 0, animations: { () -> Void in
                    self.labCountWrap.alpha = 1
                })
                let maxVal = value;
                var finished = els.count
                for (idx,el) in enumerate(els){
                    if(idx != keyItem){
                        let d = idx < _layDist.count ? _layDist[idx] : 0
                        let tt = d*CGFloat(duration)/_layMaxDist
                        UIView.animateWithDuration(animate ? Double(tt) : 0,  animations: { () -> Void in
                            el.transform = CGAffineTransformMakeTranslation(self._layTransfFrames[idx].x, self._layTransfFrames[idx].y)
                            //el.transform = CGAffineTransformMakeTranslation(self._keyFrame.origin.x-el.frame.origin.x, self._keyFrame.origin.y-el.frame.origin.y)
                            }, completion: { (f) -> Void in
                                self.finishedValue = min(self.finishedValue+self.itemProvider!.valueForItem(el, index: idx), maxVal) //min prevents to rise over value if more open-close-open anims occured
                                self.delegate?.hopplaViewCollapsing?(self, value: self.finishedValue)
                                if( --finished == 0){
                                    self.delegate?.hopplaViewCollapseDidFinish?(self, value: self.value)
                                }
                                el.hidden = true
                        })
                    }else{
                        self.finishedValue = min(self.finishedValue+self.itemProvider!.valueForItem(el, index: idx), maxVal) //min prevents to rise over value if more open-close-open anims occured
                        self.delegate?.hopplaViewCollapsing?(self, value: self.finishedValue)
                        if( --finished == 0){
                            self.delegate?.hopplaViewCollapseDidFinish?(self, value: self.value)
                        }
                        el.hidden = true
                    }
                }
            
            }else{//cannot animate
                self.labCountWrap.alpha = 1
            }
        }
    }
    
    ///open stars
    func open(animate:Bool = true){
        if (!isOpen) {
            isOpen = true
            bringSubviewToFront(labCountWrap)
            if(_canAnim()){
                
                var finished = els.count
                
                delegate?.hopplaViewOpenDidStart?(self)
                
                UIView.animateWithDuration(animate ? duration/3 : 0, animations: { () -> Void in
                    self.labCountWrap.alpha = 0;
                    }, completion:{ (finished) -> Void in
                        self.labCountWrap.hidden = true
                })
                for (idx,el) in enumerate(els){
                    if(idx != keyItem){
                        let d = idx < _layDist.count ? _layDist[idx] : 0
                        let tt = d*CGFloat(duration)/_layMaxDist //maxDis
                        el.hidden = false
                        UIView.animateWithDuration(animate ? Double(tt) : 0, animations: { () -> Void in
                            el.transform = CGAffineTransformIdentity
                            }, completion:{(f) -> Void in
                                self.finishedValue = max(self.finishedValue-self.itemProvider!.valueForItem(el, index: idx), 0)
                                self.delegate?.hopplaViewCollapsing?(self, value: self.finishedValue)
                                if( --finished == 0){
                                    self.delegate?.hopplaViewOpenDidFinish?(self, value: 0)
                                }
                        })
                    }else{
                        el.hidden = false
                        self.finishedValue = max(self.finishedValue-self.itemProvider!.valueForItem(el, index: idx), 0)
                        self.delegate?.hopplaViewCollapsing?(self, value: self.finishedValue)
                        if( --finished == 0){
                            self.delegate?.hopplaViewOpenDidFinish?(self, value: 0)
                        }
                        
                    }
                }
            }else{//cannot animate
                self.labCountWrap.alpha = 0;
                self.labCountWrap.hidden = true

            }
        }
    }
    
    //MARK: - initializations
    override init(){
        super.init()
        doInit()
    }
    init(rows:Int = 5, count:Int = 10, keyItem:Int = 0){
        super.init()
        self.rows = rows
        self.count = count
        self.keyItem = keyItem
        doInit()
    }
    init(count:Int = 10, keyItem:Int = 0){
        super.init()
        self.count = count
        self.keyItem = keyItem
        doInit()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        doInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }
    private func doInit(){
        
        labCountWrap.hidden = true
        labCountWrap.alpha = 0
        labCountWrap.userInteractionEnabled = true
        labCountWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "doOpenCloseTap:"))
        
        labCount.text = "1"
        labCount.textAlignment = NSTextAlignment.Right
        
        reinitialize();
    }

    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: _layHeight)
    }
    
    //MARK: - layout all things
    //NOTE: using contstraints was really slow compared to layouting subviews manually
    private var _layCount = 0
    private var _layRows = 0
    private var _layHeight:CGFloat = 0
    private var _layWidth:CGFloat = 0
    private var _layKeyItem = 0
    private var _layTransfFrames = [CGPoint]()
    private var _layDist = [CGFloat]()
    private var _layMaxDist:CGFloat = 0
    
    override func layoutSubviews() {
        var w = bounds.width
        var h = bounds.height
        if( w != 0 && ( h != 0 || rows>0 ) && els.count > 0 && ( w != _layWidth || h != _layHeight || _layCount != count || _layKeyItem != keyItem || _layRows != rows )){
            _layCount = count; _layWidth = w; _layHeight = h ; _layKeyItem = keyItem; _layRows = rows

            var inRow:CGFloat
            var elW:CGFloat
            var leftPadding:CGFloat
            
            if(rows > 0){
                inRow = ceil(CGFloat(count)/CGFloat(rows))
                elW = w/inRow
                leftPadding = 0
            }else{
                let ratio = h/w
                inRow = ceil(sqrt(CGFloat(count)/ratio))
                var inCol:CGFloat = ceil(CGFloat(count)/inRow)
                elW = min(w/inRow, h/inCol)
                leftPadding = w - elW*inRow
            }
            
            var x:CGFloat = 0; var y:CGFloat = 0
            for (idx, el) in enumerate(els) {
                el.transform = CGAffineTransformIdentity
                x = CGFloat(idx) % inRow
                y = (CGFloat(idx) - x) / inRow
                el.frame = CGRect(x: leftPadding + x*elW, y: y*elW, width: elW, height: elW)
                if(idx == keyItem){
                    labCountWrap.frame = el.frame
                    let b = labCountWrap.bounds
                    collapsedItem?.frame = b
                    labCount.frame = CGRect(x: b.width/2, y: b.height/2, width: b.width/2, height: b.height/2)
                }
            }
            
            
            _layTransfFrames.removeAll(keepCapacity: true)
            _layDist.removeAll(keepCapacity: true)
            var keyFrame = els[keyItem].frame
            
            for el in els{
                var frame = el.frame
                
                var t = el.transform;
                el.transform = CGAffineTransformIdentity
                el.transform = t
                //calculate distance
                var tPoint = CGPoint(x: keyFrame.origin.x-frame.origin.x, y: keyFrame.origin.y-frame.origin.y)
                _layTransfFrames.append(tPoint)
                
                let a = pow(frame.origin.x - keyFrame.origin.x, 2.0)
                let b = pow(frame.origin.y - keyFrame.origin.y, 2.0)
                let d = sqrt(a+b)
                _layDist.append(d)
                
                if(!isOpen){
                    el.transform = CGAffineTransformMakeTranslation( tPoint.x, tPoint.y )
                }
            }
            _layMaxDist = maxElement(_layDist)
            
            if(rows > 0){
                _layHeight = elW * CGFloat(rows)
            }
            invalidateIntrinsicContentSize()

        }
        super.layoutSubviews()
    }
    
    //NOTE: using contstraints was really slow compared to layouting subviews manually
    //    private func layoutEls(rowCount:Int){
    //        var bindings:[NSObject : AnyObject] = ["view": self]
    //        var allConstraints = [NSLayoutConstraint]()
    //
    //        var formats:[String] = []
    //        var formatRow = "H:|"
    //        var formatCols = [String]()
    //
    //        var widthMultiplier: CGFloat = 1.0 / CGFloat(rowCount)
    //
    //        for (idx, el) in enumerate(els) {
    //            bindings.updateValue(el, forKey: "el\(idx)")
    //            el.setTranslatesAutoresizingMaskIntoConstraints(false)
    //
    //            var x = idx % rowCount
    //            var y = (idx - x) / rowCount
    //
    //            //width (row)
    //            if idx == 0 {
    //                formatRow += "[el\(idx)]"
    //            }else{
    //                formatRow += "[el\(idx)(==el0)]"
    //            }
    //            if x == (rowCount-1)  || idx == (els.count-1){ //if last in row or last item
    //                if(x != rowCount-1 && y>0){
    //                    //create spacer
    //                    let spacer = UIView(frame: CGRectNull)
    //                    addSubview(spacer)
    //                    spacer.setTranslatesAutoresizingMaskIntoConstraints(false)
    //                    bindings.updateValue(spacer, forKey: "spacer")
    //                    formatRow += "[spacer(>=0)]|" //spacer if there is a space
    //                    //and add to collums, too
    //                    for (var i=x+1; i<rowCount; ++i){
    //                        formatCols[i]+="[spacer(>=0)]"
    //                    }
    //                }else{//no space or first row
    //                    formatRow += "|"
    //                }
    //                formats.append(formatRow)
    //                //start new row
    //                formatRow = "H:|"
    //            }
    //
    //            //height (cols)
    //            if y==0{
    //                formatCols.append("V:|[el\(idx)]")
    //            }else{
    //                formatCols[x]+="[el\(idx)]"
    //            }
    //            //make it squared
    //            allConstraints.append(NSLayoutConstraint(item: el, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    //            if(idx == keyItem){
    //                // wrapper for collapsed item and label
    //                allConstraints.append(NSLayoutConstraint(item: labCountWrap, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
    //                allConstraints.append(NSLayoutConstraint(item: labCountWrap, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
    //                allConstraints.append(NSLayoutConstraint(item: labCountWrap, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    //                allConstraints.append(NSLayoutConstraint(item: labCountWrap, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    //            }
    //        }
    //
    //
    //        //label count
    //        allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
    //        allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    //        allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    //        allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    //        //collapsed item
    //        allConstraints.append(NSLayoutConstraint(item: collapsedItem!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
    //        allConstraints.append(NSLayoutConstraint(item: collapsedItem!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
    //        allConstraints.append(NSLayoutConstraint(item: collapsedItem!, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
    //        allConstraints.append(NSLayoutConstraint(item: collapsedItem!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: labCountWrap, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    //
    //
    //        labCount.setTranslatesAutoresizingMaskIntoConstraints(false)
    //        labCountWrap.setTranslatesAutoresizingMaskIntoConstraints(false)
    //        collapsedItem!.setTranslatesAutoresizingMaskIntoConstraints(false)
    //
    //        //finish vertical formats
    //        for f in formatCols{
    //            formats.append(f+"|")
    //        }
    //
    //        //create constrains from string formats
    //        for f in formats{
    //            var c = NSLayoutConstraint.constraintsWithVisualFormat(f, options: NSLayoutFormatOptions(0), metrics: nil, views: bindings)
    //            for i in c { allConstraints.append(i as NSLayoutConstraint) }
    //        }
    //        //add to self
    //        self.addConstraints(allConstraints)
    //    }
}

//MARK: - HopplaItemProvider
///Provider for items. Encapsulate the items, that are displayd
protocol HopplaItemProvider{
    func createItem(forIndex:Int) -> UIView
    func createCollapsedItem() -> UIView
    func valueForItem(item:UIView, index:Int) -> Int
    func setValueForItem(item:UIView, index:Int, value:Int)->Void
}

//MARK: - HopplaItemProvider
@objc protocol HopplaDelegate{
    optional func hopplaViewCollapseDidStart( hp:HopplaView)
    optional func hopplaViewOpenDidStart( hp:HopplaView)
    optional func hopplaViewCollapseDidFinish( hp:HopplaView, value: Int)
    optional func hopplaViewOpenDidFinish( hp:HopplaView, value: Int)
    optional func hopplaViewCollapsing(hp:HopplaView, value: Int)
    optional func hopplaViewOpening(hp:HopplaView, value: Int)
}


//MARK: - BasicStarProvider
///Basic implamentation of HopplaItemProvider as a star selector
class BasicStarProvider:NSObject, HopplaItemProvider {
    
    func createItem(forIndex:Int) -> UIView{
        let el = UILabel()
        el.text =  "☆" //(idx<_value) ? "★":
        el.textAlignment = NSTextAlignment.Center
        el.font = el.font.fontWithSize(70)
        el.userInteractionEnabled = true
        el.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "elSelectTap:"))
        return el
    }
    func createCollapsedItem() -> UIView{
        let el = UILabel()
        el.text =  "★" //(idx<_value) ? "★":
        el.textAlignment = NSTextAlignment.Center
        el.font = el.font.fontWithSize(70)
        return el
    }
    
    //handle tap on key elelement
    func elSelectTap(gr: UITapGestureRecognizer){
        if( gr.view != nil && gr.view is UILabel){
            let el = gr.view as UILabel
            if(isSelected(el)){
                el.text = "☆"
            }else{
                el.text = "★"
            }
        }
    }
    //determine whether the element is selected (full or empty star)
    private func isSelected(el:UILabel) -> Bool{
        return el.text == "★"
    }
    
    func valueForItem(item:UIView, index:Int) -> Int{
        if(item is UILabel && (item as UILabel).text == "★"){
            return 1
        }else{
            return 0
        }
    }
    func setValueForItem(item:UIView, index:Int, value:Int){
        if(item is UILabel ){
            (item as UILabel).text =  value>0 ? "★" : "☆"
        }
        
    }
    
}

