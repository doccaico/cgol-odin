package game

import "core:fmt"
import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

WINDOW_TITLE :: "Simple CGOL"
WINDOW_WIDTH: i32 : 640
WINDOW_HEIGHT: i32 : 960

draw_grid :: proc(game: ^Game) {
	for y := 0; y < GRID_Y; y += 1 {
		for x := 0; x < GRID_X; x += 1 {
			rec := rl.Rectangle {
				x      = f32(x * int(TILE_SIZE)),
				y      = f32(y * int(TILE_SIZE)),
				width  = f32(TILE_SIZE),
				height = f32(TILE_SIZE),
			}
			if game.grid[y][x] == .Alive {
				rl.DrawRectangleRec(rec, game.alive_color)
			} else {
				rl.DrawRectangleRec(rec, game.dead_color)
			}
		}
	}
}

init_game :: proc(game: ^Game) {
	game.is_pause = true
	game.is_btn_pressed_and_should_refresh = false
	game.delay = INITIAL_DELAY
	game.timer = 0.0
	game.alive_color = rl.GREEN
	game.dead_color = rl.BLACK
	// game.render_target = rl.LoadRenderTexture(i32(GRID_X) * TILE_SIZE, i32(GRID_Y) * TILE_SIZE)
	game.render_target = rl.LoadRenderTexture(WINDOW_WIDTH, WINDOW_HEIGHT)

	ui_init(game)
	randomize_grid(game)

	rl.BeginTextureMode(game.render_target)
	draw_grid(game)
	draw_ui(game)
	rl.EndTextureMode()
}

game_deinit :: proc(game: ^Game) {
	rl.UnloadRenderTexture(game.render_target)
}

run: bool
game: Game

init :: proc() {
	run = true

	when ODIN_OS == .JS {
		rl.SetConfigFlags({.VSYNC_HINT})
	} else {
		rl.SetTargetFPS(60)
	}
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE)
	init_game(&game)
}

shutdown :: proc() {
	when ODIN_OS != .JS {
		game_deinit(&game)
	}
	rl.CloseWindow()
}

update :: proc() {
	input_handling(&game)

	dt := rl.GetFrameTime()
	should_refresh := false

	if !game.is_pause {
		game.timer += dt
		if game.timer >= game.delay {
			game.timer = 0.0
			should_refresh = true
		}
	}

	if should_refresh || game.is_btn_pressed_and_should_refresh {
		if game.is_btn_pressed_and_should_refresh do game.is_btn_pressed_and_should_refresh = false

		rl.BeginTextureMode(game.render_target)

		// 時間経過による自動更新のときだけ、世代を進める
		if should_refresh {
			update_grid(&game)
		}

		draw_grid(&game)
		draw_ui(&game)

		rl.EndTextureMode()
	}

	rl.BeginDrawing()
	rl.ClearBackground(BTN_BG_COLOR)

	src_rec := rl.Rectangle {
		0,
		0,
		f32(game.render_target.texture.width),
		f32(-game.render_target.texture.height),
	}
	dest_rec := rl.Rectangle{0, 0, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)}
	origin := rl.Vector2{0, 0}
	rl.DrawTexturePro(game.render_target.texture, src_rec, dest_rec, origin, 0.0, rl.WHITE)

	rl.EndDrawing()
}

should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			run = false
		}
	}

	return run
}

parent_window_size_changed :: proc(w, h: int) {
	// rl.SetWindowSize(c.int(w), c.int(h))
}
