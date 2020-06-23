/*
 * Copyright (c) 2012, 2013, Joel Bodenmann aka Tectu <joel@unormal.org>
 * Copyright (c) 2012, 2013, Andrew Hannam aka inmarket
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * Neither the name of the <organization> nor the
 *      names of its contributors may be used to endorse or promote products
 *      derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _GFXCONF_H
#define _GFXCONF_H

/* The operating system to use. One of these must be defined - preferably in your Makefile */
//#define GFX_USE_OS_CHIBIOS	FALSE
//#define GFX_USE_OS_WIN32		FALSE
//#define GFX_USE_OS_LINUX		FALSE
//#define GFX_USE_OS_OSX		FALSE

#define GFX_OS_NO_INIT TRUE

/* GFX sub-systems to turn on */
#define GFX_USE_GDISP TRUE
#define GFX_USE_GWIN FALSE
#define GFX_USE_GEVENT FALSE
#define GFX_USE_GINPUT FALSE
#define GFX_USE_GTIMER FALSE

/* Features for the GDISP sub-system. */
#define GDISP_NEED_STARTUP_LOGO FALSE
#define GDISP_NEED_VALIDATION FALSE
#define GDISP_NEED_CLIP TRUE
#define GDISP_NEED_TEXT TRUE
#define GDISP_NEED_MULTITHREAD TRUE
#define GDISP_NEED_CIRCLE TRUE
#define GDISP_NEED_CONTROL TRUE

/* Builtin Fonts */
#define GDISP_INCLUDE_FONT_UI1 TRUE
#define GDISP_INCLUDE_FONT_UI2 TRUE

#define GDISP_DEFAULT_ORIENTATION GDISP_ROTATE_270

/* Features for the GWIN sub-system. */
#define GWIN_NEED_CONSOLE TRUE

/* Features for the GINPUT sub-system. */
#define GINPUT_NEED_MOUSE TRUE

/* Empty defines */
#define vTraceSetMutexName(a, b)
#define vTraceSetSemaphoreName(a, b)

#endif /* _GFXCONF_H */
