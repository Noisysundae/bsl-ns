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

        #define Bayer4(a)   (bayer(a, 1))
        #define Bayer8(a)   (bayer(a, 1))
        #define Bayer16(a)  (bayer(a, 2))
        #define Bayer32(a)  (bayer(a, 2))
        #define Bayer64(a)  (bayer(a, 3))
        #define Bayer128(a) (bayer(a, 3))
        #define Bayer256(a) (bayer(a, 4))   
    #else
        //Dithering from Jodie
        float Bayer2(vec2 a) {
            a = floor(a);
            return fract(dot(a, vec2(0.5, a.y * 0.75)));
        }

        #define Bayer4(a)   (Bayer2(  0.5 * (a)) * 0.25 + Bayer2(a))
        #define Bayer8(a)   (Bayer4(  0.5 * (a)) * 0.25 + Bayer2(a))
        #define Bayer16(a)  (Bayer8(  0.5 * (a)) * 0.25 + Bayer2(a))
        #define Bayer32(a)  (Bayer16( 0.5 * (a)) * 0.25 + Bayer2(a))
        #define Bayer64(a)  (Bayer32( 0.5 * (a)) * 0.25 + Bayer2(a))
        #define Bayer128(a) (Bayer64( 0.5 * (a)) * 0.25 + Bayer2(a))
        #define Bayer256(a) (Bayer128(0.5 * (a)) * 0.25 + Bayer2(a))
    #endif
#endif