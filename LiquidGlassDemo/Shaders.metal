#include <metal_stdlib>
using namespace metal;

// Edge refraction shader - displaces pixels near edges to simulate glass refraction
[[ stitchable ]] float2 edgeRefraction(
    float2 position,
    float4 bounds,
    float edgeWidth,
    float intensity,
    float cornerRadius
) {
    float2 center = float2(bounds.z / 2.0, bounds.w / 2.0);
    float2 size = float2(bounds.z, bounds.w);

    // Distance from edges
    float distFromLeft = position.x;
    float distFromRight = size.x - position.x;
    float distFromTop = position.y;
    float distFromBottom = size.y - position.y;

    // Find minimum distance to any edge
    float minDistX = min(distFromLeft, distFromRight);
    float minDistY = min(distFromTop, distFromBottom);
    float minDist = min(minDistX, minDistY);

    // Calculate refraction factor (stronger near edges)
    float refractionFactor = 0.0;
    if (minDist < edgeWidth) {
        // Smooth falloff from edge
        refractionFactor = (1.0 - minDist / edgeWidth) * intensity;
        // Apply easing for more natural glass-like bending
        refractionFactor = refractionFactor * refractionFactor * (3.0 - 2.0 * refractionFactor);
    }

    // Direction towards center (refraction bends light inward at edges)
    float2 toCenter = center - position;
    float2 direction = normalize(toCenter);

    // Apply displacement - pixels near edges sample from slightly different positions
    float2 displacement = direction * refractionFactor * edgeWidth * 0.3;

    return position + displacement;
}
