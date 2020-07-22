//
//  Renderer.swift
//  MetalGenerativeArt
//
//  Created by Lia Kassardjian on 09/07/20.
//  Copyright © 2020 Lia Kassardjian. All rights reserved.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    var pipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    var paletteTexture: MTLTexture!
    var samplerState: MTLSamplerState!
    var uniformBufferProvider: BufferProvider!
    var sceneUniform = Uniform()
    
    fileprivate var square: Square!
    
    private var set: Sets
    private var theme: Theme
    
    var needsRedraw = true
    var forceAlwaysDraw = false
    var isOnboarding = false
    var time = Date()
    
    fileprivate var oldZoom: Float = 0
    fileprivate var zoomConstant: Float = 0
    fileprivate var shiftX: Float = 0
    fileprivate var shiftXConstant: Float = 0
    fileprivate var shiftY: Float = 0
    fileprivate var shiftYConstant: Float = 0
    fileprivate var angleConstant: Float = 0
    
    init(device: MTLDevice, metalView: MTKView, set: Sets, theme: Theme) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        square = Square(device: device)
        self.set = set
        self.theme = theme
        
        uniformBufferProvider = BufferProvider(inFlightBuffers: 3, device: device)
        
        super.init()
        
        buildPipelineState(metalView: metalView)
        configureSet()
        sceneUniform.aspectRatio = Float(metalView.frame.width / metalView.frame.height)
        sceneUniform.scale = 1 / oldZoom
        sceneUniform.translation = (shiftX, shiftY)
    }
    
    private func buildPipelineState(metalView: MTKView) {
        let vertexFunctionName = "vertexShader"
        var fragmentFunctionName = ""
        switch set {
        case .mandelbrot:
            fragmentFunctionName = "mandelbrotFragmentShader"
        case .julia:
            fragmentFunctionName = "juliaFragmentShader"
        case .some:
            fragmentFunctionName = "dewdneyFragmentShader"
        }
    
        guard let library = device.makeDefaultLibrary(),
            let vertexFunction = library.makeFunction(name: vertexFunctionName),
            let fragmentFunction = library.makeFunction(name: fragmentFunctionName)
            else {
            assert(false)
            return
        }
        
        let metalVertexDescriptor = getVertexDescriptor()
        
        pipelineState = compiledPipelineStateFrom(
            vertexShader: vertexFunction,
            fragmentShader: fragmentFunction,
            vertexDescriptor: metalVertexDescriptor,
            metalView: metalView
        )
        depthStencilState = compiledDepthState()
    }
    
    func configureSet() {
        switch set {
        case .mandelbrot:
            shiftX = 0.15
            angleConstant = 0.01
            oldZoom = 10
        case .julia:
            angleConstant = 0.01
            oldZoom = 1.0
        case .some:
            oldZoom = 0.05
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        let path = Bundle.main.path(forResource: theme.rawValue, ofType: "png")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        paletteTexture = try! textureLoader.newTexture(data: data, options: nil)
        samplerState = square.defaultSampler(device)
    }
    
    func getVertexDescriptor() -> MTLVertexDescriptor {
        let metalVertexDescriptor = MTLVertexDescriptor()
        if let attribute = metalVertexDescriptor.attributes[0] {
            attribute.format = MTLVertexFormat.float3
            attribute.offset = 0
            attribute.bufferIndex = 0
        }
        if let layout = metalVertexDescriptor.layouts[0] {
            layout.stride = MemoryLayout<Float>.size * (3)
        }
        return metalVertexDescriptor
    }
    
    func compiledPipelineStateFrom(vertexShader: MTLFunction,
                                   fragmentShader: MTLFunction,
                                   vertexDescriptor: MTLVertexDescriptor,
                                   metalView: MTKView) -> MTLRenderPipelineState? {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.vertexFunction = vertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = metalView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = metalView.depthStencilPixelFormat
        
        var compiledState: MTLRenderPipelineState?
        do {
            compiledState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return compiledState
    }
    
    func compiledDepthState() -> MTLDepthStencilState {
        let depthStencilDesc = MTLDepthStencilDescriptor()
        depthStencilDesc.depthCompareFunction = MTLCompareFunction.less
        depthStencilDesc.isDepthWriteEnabled = true
        
        return device.makeDepthStencilState(descriptor: depthStencilDesc)!
    }
    
    func calculateShift(from angle: Float) -> (x: Float, y: Float) {
        let theta = angle * .pi / 180
        
        let radius: Float = 0.75
        
        let x = radius * cos(theta)
        let y = radius * sin(theta)
        
        return (x, y)
    }
    
    func changePattern(for set: Sets, theme: Theme, in view: MTKView) {
        self.set = set
        self.theme = theme
        
        buildPipelineState(metalView: view)
        configureSet()
        sceneUniform.scale = 1 / oldZoom
        time = Date()
    }
    
    func animate(_ view: MTKView) {
        var shift: (x: Float, y: Float) = (0, 0)
        
        sceneUniform.angle += angleConstant
        if sceneUniform.angle == 360 {
            sceneUniform.angle = 0
        }
        
        shift = calculateShift(from: sceneUniform.angle)
        
        if isOnboarding && time.timeIntervalSinceNow < -30 {
            var nextSet = set
            var nextTheme = theme
            
            if set == .mandelbrot {
                nextSet = .julia
                nextTheme = .lightning
            } else {
                nextSet = .mandelbrot
                nextTheme = .main
            }
            
            changePattern(for: nextSet, theme: nextTheme, in: view)
        }
        
        
        if set == .mandelbrot {
            sceneUniform.translation = (shiftX - shift.x, shiftY - shift.y)
        } else {
            sceneUniform.translation = (shiftX, shiftY)
        }
    }
    
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        sceneUniform.aspectRatio = Float(size.width / size.height)
        needsRedraw = true
    }
    
    func draw(in view: MTKView) {
        guard (needsRedraw == true || forceAlwaysDraw == true) else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let drawable = view.currentDrawable else { return }
                
        animate(view)
        
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            else { return }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setCullMode(MTLCullMode.none)
        
        if let squareBuffer = square?.vertexBuffer {
            renderEncoder.setVertexBuffer(squareBuffer, offset: 0, index: 0)
        }
        
        let uniformBuffer = uniformBufferProvider.nextBufferWithData(sceneUniform)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        
        renderEncoder.setFragmentTexture(paletteTexture, index: 0)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        renderEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
