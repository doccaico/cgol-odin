package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

is_btn_pressed :: proc(game: ^Game, btn: Button_Kind) -> bool {
	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		bounds: rl.Rectangle
		switch btn {
		case .Randomize:
			bounds = game.btn_randomize.bounds
		case .Pause_And_Unpause:
			bounds = game.btn_pause_and_unpause.bounds
		case .Speed_Up:
			bounds = game.btn_speed_up.bounds
		case .Speed_Down:
			bounds = game.btn_speed_down.bounds
		case .Rand_Alive_Color:
			bounds = game.btn_rand_alive_color.bounds
		case .Rand_Dead_Color:
			bounds = game.btn_rand_dead_color.bounds
		}
		mouse_pos := rl.GetMousePosition()
		if rl.CheckCollisionPointRec(mouse_pos, bounds) {
			return true
		}
	}
	return false
}

input_handling :: proc(game: ^Game) {
	if rl.IsKeyPressed(.R) || is_btn_pressed(game, .Randomize) {
		game.is_btn_pressed_and_should_refresh = true
		randomize_grid(game)
	}
	if rl.IsKeyPressed(.P) || is_btn_pressed(game, .Pause_And_Unpause) {
		game.is_pause = !game.is_pause
	}
	if rl.IsKeyPressed(.W) || is_btn_pressed(game, .Speed_Up) {
		game.delay = math.max(MIN_DELAY, game.delay - DELAY_VALUE)
	}
	if rl.IsKeyPressed(.S) || is_btn_pressed(game, .Speed_Down) {
		game.delay = math.min(MAX_DELAY, game.delay + DELAY_VALUE)
	}
	if rl.IsKeyPressed(.A) || is_btn_pressed(game, .Rand_Alive_Color) {
		game.is_btn_pressed_and_should_refresh = true

		color: rl.Color
		color[0] = u8(rl.GetRandomValue(0, 255))
		color[1] = u8(rl.GetRandomValue(0, 255))
		color[2] = u8(rl.GetRandomValue(0, 255))
		color[3] = 255
		game.alive_color = color
	}
	if rl.IsKeyPressed(.D) || is_btn_pressed(game, .Rand_Dead_Color) {
		game.is_btn_pressed_and_should_refresh = true

		color: rl.Color
		color[0] = u8(rl.GetRandomValue(0, 255))
		color[1] = u8(rl.GetRandomValue(0, 255))
		color[2] = u8(rl.GetRandomValue(0, 255))
		color[3] = 255
		game.dead_color = color
	}
}
