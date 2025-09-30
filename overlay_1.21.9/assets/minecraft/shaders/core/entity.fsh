#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
in vec4 vertexPerFaceColorBack;
in vec4 vertexPerFaceColorFront;
#else
in vec4 vertexColor;
#endif
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;


// Customizable glow parameters
const float GLOW_THRESHOLD = 0.3;
const float GLOW_INTENSITY = 0.8;
const float GLOW_BOOST = 0.6;  

void main() {
    vec2 texSize = textureSize(Sampler0, 0);
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
#ifdef PER_FACE_LIGHTING
    color *= (gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack) * ColorModulator;
#else
    color *= vertexColor * ColorModulator;
#endif
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
if (texSize.x == 2048 && mod(texSize.y, 1024) == 0) {
    float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    float glowFactor = smoothstep(GLOW_THRESHOLD, 0.8, brightness);
    
    // Store original color before modifications
    vec3 originalColor = color.rgb;
    
    vec3 glow = color.rgb * GLOW_INTENSITY * glowFactor;
    color.rgb += glow;
    
    color.rgb *= (1.0 + GLOW_BOOST * glowFactor);
    
    // Preserve color ratios while capping brightness
    float maxComponent = max(color.r, max(color.g, color.b));
    if (maxComponent > 1.5) { // Adjust this cap as needed
        color.rgb *= 1.5 / maxComponent;
    }
} else {
    color *= lightMapColor;
}
#endif
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}