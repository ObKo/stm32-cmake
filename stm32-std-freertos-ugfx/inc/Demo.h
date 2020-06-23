/**
 * Function definitions for the main project file.
 *
 * @author: Jonathan Müller-Boruttau,
 * 			Tobias Fuchs tobias.fuchs@tum.de,
 * 			Nadja Peters nadja.peters@tum.de (RCS, TUM)
 */

#ifndef Demo_INCLUDED
#define Demo_INCLUDED

struct coord {
	uint8_t x;
	uint8_t y;
};

struct buttons {
    struct coord joystick;
    unsigned char A;
    unsigned char B;
    unsigned char C;
    unsigned char D;
    unsigned char E;
    unsigned char K;
};

#endif
