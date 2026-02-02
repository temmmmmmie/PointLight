#ifndef _SHADOWCUBEMAP
#define _SHADOWCUBEMAP

#include "value.fx"

struct VS_IN
{
    float3 vLocalPos : POSITION;
};

struct VS_OUT
{
    float3 vWorld : POSITION1;
};

VS_OUT VS_ShadowCubeMap(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    output.vWorld = mul(float4(_in.vLocalPos, 1), g_matWorld);
    
    return output;
}
struct GS_OUT
{
    float4 ViewProjPos : SV_POSITION;
    float3 WorldPos : POSITION;
    uint RTIndex : SV_RenderTargetArrayIndex;
};

[maxvertexcount(18)]
void GS_ShadowCubeMap(
    triangle VS_OUT input[3],
    inout TriangleStream<GS_OUT> stream)
{
    [unroll] 
    for (int f = 0; f < 6; ++f)
    {
        GS_OUT output = (GS_OUT) 0; // Assign triangle to the render target corresponding to this cube face 
        output.RTIndex = f; // For each vertex of the triangle, compute screen space position and pass distance 
        [unroll] 
        for (int v = 0; v < 3; ++v)
        {
            output.ViewProjPos = mul(float4(input[v].vWorld.xyz, 1), g_Mat_ViewProj[f]);
            output.WorldPos = input[v].vWorld;
            stream.Append(output);
        } // New triangle 
        stream.RestartStrip();
    }
}

#define LIGHTPOS g_vec4_0;
#define RADIUS   g_float_0;
float PS_ShadowCubeMap(GS_OUT input) : SV_Target
{
    float3 lightworldpos = LIGHTPOS;
    float dist = length(input.WorldPos - lightworldpos);
    return dist / RADIUS;
}
#endif