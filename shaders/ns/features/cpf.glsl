#ifndef NS_CPF_FEATURE_INCLUDED
	#define NS_CPF_FEATURE_INCLUDED

	uniform bool firstPersonCamera;

	varying float cpfDistance;

	#ifdef FSH
		#include "/lib/util/dither.glsl"
		#include "/ns/configs/cpf.glsl"
		#include "/ns/configs/dithering.glsl"
		#include "/ns/features/dithering.glsl"
		#include "/ns/utils/math.glsl"

		float getPf(bool backfaceCulling) {
			if (backfaceCulling && !gl_FrontFacing) {
				discard;
			}

			#ifdef NS_CPF_ENABLED
				float threshold = firstPersonCamera ? NS_CPF_DIST_THRESHOLD_FIRST_PERSON : NS_CPF_DIST_THRESHOLD_THIRD_PERSON;

				return float(
					nClamp(1 / gl_FragCoord.w, NS_CPF_OFFSET, threshold + NS_CPF_OFFSET)
					#ifdef NS_DITHERING_ENABLED
						> bayer(gl_FragCoord.xy, NS_DITHERING_BAYER_EXPONENT, NS_DITHERING_BAYER_SCALE)
					#else
						> Bayer64(gl_FragCoord.xy)
					#endif
				);
			#else
				return 1.0;
			#endif
		}

		float getPf() { return getPf(false); }
	#endif
#endif