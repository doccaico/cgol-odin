package game

import "core:fmt"
import "core:slice"
import rl "vendor:raylib"

BTN_WIDTH: i32 : WINDOW_WIDTH / 3
BTN_HEIGHT: i32 : 80
BTN_SPAN: i32 : 4
BTN_FONT_SIZE: i32 : 18

BTN_AREA_X: i32 : 0
BTN_AREA_Y: i32 : WINDOW_HEIGHT - (BTN_HEIGHT * 2)

BTN_BG_COLOR: rl.Color : {30, 30, 45, 255}
BTN_LINE_COLOR: rl.Color : rl.GRAY
BTN_TEXT_COLOR: rl.Color : rl.WHITE

Button_Kind :: enum {
	Randomize,
	Pause_And_Unpause,
	Rand_Alive_Color,
	Rand_Dead_Color,
	Speed_Up,
	Speed_Down,
}

Button :: struct {
	bounds:     rl.Rectangle,
	text_str:   cstring,
	text_width: i32,
}

ui_init :: proc(game: ^Game) {
	SPACE: i32 : 4
	{
		str: cstring : "(R)Randomize"
		game.btn_randomize = {
			bounds     = {
				f32(BTN_AREA_X + SPACE),
				f32(BTN_AREA_Y + SPACE),
				f32(BTN_WIDTH - SPACE * 2),
				f32((WINDOW_HEIGHT - BTN_AREA_Y) / 2 - SPACE * 2),
			},
			text_str   = str,
			text_width = rl.MeasureText(str, BTN_FONT_SIZE),
		}
	}
	{
		str: cstring : "(P)Pause/Unpause"
		game.btn_pause_and_unpause = {
			bounds     = {
				f32(BTN_AREA_X + SPACE),
				f32(BTN_AREA_Y + BTN_HEIGHT + SPACE),
				f32(BTN_WIDTH - SPACE * 2),
				f32((WINDOW_HEIGHT - BTN_AREA_Y) / 2 - SPACE * 2),
			},
			text_str   = str,
			text_width = rl.MeasureText(str, BTN_FONT_SIZE),
		}
	}
	{
		str: cstring : "(W)Speed Up"
		game.btn_speed_up = {
			bounds     = {
				f32(BTN_AREA_X + BTN_WIDTH * 1 + SPACE),
				f32(BTN_AREA_Y + SPACE),
				f32(BTN_WIDTH - SPACE * 2),
				f32((WINDOW_HEIGHT - BTN_AREA_Y) / 2 - SPACE * 2),
			},
			text_str   = str,
			text_width = rl.MeasureText(str, BTN_FONT_SIZE),
		}
	}
	{
		str: cstring : "(S)Speed Down"
		game.btn_speed_down = {
			bounds     = {
				f32(BTN_AREA_X + BTN_WIDTH * 1 + SPACE),
				f32(BTN_AREA_Y + BTN_HEIGHT + SPACE),
				f32(BTN_WIDTH - SPACE * 2),
				f32((WINDOW_HEIGHT - BTN_AREA_Y) / 2 - SPACE * 2),
			},
			text_str   = str,
			text_width = rl.MeasureText(str, BTN_FONT_SIZE),
		}
	}
	{
		str: cstring : "(A)Rand ALIVE Color"
		game.btn_rand_alive_color = {
			bounds     = {
				f32(BTN_AREA_X + BTN_WIDTH * 2 + SPACE),
				f32(BTN_AREA_Y + SPACE),
				f32(BTN_WIDTH - SPACE * 2),
				f32((WINDOW_HEIGHT - BTN_AREA_Y) / 2 - SPACE * 2),
			},
			text_str   = str,
			text_width = rl.MeasureText(str, BTN_FONT_SIZE),
		}
	}
	{
		str: cstring : "(D)Rand DEAD Color"
		game.btn_rand_dead_color = {
			bounds     = {
				f32(BTN_AREA_X + BTN_WIDTH * 2 + SPACE),
				f32(BTN_AREA_Y + BTN_HEIGHT + SPACE),
				f32(BTN_WIDTH - SPACE * 2),
				f32((WINDOW_HEIGHT - BTN_AREA_Y) / 2 - SPACE * 2),
			},
			text_str   = str,
			text_width = rl.MeasureText(str, BTN_FONT_SIZE),
		}
	}
}

