package game

import "core:math/rand"
import rl "vendor:raylib"

TILE_SIZE: i32 : 2

// 生存セルの割合
ALIVE_RATIO: f32 : 0.40
// 更新する間にはさむ時間(大きいほどゆっくり更新する)
INITIAL_DELAY: f32 : 0.15
// DELAYの最大値
MAX_DELAY: f32 : 0.25
// DELAYの最小値
MIN_DELAY: f32 : 0.05
// 加減算する時の値(それぞれ最大で4段階ずつ)
DELAY_VALUE: f32 : 0.025

GRID_X :: int(WINDOW_WIDTH / TILE_SIZE)
GRID_Y :: int(WINDOW_HEIGHT / TILE_SIZE - (BTN_HEIGHT / TILE_SIZE * 2))

State :: enum u8 {
	Dead  = 0,
	Alive = 1,
}

Game :: struct {
	grid:                              [GRID_Y][GRID_X]State,
	temp_grid:                         [GRID_Y][GRID_X]State,
	is_pause:                          bool,
	is_btn_pressed_and_should_refresh: bool,
	delay:                             f32,
	timer:                             f32,
	render_target:                     rl.RenderTexture2D,
	btn_randomize:                     Button,
	btn_pause_and_unpause:             Button,
	btn_speed_up:                      Button,
	btn_speed_down:                    Button,
	btn_rand_alive_color:              Button,
	btn_rand_dead_color:               Button,
	alive_color:                       rl.Color,
	dead_color:                        rl.Color,
}

randomize_grid :: proc(game: ^Game) {
	for y := 0; y < GRID_Y; y += 1 {
		for x := 0; x < GRID_X; x += 1 {
			game.grid[y][x] = (rand.float32_range(0, 1) < ALIVE_RATIO) ? .Alive : .Dead
		}
	}
}

count_neighbors :: #force_inline proc(grid: ^[GRID_Y][GRID_X]State, x: int, y: int) -> int {
	count := 0
	for dy := -1; dy <= 1; dy += 1 {
		for dx := -1; dx <= 1; dx += 1 {
			if dx == 0 && dy == 0 do continue

			nx := x + dx
			ny := y + dy

			if nx >= 0 && nx < GRID_X && ny >= 0 && ny < GRID_Y {
				if grid[ny][nx] == .Alive do count += 1
			}
		}
	}
	return count
}

update_grid :: proc(game: ^Game) {
	for y := 0; y < GRID_Y; y += 1 {
		for x := 0; x < GRID_X; x += 1 {
			neighbors := count_neighbors(&game.grid, x, y)
			current_state := game.grid[y][x]

			if current_state == .Alive {
				game.temp_grid[y][x] = (neighbors <= 1 || neighbors >= 4) ? .Dead : .Alive
			} else {
				game.temp_grid[y][x] = (neighbors == 3) ? .Alive : .Dead
			}
		}
	}
	// 次世代のデータを現在のデータにコピー
	for y := 0; y < GRID_Y; y += 1 {
		for x := 0; x < GRID_X; x += 1 {
			game.grid[y][x] = game.temp_grid[y][x]
		}
	}
}
