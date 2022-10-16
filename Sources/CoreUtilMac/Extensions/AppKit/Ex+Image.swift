//
//  Ex+Image.swift
//  CoreUtil
//
//  Created by yuki on 2020/03/10.
//  Copyright © 2020 yuki. All rights reserved.
//

import Cocoa

extension NSImage {
    public var cgImage: CGImage? {
        var imageRect = CGRect(size: self.size)
        return cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
    }
}


extension CGImage {
    public func convertToGrayscale() -> CGImage {
        let imageRect = CGRect(size: CGSize(width: width, height: height))
        let context = CGContext(
            data: nil, width: self.width, height: self.height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        context.draw(self, in: imageRect)
        return context.makeImage()!
    }
}

extension NSImage {
    func resizedAspectFill(to newSize: CGSize) -> NSImage {
        let bitmapRep = NSBitmapImageRep(size: newSize)
        let scale = self.size.aspectFillRatio(fillInside: newSize)
        
        NSGraphicsContext(bitmapImageRep: bitmapRep)?.perform {
            self.draw(in: CGRect(center: newSize.convertToPoint()/2, size: self.size * scale), from: .zero, operation: .copy, fraction: 1.0)
        }
        
        return NSImage(bitmapImageRep: bitmapRep)
    }
    
    func resizedAspectFit(to newSize: CGSize, fillColor: NSColor = .black) -> NSImage {
        let bitmapRep = NSBitmapImageRep(size: newSize)
        let scale = self.size.aspectFitRatio(fitInside: newSize)
        
        NSGraphicsContext(bitmapImageRep: bitmapRep)?.perform {
            fillColor.setFill()
            NSRect(size: newSize).fill()
            draw(in: CGRect(center: newSize.convertToPoint()/2, size: self.size * scale), from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        
        return NSImage(bitmapImageRep: bitmapRep)
    }
    
    
    func resized(to newSize: NSSize) -> NSImage {
        let bitmapRep = NSBitmapImageRep(size: newSize)
        
        NSGraphicsContext(bitmapImageRep: bitmapRep)?.perform {
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
        }
        
        return NSImage(bitmapImageRep: bitmapRep)
    }
}

extension NSGraphicsContext {
    public func perform(_ block: () -> ()) {
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = self
        block()
        NSGraphicsContext.restoreGraphicsState()
    }
}

extension NSImage {
    public convenience init(bitmapImageRep: NSBitmapImageRep) {
        self.init(size: bitmapImageRep.size)
        self.addRepresentation(bitmapImageRep)
    }
    public convenience init(size: CGSize, colorSpaceName: NSColorSpaceName = .calibratedRGB, canvas: () -> ()) {
        let bitmapImageRep = NSBitmapImageRep(size: size, colorSpaceName: colorSpaceName)
        NSGraphicsContext(bitmapImageRep: bitmapImageRep)?.perform(canvas)
        self.init(bitmapImageRep: bitmapImageRep)
    }
    public convenience init(size: CGSize, colorSpaceName: NSColorSpaceName = .calibratedRGB, cgcanvas: (CGContext) -> ()) {
        self.init(size: size, colorSpaceName: colorSpaceName, canvas: {
            if let context = NSGraphicsContext.current?.cgContext { cgcanvas(context) }
        })
    }
}

extension NSBitmapImageRep {
    public convenience init(size: CGSize, colorSpaceName: NSColorSpaceName = .calibratedRGB) {
        self.init(
            bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: colorSpaceName, bytesPerRow: 0, bitsPerPixel: 0
        )!
    }
}


extension CGContext {
    public var size: CGSize { CGSize(width: width, height: height) }
    public var bounds: CGRect { CGRect(size: size) }
}
