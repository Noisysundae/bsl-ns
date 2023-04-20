#ifndef NS_DITHERING_FEATURE_INCLUDED
	#define NS_DITHERING_FEATURE_INCLUDED

	#include "/ns/configs/dithering.glsl"

	float bayer(vec2 coord, int bayerExp, float scale) {
		#ifdef NS_DITHERING_ENABLED
			ivec2 pos = ivec2(floor(coord / scale));
			int size = 4 << (bayerExp - 1 << 1);
			float value = 0.0;

			// --- 2x2 Bayer Pattern ---
			// 0 2
			// 3 1
			// ---
			// Each iteration in the loop adds a value
			// based on the 2x2 pattern, transformed `coord`, and a pattern density factor.
			//
			// For example, on a 4x4 `coord` with `bayerExp` of 2,
			// the values to add from each iteration are as follow...
			//
			// #0
			//
			// 0   8   0   8
			// 12  4   12  4
			// 0   8   0   8
			// 12  4   12  4
			//
			// #1
			//
			// 0   0   2   2
			// 0   0   2   2
			// 3   3   1   1
			// 3   3   1   1

			for (int i = 0; i < bayerExp; i++) {
				ivec2 t = pos >> i & 1;
				value += (4 - ((t.x << 1) + t.y) & 3)
					<< (bayerExp - i - 1 << 1);
			}

			return value / size;
		#else
			return 1.0;
		#endif
	}

	float bayer(vec2 pos, int bayerExp) {
		return bayer(pos, bayerExp, NS_DITHERING_BAYER_SCALE);
	}
	
	float bayer(vec2 pos) {
		return bayer(pos, NS_DITHERING_BAYER_EXPONENT, NS_DITHERING_BAYER_SCALE);
	}
#endif