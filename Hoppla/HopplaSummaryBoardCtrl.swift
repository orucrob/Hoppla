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

class HopplaSummaryBoardCtrl: UIViewController, HopplaBoardItemProvider {
    
    @IBAction func openCloseAction(sender: UIButton) {
        if(hopplaSummary.mode == HopplaSummaryBoard.Mode.NORMAL){
            hopplaSummary.setMode(HopplaSummaryBoard.Mode.DETAIL, animate: true)
            sender.setTitle("Normal", forState: UIControlState.Normal)
        }else{
            hopplaSummary.setMode(HopplaSummaryBoard.Mode.NORMAL, animate: true)
            sender.setTitle("Detail", forState: UIControlState.Normal)
        }
//        if let t = hopplaSummary.title{
//            hopplaSummary.title! += " heoo"
//        }else{
//            hopplaSummary.title = "first"
//        }
        
    }
    override func viewDidLoad() {
        var b = HopplaBoard()
        b.indexesInLevel = 2
        b.levels = 3
        b.itemProvider = self
        hopplaSummary.board = b
        var bg = UIView()
        bg.backgroundColor = UIColor.orangeColor()
        hopplaSummary.backgroundView = bg
        
        
        //update title
//        var name = UILabel(frame: CGRectNull)
//        name.font = UIFont(name: "HelveticaNeue-Thin", size: 50)
//        name.textColor = UIColor.whiteColor()
//        hopplaSummary.titleLabel = name

        hopplaSummary.title = "hello"
    }
    
    @IBOutlet weak var hopplaSummary: HopplaSummaryBoard!
    
    
    func hopplaBoardGetItem(hb: HopplaBoard, levelIdx: Int, idxInLevel: Int) -> HopplaImage {
        var w = 20
        if(levelIdx == 0){
            w = 50
        }else if( levelIdx == 1 ){
            w = 35
        }
        var h = HopplaImage(frame: CGRect(x: 0, y: 0, width: w, height: w))
        h.imageName = "star.png"
        return h
    }
    func hopplaBoardGetSize(hb: HopplaBoard, levelIdx: Int, idxInLevel: Int) -> CGSize {
        var w = 20
        if(levelIdx == 0){
            w = 50
        }else if( levelIdx == 1 ){
            w = 35
        }
        return CGSize(width: w, height: w)
    }
}
