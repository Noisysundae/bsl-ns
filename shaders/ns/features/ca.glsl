#ifndef NS_CA_FEATURE_INCLUDED
	#define NS_CA_FEATURE_INCLUDED

	#include "/ns/configs/ca.glsl"
	#include "/ns/utils/math.glsl"

	#ifdef NS_CA_ENABLED
		uniform float
			nsSmoothedTemperature,
			nsSmoothedRainfall;

		float nsBaseCaFactor =
			pow(1 / (1 + abs(nsSmoothedTemperature - 0.5)), 2)
				* NS_CA_TEMPERATURE_WEIGHT * 2 - NS_CA_TEMPERATURE_WEIGHT
			+ (1 - nsSmoothedRainfall)
				* NS_CA_RAINFALL_WEIGHT * 2 - NS_CA_RAINFALL_WEIGHT
			;

		float getCaFactor(float altitude, float rainFactor, float thunderFactor, float skyLight) {
			float altitudeFactor = nClamp(altitude, 64, 160) * NS_CA_ALTITUDE_WEIGHT;
			return max(
				1
					+ nsBaseCaFactor
					+ altitudeFactor * altitudeFactor * 6
					+ rainFactor * NS_CA_WEATHER_WEIGHT * 2.5
					+ thunderFactor * NS_CA_WEATHER_WEIGHT * 5
				, 0)
				* clamp(pow(skyLight / 240.0, 2), 1 - pow(NS_CA_INDOOR_WEIGHT, 0.05), 1.0);
		}

	#else
		float getCaFactor (float altitude, float rainFactor, float thunderFactor, float skyLight) {
			return 1.0;
		}
	#endif
#endif