//
//  FullContentWindow.swift
//  TGUIKit
//
//  Created by Alex on 2020/4/29.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Foundation
import SwiftUI

open class FullContentWindow: Window{
    private var buttons: [NSButton] = []
    public let titleBarAccessoryViewController=NSTitlebarAccessoryViewController()
    private lazy var titleBarHeight = calculatedTitleBarHeight
    private let titleBarLeadingOffset: CGFloat?
    private var originalLeadingOffsets: [CGFloat] = []
    public override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool){
        let styleMask: NSWindow.StyleMask = [.closable, .titled, .miniaturizable, .resizable, .fullSizeContentView]
        self.titleBarLeadingOffset = 7
        super.init(contentRect: contentRect, styleMask: styleMask, backing: .buffered, defer: true)
        setup(titleBarHeight:50,titleBarLeadingOffset:self.titleBarLeadingOffset)
    }
    public init(contentRect: NSRect, titleBarHeight: CGFloat, titleBarLeadingOffset: CGFloat? = nil) {
        self.titleBarLeadingOffset = titleBarLeadingOffset
        let styleMask: NSWindow.StyleMask = [.closable, .titled, .miniaturizable, .resizable, .fullSizeContentView]
        super.init(contentRect: contentRect, styleMask: styleMask, backing: .buffered, defer: true)
        setup(titleBarHeight:titleBarHeight,titleBarLeadingOffset:titleBarLeadingOffset)
        
    }
    
    private func setup(titleBarHeight: CGFloat, titleBarLeadingOffset: CGFloat? = nil){
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        buttons = [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton].compactMap {
           standardWindowButton($0)
        }
        var accessoryViewHeight = titleBarHeight - calculatedTitleBarHeight
        accessoryViewHeight = max(0, accessoryViewHeight)
        
        if accessoryViewHeight > 0 {
            titleBarAccessoryViewController.view = TitleBarView(frame: CGRect(x: 0.0,y: 0.0,width: 0.0,height: accessoryViewHeight))
            addTitlebarAccessoryViewController(titleBarAccessoryViewController)
        }
        self.titleBarHeight = max(titleBarHeight, calculatedTitleBarHeight)
    }
    public override func layoutIfNeeded() {
       super.layoutIfNeeded()
       if originalLeadingOffsets.isEmpty {
          let firstButtonOffset = buttons.first?.frame.origin.x ?? 0
          originalLeadingOffsets = buttons.map { $0.frame.origin.x - firstButtonOffset }
       }
        if #available(OSX 10.12, *) {
            if titleBarAccessoryViewController.view.frame.height > 0, !titleBarAccessoryViewController.isHidden {
                setupButtons()
            }
        } else {
            // Fallback on earlier versions
            if titleBarAccessoryViewController.view.frame.height > 0{
                setupButtons()
            }
        }
    }
    
    public var adjustMinX : CGFloat{
        if #available(OSX 10.12, *) {
            if titleBarAccessoryViewController.isHidden {
               return 0
            }
        }
        if !self.isFullScreen {
            return buttons.last?.frame.maxX ?? 0
        }
        return 0
    }
    
}
extension FullContentWindow {

   public var standardWindowButtonsRect: CGRect {
      var result = CGRect()
      if let firstButton = buttons.first, let lastButton = buttons.last {
         let leadingOffset = firstButton.frame.origin.x
         let maxX = lastButton.frame.maxX
         result = CGRect(x: leadingOffset, y: 0, width: maxX - leadingOffset, height: titleBarHeight)
         if let titleBarLeadingOffset = titleBarLeadingOffset {
            result = result.offsetBy(dx: titleBarLeadingOffset - leadingOffset, dy: 0)
         }
      }
      return result
   }
}

extension FullContentWindow {

   private func setupButtons() {
      let barHeight = calculatedTitleBarHeight
      for (idx, button) in buttons.enumerated() {
         let coordY = (barHeight - button.frame.size.height) * 0.5
         var coordX = button.frame.origin.x
         if let titleBarLeadingOffset = titleBarLeadingOffset {
            coordX = titleBarLeadingOffset + originalLeadingOffsets[idx]
         }
         button.setFrameOrigin(CGPoint(x: coordX, y: coordY))
      }
   }

   private var calculatedTitleBarHeight: CGFloat {
      let result = contentRect(forFrameRect: frame).height - contentLayoutRect.height
      return result
   }
    
}

class TitleBarView:NSView{
    override func mouseDown(with event: NSEvent) {
        
    }
}
