#ifdef OVERWORLD

//BSL-NS//
#include "/ns/configs/sky.glsl"

float CloudSample(vec2 coord, vec2 wind, float currentStep, float sampleStep, float sunCoverage) {
	#if CLOUD_BASE == 0
	float noiseBase = texture2D(noisetex, coord * 0.25 + wind).r;
	#else
	float noiseBase = texture2D(noisetex, coord * 0.5 + wind).g;
	noiseBase = pow(1.0 - noiseBase, 2.0) * 0.5 + 0.25;
	#endif

	float detailZ = floor(currentStep * float(CLOUD_THICKNESS) + 0.5) * 0.04;
	float noiseDetail = texture2D(noisetex, coord * 0.5 - wind * 2.0 + detailZ).b;

	float noiseCoverage = abs(currentStep - 0.125) * (currentStep > 0.125 ? 1.14 : 8.0);
	noiseCoverage = noiseCoverage * noiseCoverage * 4.0;
	
	float noise = mix(noiseBase, noiseDetail, 0.0476 * CLOUD_DETAIL) * 21.0 - noiseCoverage;
	noise = mix(noise, 21.0, 0.33 * rainStrength);
	float multiplier = CLOUD_DENSITY * CLOUD_THICKNESS / 4.0 * sampleStep;
	multiplier *= (1.0 - 0.75 * rainStrength);

	noise = max(noise - (sunCoverage * 3.0 + CLOUD_AMOUNT), 0.0) * multiplier;
	noise = noise / sqrt(noise * noise + 0.5);

	return noise;
}

vec4 DrawCloud(vec3 viewPos, float dither, vec3 lightCol, vec3 ambientCol) {
	#ifdef TAA
	dither = fract(16.0 * frameTimeCounter + dither);
	#endif

	int samples = CLOUD_THICKNESS * 2;
	
	float cloud = 0.0, cloudLighting = 0.0;

	float sampleStep = 1.0 / samples;
	float currentStep = dither * sampleStep;
	
	vec3 nViewPos = normalize(viewPos);
	float VoU = dot(nViewPos, upVec);
	float VoL = dot(nViewPos, lightVec);
	
	float sunCoverage = pow(clamp(abs(VoL) * 2.0 - 1.0, 0.0, 1.0), 12.0) * (1.0 - rainStrength);

	vec2 wind = vec2(
		frametime * CLOUD_SPEED * 0.0005,
		sin(frametime * CLOUD_SPEED * 0.001) * 0.005
	) * CLOUD_HEIGHT / 15.0;

	vec3 cloudColor = vec3(0.0);

	if (VoU > 0.025) {
		vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz);

		float halfVoL = VoL * shadowFade * 0.5 + 0.5;
		float halfVoLSqr = halfVoL * halfVoL;
		float scattering = pow(halfVoL, 6.0);
		float noiseLightFactor = (2.0 - 1.5 * VoL * shadowFade) * CLOUD_DENSITY * 0.5;

		for(int i = 0; i < samples; i++) {
			if (cloud > 0.99) break;
			vec3 planeCoord = wpos * ((CLOUD_HEIGHT + currentStep * CLOUD_THICKNESS) / wpos.y) * 0.004;
			vec2 coord = cameraPosition.xz * 0.00025 + planeCoord.xz;

			float noise = CloudSample(coord, wind, currentStep, sampleStep, sunCoverage);

			float sampleLighting = pow(currentStep, 1.125 * halfVoLSqr + 0.875) * 0.8 + 0.2;
			sampleLighting *= 1.0 - pow(noise, noiseLightFactor);

			cloudLighting = mix(cloudLighting, sampleLighting, noise * (1.0 - cloud * cloud));
			cloud = mix(cloud, 1.0, noise);

			currentStep += sampleStep;
		}
		cloudLighting = mix(cloudLighting, 1.0, (1.0 - cloud * cloud) * scattering * 0.5);
		cloudColor = mix(
			ambientCol * (0.35 * sunVisibility + 0.5),
			lightCol * (0.85 + 1.15 * scattering),
			cloudLighting
		);
		cloudColor *= 1.0 - 0.6 * rainStrength;
		// cloudColor = vec3(cloudLighting);
		cloud *= clamp(1.0 - exp(-20.0 * VoU + 0.5), 0.0, 1.0) * (1.0 - 0.6 * rainStrength);
	}
	cloudColor *= CLOUD_BRIGHTNESS * (0.5 - 0.25 * (1.0 - sunVisibility) * (1.0 - rainStrength));
	// cloudColor *= voidFade;
	#if MC_VERSION >= 11800
	cloudColor *= clamp((cameraPosition.y + 70.0) / 8.0, 0.0, 1.0);
	#else
	cloudColor *= clamp((cameraPosition.y + 6.0) / 8.0, 0.0, 1.0);
	#endif
	
	#ifdef UNDERGROUND_SKY
	cloud *= mix(clamp((cameraPosition.y - 48.0) / 16.0, 0.0, 1.0), 1.0, eBS);
	#endif
	
	return vec4(cloudColor, cloud * cloud * CLOUD_OPACITY);
}

