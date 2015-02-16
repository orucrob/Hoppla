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

class HopplaListCtrl: UIViewController, HopplaListItemProvider{
    private var _items = [String: UIView]()
    private var _detailItem: UIView?
    private var _settItem: UIView?
    
    @IBOutlet weak var hopplaList: HopplaList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hopplaList.itemProvider = self
        var gr = UITapGestureRecognizer(target: self, action: "handleDetailTap:")
        hopplaList.detail.addGestureRecognizer(gr)

    }
    
    func handleDetailTap(gr: UITapGestureRecognizer){
        hopplaList.closeDetail()
    }

    func hopplaListGetItem(hl: HopplaList, idx: Int) -> UIView {
        if(_items["\(idx)"] != nil){
            return _items["\(idx)"]!
        }else {
            var el = UIView()
            
            var r:CGFloat = CGFloat(arc4random_uniform(100))/100
            var g:CGFloat = CGFloat(arc4random_uniform(100))/100
            var b:CGFloat = CGFloat(arc4random_uniform(100))/100
            
            el.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
            _items["\(idx)"] = el
            return el
            
        }
    }
    func hopplaListGetDetailItem(hl: HopplaList, idx: Int) -> UIView {
        if(_detailItem == nil){
            _detailItem = UIView()
        }
        if(_items["\(idx)"] != nil){
            _detailItem?.backgroundColor = _items["\(idx)"]?.backgroundColor
            return _detailItem!
        }else{
            //should never happen
            return UIView()
        }
    }
    func hopplaListGetSettingsItem(hl: HopplaList, idx: Int) -> UIView? {
//        if(_settItem == nil){
//            _settItem = UIView()
//        }
//        if(_items["\(idx)"] != nil){
//            _settItem?.backgroundColor = UIColor.orangeColor()//_items["\(idx)"]?.backgroundColor
//            return _settItem!
//        }else{
            //should never happen
            return nil
//        }
    }
    func hopplaListGetNumberOfItems(hl: HopplaList) -> Int {
        return 8
    }
    func hopplaListHeightForItem(hl: HopplaList, idx: Int) -> CGFloat? {
        return 90
    }
    func hopplaListIdForItem(hl: HopplaList, idx: Int) -> String {
        return "\(idx)"
    }
}