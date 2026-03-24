#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    if (color.r > 0.25 && color.r < 0.251
        && color.g > 0.25 && color.g < 0.251
        && color.b > 0.25 && color.b < 0.251) {
            // uncomment for debugging ig
            //fragColor = vec4(1.0, 0.0, 0.0, 1.0); return;
            color = vec4(0.6667, 0.6667, 0.6667, 1.0);
    }
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
