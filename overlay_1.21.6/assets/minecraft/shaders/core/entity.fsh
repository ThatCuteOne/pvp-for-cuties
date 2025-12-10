#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;

out vec4 fragColor;

// Customizable glow parameters
const float GLOW_INTENSITY = 0.4;
const float GLOW_BOOST = 0.2;
const float MAX_BRIGHTNESS = 2.0;  // Upper limit for trim brightness

void main() {
    vec2 texSize = textureSize(Sampler0, 0);
    vec4 color = texture(Sampler0, texCoord0);
    
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif
    color *= vertexColor * ColorModulator;
    
#ifndef NO_OVERLAY
    vec4 NewoverlayColor = overlayColor;
    if(dot(overlayColor.rgb - vec3(1,0,0),overlayColor.rgb - vec3(1,0,0)) <= 0.00001){
        NewoverlayColor = vec4(163.0/255.0,1.0/255.0,160.0/255.0,1.0);
    }

    color.rgb = mix(NewoverlayColor.rgb, color.rgb, overlayColor.a);
#endif
#ifndef EMISSIVE
    if (texSize.x == 2048 && mod(texSize.y, 1024) == 0) {
        vec3 glow = color.rgb * GLOW_INTENSITY;
        color.rgb += glow;
        color.rgb *= (1.0 + GLOW_BOOST);
        float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        if (brightness > MAX_BRIGHTNESS) {
            color.rgb = color.rgb * (MAX_BRIGHTNESS / brightness);
        }
        color.rgb = min(color.rgb, vec3(2.0));
    } else {
        color *= lightMapColor;
    }
#endif
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}