draw_ui :: proc(game: ^Game) {
	SPACE: i32 : 26
	// Randomize
	{
		x, y := i32(game.btn_randomize.bounds.x), i32(game.btn_randomize.bounds.y)
		width, height :=
			i32(game.btn_randomize.bounds.width), i32(game.btn_randomize.bounds.height)
		text_width := game.btn_randomize.text_width
		rl.DrawRectangleLinesEx(game.btn_randomize.bounds, 2, BTN_LINE_COLOR)
		rl.DrawText(
			game.btn_randomize.text_str,
			(width - text_width) / 2,
			y + SPACE,
			BTN_FONT_SIZE,
			BTN_TEXT_COLOR,
		)
	}
	// Pause/Unpause
	{
		x, y := i32(game.btn_pause_and_unpause.bounds.x), i32(game.btn_pause_and_unpause.bounds.y)
		width, height :=
			i32(game.btn_pause_and_unpause.bounds.width),
			i32(game.btn_pause_and_unpause.bounds.height)
		text_width := game.btn_pause_and_unpause.text_width
		rl.DrawRectangleLinesEx(game.btn_pause_and_unpause.bounds, 2, BTN_LINE_COLOR)
		rl.DrawText(
			game.btn_pause_and_unpause.text_str,
			(width - text_width) / 2,
			y + SPACE,
			BTN_FONT_SIZE,
			BTN_TEXT_COLOR,
		)
	}
	// Speed Up
	{
		x, y := i32(game.btn_speed_up.bounds.x), i32(game.btn_speed_up.bounds.y)
		width, height := i32(game.btn_speed_up.bounds.width), i32(game.btn_speed_up.bounds.height)
		text_width := game.btn_speed_up.text_width
		rl.DrawRectangleLinesEx(game.btn_speed_up.bounds, 2, BTN_LINE_COLOR)
		rl.DrawText(
			game.btn_speed_up.text_str,
			(BTN_WIDTH * 1) + (width - text_width) / 2,
			y + SPACE,
			BTN_FONT_SIZE,
			BTN_TEXT_COLOR,
		)
	}
	// Speed Down
	{
		x, y := i32(game.btn_speed_down.bounds.x), i32(game.btn_speed_down.bounds.y)
		width, height :=
			i32(game.btn_speed_down.bounds.width), i32(game.btn_speed_down.bounds.height)
		text_width := game.btn_speed_down.text_width
		rl.DrawRectangleLinesEx(game.btn_speed_down.bounds, 2, BTN_LINE_COLOR)
		rl.DrawText(
			game.btn_speed_down.text_str,
			(BTN_WIDTH * 1) + (width - text_width) / 2,
			y + SPACE,
			BTN_FONT_SIZE,
			BTN_TEXT_COLOR,
		)
	}
	// Rand ALIVE Color
	{
		x, y := i32(game.btn_rand_alive_color.bounds.x), i32(game.btn_rand_alive_color.bounds.y)
		width, height :=
			i32(game.btn_rand_alive_color.bounds.width),
			i32(game.btn_rand_alive_color.bounds.height)
		text_width := game.btn_rand_alive_color.text_width
		rl.DrawRectangleLinesEx(game.btn_rand_alive_color.bounds, 2, BTN_LINE_COLOR)
		rl.DrawText(
			game.btn_rand_alive_color.text_str,
			(BTN_WIDTH * 2) + (width - text_width) / 2,
			y + SPACE,
			BTN_FONT_SIZE,
			BTN_TEXT_COLOR,
		)
	}
	// Rand DEAD Color
	{
		x, y := i32(game.btn_rand_dead_color.bounds.x), i32(game.btn_rand_dead_color.bounds.y)
		width, height :=
			i32(game.btn_rand_dead_color.bounds.width), i32(game.btn_rand_dead_color.bounds.height)
		text_width := game.btn_rand_dead_color.text_width
		rl.DrawRectangleLinesEx(game.btn_rand_dead_color.bounds, 2, BTN_LINE_COLOR)
		rl.DrawText(
			game.btn_rand_dead_color.text_str,
			(BTN_WIDTH * 2) + (width - text_width) / 2,
			y + SPACE,
			BTN_FONT_SIZE,
			BTN_TEXT_COLOR,
		)
	}
}
