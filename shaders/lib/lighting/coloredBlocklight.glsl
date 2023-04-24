vec2 Reprojection(vec3 pos) {
	pos = pos * 2.0 - 1.0;

	vec4 viewPosPrev = gbufferProjectionInverse * vec4(pos, 1.0);
	viewPosPrev /= viewPosPrev.w;
	viewPosPrev = gbufferModelViewInverse * viewPosPrev;

	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	cameraOffset *= float(pos.z > 0.56);

	vec4 previousPosition = viewPosPrev + vec4(cameraOffset, 0.0);
	previousPosition = gbufferPreviousModelView * previousPosition;
	previousPosition = gbufferPreviousProjection * previousPosition;
	return previousPosition.xy / previousPosition.w * 0.5 + 0.5;
}

vec3 ApplyMultiColoredBlocklight(vec3 blocklightCol, vec3 screenPos) {
	if (screenPos.z > 0.56) {
		screenPos.xy = Reprojection(screenPos);
	}
	vec3 coloredLight = texture2D(colortex9, screenPos.xy).rgb;
		
	vec3 coloredLightNormalized = normalize(coloredLight + 0.00001);
	coloredLightNormalized *= GetLuminance(blocklightCol) / GetLuminance(coloredLightNormalized);
	float coloredLightMix = min((coloredLight.r + coloredLight.g + coloredLight.b) * 512.0, 1.0);

	return mix(blocklightCol, coloredLightNormalized, coloredLightMix);
}