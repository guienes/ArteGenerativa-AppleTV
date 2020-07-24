//
//  BufferProvider.swift
//  Model_IO_OSX
//
//  Created by Andriy K. on 6/20/15.
//  Copyright © 2015 Andriy K. All rights reserved.
//

import UIKit
import simd
import Accelerate

struct Uniform {
    var scale: Float = 1
    var translation: (x: Float, y: Float) = (0, 0)
    var maxNumberOfiterations: Float = 100
    var aspectRatio: Float = 1
    var angle: Float = 135
    var radius: Float = 0.7885
    
    fileprivate var raw: [Float] {
        return [scale, translation.x, translation.y, maxNumberOfiterations, aspectRatio, angle, radius, 0, 0, 0]
    }
    
    static var size = MemoryLayout<Float>.size * 10
}


class BufferProvider {
    
    static let floatSize = MemoryLayout<Float>.size
    static var bufferSize = Uniform.size
    
    fileprivate(set) var indexOfAvaliableBuffer = 0
    fileprivate(set) var numberOfInflightBuffers: Int
    fileprivate var buffers:[MTLBuffer]
    fileprivate(set) var avaliableResourcesSemaphore:DispatchSemaphore
    
    init(inFlightBuffers: Int, device: MTLDevice) {
        
        avaliableResourcesSemaphore = DispatchSemaphore(value: inFlightBuffers)
        
        numberOfInflightBuffers = inFlightBuffers
        buffers = [MTLBuffer]()
        
        for _ in 0 ..< inFlightBuffers {
            if let buffer = device.makeBuffer(length: BufferProvider.bufferSize, options: MTLResourceOptions()) {
                buffer.label = "Uniform buffer"
                buffers.append(buffer)
            }
        }
    }
    
    deinit{
        for _ in 0...numberOfInflightBuffers{
            avaliableResourcesSemaphore.signal()
        }
    }
    
    func nextBufferWithData(_ uniform: Uniform) -> MTLBuffer {
        let uniformBuffer = self.buffers[indexOfAvaliableBuffer]
        indexOfAvaliableBuffer += 1
        if indexOfAvaliableBuffer == numberOfInflightBuffers {
            indexOfAvaliableBuffer = 0
        }
        
        memcpy(uniformBuffer.contents(), uniform.raw, Uniform.size)
        return uniformBuffer
    }
    
}
