//
//  Shaders.metal
//  Mandelbrot
//
//  Created by Andriy K. on 2/4/16.
//  Copyright © 2016 Andriy K. All rights reserved.
//

#include <metal_stdlib>
#include <metal_math>
using namespace metal;


int findMandelbrot(float cr, float ci, int max_iterations);
int findJulia(float cr, float ci, float z, int max_iterations);

// Vertex data recieved in vertex shader
struct Vertex {
    float3 position [[attribute(0)]];
};


// Vertex data sent from vertex shader to fragment shader (interpolated)
struct VertexOut {
    float4 position [[position]];
    float2 coords;
};

// Constants
struct Uniforms {
    float scale;
    float xTranslate;
    float yTranslate;
    float maxIterations;
    float aspectRatio;
    float angle;
    float radius;
};


// Function to find number of iterations for number to "blow"
// cr - real part of complex number
// ci - imaginary part of complex image
// max_iterations - how many times we iterate
int findMandelbrot(float cr, float ci, int max_iterations)
{
    int i = 0;
    float zr = 0.0, zi = 0.0;
    while (i < max_iterations && zr * zr + zi * zi < 4.0)
    {
        float temp = zr * zr - zi * zi + cr;
        zi = 2.0 * zr * zi + ci;
        zr = temp;
        i++;
    }
    return i;
}

// Function to find number of iterations for number to "blow"
// cr - real part of complex number
// ci - imaginary part of complex image
// zr - real part of constant to calculate Julia Set
// zi - imaginary part of constant to calculate Julia Set
// max_iterations - how many times we iterate
int findJulia(float zr, float zi, float cr, float ci, int max_iterations) {
    int i = 0;
    while (i < max_iterations && zr * zr + zi * zi < 4.0)
    {
        float temp = zr * zr - zi * zi + cr;
        zi = 2.0 * zr * zi + ci;
        zr = temp;
        i++;
    }
    return i;
}

// MARK: - Vertex shader
vertex VertexOut vertexShader(const    Vertex    vertexIn      [[stage_in]],
                              constant Uniforms &uniformBuffer [[buffer(1)]],
                              unsigned int       vid           [[vertex_id]])
{
    VertexOut vertexOut;
    vertexOut.position = float4(vertexIn.position,1);
    float scale = uniformBuffer.scale;
    vertexOut.coords.x = (vertexIn.position.x * uniformBuffer.aspectRatio) * scale - uniformBuffer.xTranslate;
    vertexOut.coords.y = vertexIn.position.y * scale - uniformBuffer.yTranslate;
    return vertexOut;
}


// MARK: - Fragment shader
fragment float4 mandelbrotFragmentShader(VertexOut interpolated [[stage_in]],
                                         texture2d<float>  tex2D        [[texture(0)]],
                                         constant Uniforms &uniformBuffer [[buffer(0)]],
                                         sampler           sampler2D    [[sampler(0)]])
{
    int maxN = uniformBuffer.maxIterations;
    
    float x = interpolated.coords.x;
    float y = interpolated.coords.y;
    
    int n = findMandelbrot(x, y, maxN);
    
    float2 paletCoord = float2((n == maxN ? 0.0 : float(n)) / 100.0  , 0);
    float4 finalColor = tex2D.sample(sampler2D, paletCoord);
    
    return finalColor;
}

fragment float4 juliaFragmentShader(VertexOut interpolated [[stage_in]],
                                    texture2d<float>  tex2D        [[texture(0)]],
                                    constant Uniforms &uniformBuffer [[buffer(0)]],
                                    sampler           sampler2D    [[sampler(0)]])
{
    int maxN = uniformBuffer.maxIterations;
    
    float alpha = uniformBuffer.angle * M_PI_F / 180;
    float realValue = uniformBuffer.radius * cos(alpha);
    float imaginaryValue = uniformBuffer.radius * sin(alpha);
    
    float x = interpolated.coords.x;
    float y = interpolated.coords.y;
    
    int n = findJulia(x, y, realValue, imaginaryValue, maxN);
    
    float2 paletCoord = float2((n == maxN ? 0.0 : float(n)) / 100.0  , 0);
    float4 finalColor = tex2D.sample(sampler2D, paletCoord);
    
    return finalColor;
}

fragment float4 dewdneyFragmentShader(VertexOut interpolated [[stage_in]],
                                    texture2d<float>  tex2D        [[texture(0)]],
                                    constant Uniforms &uniformBuffer [[buffer(0)]],
                                    sampler           sampler2D    [[sampler(0)]])
{
    float x = interpolated.coords.x;
    float y = interpolated.coords.y;
    
    float r = cos(x) + sin(y);
    
    return float4(cos(y*r), cos(x*y*r), sin(r*x), 1);
}