float GetNoise(vec2 pos) {
	return fract(sin(dot(pos, vec2(12.9898, 4.1414))) * 43758.5453);
}

void DrawStars(inout vec3 color, vec3 viewPos, int moonPhase) {
	vec3 wpos = vec3(gbufferModelViewInverse * vec4(viewPos, 1.0));
	vec3 planeCoord = wpos / (wpos.y + length(wpos.xz));
	vec2 wind = vec2(frametime, 0.0);
	vec2 coord = planeCoord.xz * 0.4 + cameraPosition.xz * 0.0001 + wind * 0.00125;
	coord = floor(coord * 1024.0) / 1024.0;
	
	float VoU = clamp(dot(normalize(viewPos), upVec), 0.0, 1.0);
	float multiplier = sqrt(sqrt(VoU)) * 5.0 * (1.0 - rainStrength) * moonVisibility;
	
	float star = 1.0;
	if (VoU > 0.0) {
		star *= GetNoise(coord.xy);
		star *= GetNoise(coord.xy + 0.10);
		star *= GetNoise(coord.xy + 0.23);
	}
	star = clamp(star - 0.8125, 0.0, 1.0) * multiplier;
	//star *= voidFade;
	#if MC_VERSION >= 11800
	star *= clamp((cameraPosition.y + 70.0) / 8.0, 0.0, 1.0);
	#else
	star *= clamp((cameraPosition.y + 6.0) / 8.0, 0.0, 1.0);
	#endif

	#ifdef UNDERGROUND_SKY
	star *= mix(clamp((cameraPosition.y - 48.0) / 16.0, 0.0, 1.0), 1.0, eBS);
	#endif
		
	color += star * pow(lightNight, vec3(0.8))
	#ifdef NS_MOON_PHASE_STARS_ENABLED
	* (1 - cos(moonPhase * 0.3927) * 0.6667)
	#endif
	;
}

#ifdef AURORA
#include "/lib/color/auroraColor.glsl"

float AuroraSample(vec2 coord, vec2 wind, float VoU) {
	float noise = texture2D(noisetex, coord * 0.0625  + wind * 0.25).b * 3.0;
		  noise+= texture2D(noisetex, coord * 0.03125 + wind * 0.15).b * 3.0;

	noise = max(1.0 - 4.0 * (0.5 * VoU + 0.5) * abs(noise - 3.0), 0.0);

	return noise;
}

vec3 DrawAurora(vec3 viewPos, float dither, int samples) {
	#ifdef TAA
	dither = fract(16.0 * frameTimeCounter + dither);
	#endif
	
	float sampleStep = 1.0 / samples;
	float currentStep = dither * sampleStep;

	float VoU = dot(normalize(viewPos), upVec);

	float visibility = moonVisibility * (1.0 - rainStrength) * (1.0 - rainStrength);

	#ifdef WEATHER_PERBIOME
	visibility *= isCold * isCold;
	#endif

	vec2 wind = vec2(
		frametime * CLOUD_SPEED * 0.000125,
		sin(frametime * CLOUD_SPEED * 0.05) * 0.00025
	);

	vec3 aurora = vec3(0.0);

	if (VoU > 0.0 && visibility > 0.0) {
		vec3 wpos = normalize((gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz);
		for(int i = 0; i < samples; i++) {
			vec3 planeCoord = wpos * ((8.0 + currentStep * 7.0) / wpos.y) * 0.004;

			vec2 coord = cameraPosition.xz * 0.00004 + planeCoord.xz;
			coord += vec2(coord.y, -coord.x) * 0.3;

			float noise = AuroraSample(coord, wind, VoU);
			
			if (noise > 0.0) {
				noise *= texture2D(noisetex, coord * 0.125 + wind * 0.25).b;
				noise *= 0.5 * texture2D(noisetex, coord + wind * 16.0).b + 0.75;
				noise = noise * noise * 3.0 * sampleStep;
				noise *= max(sqrt(1.0 - length(planeCoord.xz) * 3.75), 0.0);

				vec3 auroraColor = mix(auroraLowCol, auroraHighCol, pow(currentStep, 0.4));
				aurora += noise * auroraColor * exp2(-6.0 * i * sampleStep);
			}
			currentStep += sampleStep;
		}
	}
	// visibility *= voidFade;
	#if MC_VERSION >= 11800
	visibility *= clamp((cameraPosition.y + 70.0) / 8.0, 0.0, 1.0);
	#else
	visibility *= clamp((cameraPosition.y + 6.0) / 8.0, 0.0, 1.0);
	#endif

	#ifdef UNDERGROUND_SKY
	visibility *= mix(clamp((cameraPosition.y - 48.0) / 16.0, 0.0, 1.0), 1.0, eBS);
	#endif

	return aurora * visibility;
}
#endif
#endif