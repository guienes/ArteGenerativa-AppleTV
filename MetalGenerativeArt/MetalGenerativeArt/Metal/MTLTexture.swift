//
//  MTLTexture.swift
//  MetalGenerativeArt
//
//  Created by Lia Kassardjian on 13/07/20.
//  Copyright © 2020 Lia Kassardjian. All rights reserved.
//

import Metal
import MetalKit

extension MTLTexture {
    
    func bytes() -> UnsafeMutableRawPointer? {
        let width = self.width
        let height   = self.height
        let rowBytes = self.width * 4
        guard let p = malloc(width * height * 4) else { return nil }
        
        self.getBytes(p,
                      bytesPerRow: rowBytes,
                      from: MTLRegionMake2D(0, 0, width, height),
                      mipmapLevel: 0)
        
        return p
    }
    
    func toImage() -> CGImage? {
        guard let p = bytes() else { return nil }
        
        let pColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in return }
        
        let selftureSize = self.width * self.height * 4
        let rowBytes = self.width * 4
        guard let provider = CGDataProvider(
            dataInfo: nil,
            data: p,
            size: selftureSize,
            releaseData: releaseMaskImagePixelData
            ) else { return nil }
        
        let cgImageRef = CGImage(
            width: self.width,
            height: self.height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: rowBytes,
            space: pColorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
            )!
        
        return cgImageRef
    }
}
