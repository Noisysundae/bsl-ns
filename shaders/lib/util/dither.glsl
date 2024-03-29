#ifndef DITHER_INCLUDED
    #define DITHER_INCLUDED

    #include "/ns/configs/main.glsl"
    #include "/ns/features/dithering.glsl"

    #ifdef NS_DITHERING_ENABLED
        #ifdef NS_DITHERING_BSL_BAYER_OVERRIDE
            #define BSL_BAYER_OVERRIDE
        #endif
    #endif

    #ifdef BSL_BAYER_OVERRIDE
        #undef BSL_BAYER_OVERRIDE

        #define Bayer4(a) (bayer(a, 2))
        #define Bayer8(a) (bayer(a, 3))   
    #else
        //Dithering from Jodie
        float Bayer2(vec2 a) {
            a = floor(a);
            return fract(a.x * 0.5 + a.y * 0.75);
        }

        #define Bayer4(a) (Bayer2(a * 0.5) * 0.25 + Bayer2(a))
        #define Bayer8(a) (Bayer4(a * 0.5) * 0.25 + Bayer2(a))
    #endif
#endif
