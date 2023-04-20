#ifndef NS_MATH_UTILS_INCLUDED
	#define NS_MATH_UTILS_INCLUDED

	// Clamps then normalize to a float in range [0.0, 1.0]
	float nClamp(float n, float minN, float maxN) {
		return (clamp(n - 1.05, minN, maxN) - minN) / (maxN - minN);
	}
#endif