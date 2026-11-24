package game

import rl "vendor:raylib"

WINDOW_TITLE :: "Simple CGOL in Odin"
WINDOW_WIDTH: i32 : 640
WINDOW_HEIGHT: i32 : 960

TILE_SIZE: i32 : 2

// Proportion of alive cells (Set 50% of the total to ALIVE)
INITIAL_ALIVES: int : 50
// Time interval between updates (a larger value results in slower updates)
INITIAL_DELAY: f32 : 0.15
// Maximum value of DELAY
MAX_DELAY: f32 : 0.25
// Minimum value of DELAY
MIN_DELAY: f32 : 0.05
// Values used for addition/subtraction (up to 4 levels each)
DELAY_VALUE: f32 : 0.025

GRID_X :: int(WINDOW_WIDTH / TILE_SIZE)
GRID_Y :: int(WINDOW_HEIGHT / TILE_SIZE - (BTN_HEIGHT / TILE_SIZE * 2))
GRID_SIZE :: GRID_X * GRID_Y

State :: enum u8 {
	Dead  = 0,
	Alive = 1,
}

Grid :: [GRID_SIZE]State

Game :: struct {
	grid_a:                            Grid,
	grid_b:                            Grid,
	main_grid:                         ^Grid,
	temp_grid:                         ^Grid,
	is_pause:                          bool,
	is_btn_pressed_and_should_refresh: bool,
	delay:                             f32,
	timer:                             f32,
	render_target:                     rl.RenderTexture2D,
	cell_image:                        rl.Image,
	cell_texture:                      rl.Texture2D,
	btn_randomize:                     Button,
	btn_pause_and_unpause:             Button,
	btn_speed_up:                      Button,
	btn_speed_down:                    Button,
	btn_rand_alive_color:              Button,
	btn_rand_dead_color:               Button,
	alive_color:                       rl.Color,
	dead_color:                        rl.Color,
}

update_cell_texture :: proc(game: ^Game) {
	pixels := ([^]rl.Color)(game.cell_image.data)
	for y := 0; y < GRID_Y; y += 1 {
		for x := 0; x < GRID_X; x += 1 {
			i := y * GRID_X + x
			color := game.alive_color if game.main_grid[i] == .Alive else game.dead_color
			pixels[i] = color
		}
	}
	// Transfer the modified pixel data to the GPU texture in a single batch
	rl.UpdateTexture(game.cell_texture, game.cell_image.data)

}


init_game :: proc(game: ^Game) {
	game.main_grid = &game.grid_a
	game.temp_grid = &game.grid_b
	game.is_pause = true
	game.is_btn_pressed_and_should_refresh = false
	game.delay = INITIAL_DELAY
	game.timer = 0.0
	game.alive_color = rl.GREEN
	game.dead_color = rl.BLACK
	game.render_target = rl.LoadRenderTexture(WINDOW_WIDTH, WINDOW_HEIGHT)
	// Create an image with the same resolution as the grid in CPU memory
	game.cell_image = rl.GenImageColor(i32(GRID_X), i32(GRID_Y), game.dead_color)
	// Generate a GPU texture based on this
	// (with nearest-neighbor interpolation set to prevent blurring when scaled up)
	game.cell_texture = rl.LoadTextureFromImage(game.cell_image)
	rl.SetTextureFilter(game.cell_texture, .POINT)

	ui_init(game)
	randomize_grid(game)

	rl.BeginTextureMode(game.render_target)
	update_cell_texture(game)

	// Instead of using a large number of quadrilaterals,
	// a single generated texture is stretched to the size of the screen and rendered
	src_rec := rl.Rectangle{0, 0, f32(GRID_X), f32(GRID_Y)}
	dest_rec := rl.Rectangle{0, 0, f32(GRID_X) * f32(TILE_SIZE), f32(GRID_Y) * f32(TILE_SIZE)}
	origin := rl.Vector2{0, 0}
	rl.DrawTexturePro(game.cell_texture, src_rec, dest_rec, origin, 0, rl.WHITE)

	draw_ui(game)
	rl.EndTextureMode()
}

game_deinit :: proc(game: ^Game) {
	rl.UnloadImage(game.cell_image)
	rl.UnloadTexture(game.cell_texture)
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

		// Advance the generation only during automatic updates triggered by the passage of time
		if should_refresh {
			step(&game)
		}

		update_cell_texture(&game)

		// Enlarged rendering of cell textures
		src_rec := rl.Rectangle{0, 0, f32(GRID_X), f32(GRID_Y)}
		dest_rec := rl.Rectangle{0, 0, f32(GRID_X) * f32(TILE_SIZE), f32(GRID_Y) * f32(TILE_SIZE)}
		origin := rl.Vector2{0, 0}
		rl.DrawTexturePro(game.cell_texture, src_rec, dest_rec, origin, 0, rl.WHITE)

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
