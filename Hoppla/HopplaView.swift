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
    let labCount = UILabel(frame: CGRectNull)

    //value - how many stars are filled
    var value:Int = 0{
        didSet{
            if(value>count){
                value = count
            }else{
                for (idx,el) in enumerate(els){
                    el.text = (idx<value) ? "★": "☆"
                }
            }
        }
    }
    
    //total amount of stars
    var count:Int = 0 {
        didSet{
            //remove
            for e in els{
                e.removeFromSuperview()
            }
            els.removeAll(keepCapacity: false)
            labCount.removeFromSuperview();
            
            //add
            for var index = 0; index < count; ++index {
                let el = UILabel();
                //el.text = "☆";//"★"
                el.textAlignment = NSTextAlignment.Center
                els.append(el)
                // el.layer.borderWidth = 1
                addSubview(el)
                if(index == keyItem){
                    el.userInteractionEnabled = true
                    el.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "elTap:"))
                }
            }
            addSubview(labCount)
            
            //layout
            layoutEls(count/2);        }
    }
    //which item is static (and it's not moved)
    var keyItem:Int = 0
    
    //how many iteme has been hidden during hiding
    private var finished:Int = 0{
        didSet{
            labCount.text = "\(finished)"
        }
    }
    
    //holds all stars elements in order
    private var els = [UILabel]()
    
    //is stars board open or closed?
    private var open = true
    
    //open or close stars
    func elTap(gr: AnyObject){
        var t = CGFloat(1);
        var mx = CGFloat(0);
        var dis = [CGFloat]()
        
        var keyFrame = els[keyItem].frame
        if(!open){
            var t = els[keyItem].transform;
            els[keyItem].transform = CGAffineTransformIdentity
            keyFrame = els[keyItem].frame
            els[keyItem].transform = t
        }
        
        for el in els{
            var frame = el.frame
            if(!open){
                var t = el.transform;
                el.transform = CGAffineTransformIdentity
                frame = el.frame
                el.transform = t
            }
            let a = pow(frame.origin.x - keyFrame.origin.x, 2.0)
            let b = pow(frame.origin.y - keyFrame.origin.y, 2.0)
            let d = sqrt(a+b)
            mx = max(mx, d)
            dis.append(d)
        }

        if(open){
            open = false
            labCount.hidden = false
            UIView.animateWithDuration(Double(t/3), animations: { () -> Void in
                self.labCount.alpha = 1
            })
            for (idx,el) in enumerate(els){
                let d = dis[idx]
                let tt = d*t/mx
                UIView.animateWithDuration(Double(tt),  animations: { () -> Void in
                    el.transform = CGAffineTransformMakeTranslation(keyFrame.origin.x-el.frame.origin.x, keyFrame.origin.y-el.frame.origin.y)
                }, completion: { (finised) -> Void in
                    if(self.isSelected(el)){
                        self.finished = min(self.finished+1, self.value) //min prevents to rise over value if more open-close-open anims occured
                    }
                })
            }
        }else{
            open = true
            finished = 0;
            UIView.animateWithDuration(Double(t/3), animations: { () -> Void in
                self.labCount.alpha = 0;
            }, completion:{ (finished) -> Void in
                self.labCount.hidden = true
            })
            for (idx,el) in enumerate(els){
                let d = dis[idx]
                let tt = d*t/mx
                UIView.animateWithDuration(Double(tt), animations: { () -> Void in
                    el.transform = CGAffineTransformIdentity
                })
            }
            
        }
    }
    
    //determine whether the element is selected (full or empty star)
    private func isSelected(el:UILabel) -> Bool{
        return el.text == "★"
    }

    
    //MARK: - initializations
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        doInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }
    private func doInit(){
        count = 10;

        labCount.hidden = true
        labCount.alpha = 0
        labCount.text = "1"
        labCount.textAlignment = NSTextAlignment.Right
        
    }

    
    
    
    //MARK: - layout board
    private func layoutEls(rowCount:Int){
        var bindings:[NSObject : AnyObject] = ["view": self]
        var allConstraints = [NSLayoutConstraint]()

        var formats:[String] = []
        var formatRow = "H:|"
        var formatCols = [String]()

        var widthMultiplier: CGFloat = 1.0 / CGFloat(rowCount)
        
        labCount.setTranslatesAutoresizingMaskIntoConstraints(false)
        for (idx, el) in enumerate(els) {
            bindings.updateValue(el, forKey: "el\(idx)")
            el.setTranslatesAutoresizingMaskIntoConstraints(false)

            var x = idx % rowCount
            var y = (idx - x) / rowCount
            
            //width (row)
            if idx == 0 {
                formatRow += "[el\(idx)]"
            }else{
                formatRow += "[el\(idx)(==el0)]"
            }
            if x == (rowCount-1)  || idx == (els.count-1){ //if last in row or last item
                formatRow += "|" //TODO if last and not full row
                formats.append(formatRow)
                //start new row
                formatRow = "H:|"
            }
            
            //height (cols)
            if y==0{
                formatCols.append("V:|[el\(idx)]")
            }else{
                formatCols[x]+="[el\(idx)]"
            }
            //make it squared
            allConstraints.append(NSLayoutConstraint(item: el, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
            if(idx == keyItem){
                allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
                allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
                allConstraints.append(NSLayoutConstraint(item: labCount, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: el, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
            }
            
        }
        //finish vertical formats
        for f in formatCols{
            formats.append(f+"|")
        }
        
        //create constrains from string formats
        for f in formats{
            var c = NSLayoutConstraint.constraintsWithVisualFormat(f, options: NSLayoutFormatOptions(0), metrics: nil, views: bindings)
            for i in c { allConstraints.append(i as NSLayoutConstraint) }
        }
        //add to self
        self.addConstraints(allConstraints)
    }
}
