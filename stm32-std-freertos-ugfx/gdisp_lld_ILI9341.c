/*
 * This file is subject to the terms of the GFX License. If a copy of
 * the license was not distributed with this file, you can obtain one at:
 *
 *              http://ugfx.org/license.html
 */

/**
 * @file    drivers/gdisp/ILI9341/gdisp_lld.c
 * @brief   GDISP Graphics Driver subsystem low level driver source for
 * 			the ILI9341 and compatible HVGA display
 */

#include "gfx.h"

#if GFX_USE_GDISP

#if defined(GDISP_SCREEN_HEIGHT)
	#warning "GDISP: This low level driver does not support setting a screen size. It is being ignored."
	#undef GISP_SCREEN_HEIGHT
#endif
#if defined(GDISP_SCREEN_WIDTH)
	#warning "GDISP: This low level driver does not support setting a screen size. It is being ignored."
	#undef GDISP_SCREEN_WIDTH
#endif

#define GDISP_DRIVER_VMT			GDISPVMT_STM32LTDC
#include "gdisp_lld_config.h"
#include "src/gdisp/gdisp_driver.h"
#include "stm32f429i_discovery_lcd.h"

/*===========================================================================*/
/* Driver local definitions.                                                 */
/*===========================================================================*/

#ifndef GDISP_SCREEN_HEIGHT
	#define GDISP_SCREEN_HEIGHT		240
#endif
#ifndef GDISP_SCREEN_WIDTH
	#define GDISP_SCREEN_WIDTH		320
#endif
#ifndef GDISP_INITIAL_CONTRAST
	#define GDISP_INITIAL_CONTRAST	50
#endif
#ifndef GDISP_INITIAL_BACKLIGHT
	#define GDISP_INITIAL_BACKLIGHT	100
#endif

#include "drivers/gdisp/ILI9341/ILI9341.h"

/*===========================================================================*/
/* Driver local functions.                                                   */
/*===========================================================================*/
static inline void init_board(GDisplay *g) {
	g->board = 0;

	/* Init LCD and LTCD. Enable layer1 only. */
	LCD_Init();
	LCD_LayerInit();
	LTDC_LayerCmd(LTDC_Layer1, ENABLE);
	LTDC_LayerCmd(LTDC_Layer2, ENABLE);
	LTDC_ReloadConfig(LTDC_IMReload);
	LTDC_Cmd(ENABLE);
	LCD_SetLayer(LCD_BACKGROUND_LAYER);
}

static inline void set_backlight(GDisplay *g, uint8_t percent) {
	(void) g;
	uint16_t i = (percent * 0xFF) / 100;
	LCD_SetTransparency((uint8_t)i);
}

/*===========================================================================*/
/* Driver exported functions.                                                */
/*===========================================================================*/

LLDSPEC bool_t gdisp_lld_init(GDisplay *g) {
	// No private area for this controller
	g->priv = 0;

	// Initialise the board interface
	init_board(g);

	/* Turn on the back-light */
	set_backlight(g, GDISP_INITIAL_BACKLIGHT);

	/* Initialise the GDISP structure */
	g->g.Width = GDISP_SCREEN_WIDTH;
	g->g.Height = GDISP_SCREEN_HEIGHT;
	g->g.Orientation = GDISP_ROTATE_90;
	g->g.Powermode = powerOn;
	g->g.Backlight = GDISP_INITIAL_BACKLIGHT;
	g->g.Contrast = GDISP_INITIAL_CONTRAST;
	return TRUE;
}

#if GDISP_HARDWARE_DRAWPIXEL
LLDSPEC void gdisp_lld_draw_pixel(GDisplay *g) {
	coord_t		x, y;

	switch(g->g.Orientation) {
	default:
	case GDISP_ROTATE_0:
		x = g->p.x;
		y = g->p.y;
		break;
	case GDISP_ROTATE_90:
		x = g->p.y;
		y = GDISP_SCREEN_WIDTH-1 - g->p.x;
		break;
	case GDISP_ROTATE_180:
		x = GDISP_SCREEN_WIDTH-1 - g->p.x;
		y = GDISP_SCREEN_HEIGHT-1 - g->p.y;
		break;
	case GDISP_ROTATE_270:
		x = GDISP_SCREEN_HEIGHT-1 - g->p.y;
		y = g->p.x;
		break;
	}
	LCD_SetTextColor(g->p.color);
	LCD_DrawLine(x, y, 1, LCD_DIR_HORIZONTAL);
}
#endif

#if GDISP_HARDWARE_FILLS
LLDSPEC void gdisp_lld_fill_area(GDisplay *g) {
	LCD_SetTextColor(g->p.color);

	coord_t		x, y, cx, cy;

	switch(g->g.Orientation) {
	default:
	case GDISP_ROTATE_0:
		x = g->p.x;
		y = g->p.y;
		cx = g->p.cx;
		cy = g->p.cy;
		break;
	case GDISP_ROTATE_90:
		x = g->p.y;
		y = GDISP_SCREEN_WIDTH-1 - g->p.x - g->p.cx + 1;
		cy = g->p.cx;
		cx = g->p.cy;
		break;
	case GDISP_ROTATE_180:
		x = GDISP_SCREEN_WIDTH-1 - g->p.x;
		y = GDISP_SCREEN_HEIGHT-1 - g->p.y;
		cx = g->p.cx;
		cy = g->p.cy;
		break;
	case GDISP_ROTATE_270:
		x = GDISP_SCREEN_HEIGHT-1 - g->p.y;
		y = g->p.x;
		cy = g->p.cx;
		cx = g->p.cy;
		break;
	}

	LCD_DrawFullRect(x, y, cx, cy);
}
#endif

#if GDISP_HARDWARE_CLEARS
LLDSPEC	void gdisp_lld_clear(GDisplay *g) {
	//LCD_Clear(g->p.color);
	LCD_SetTextColor(g->p.color);
	LCD_DrawFullRect(0,0,240,320);
}
#endif

#endif /* GFX_USE_GDISP */
