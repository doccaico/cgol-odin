package game

import "core:math/rand"

randomize_grid :: proc(game: ^Game) {
	alive_count := GRID_SIZE * INITIAL_ALIVES / 100
	for i := 0; i < alive_count; i += 1 {
		game.main_grid[i] = .Alive
	}
	for i := alive_count; i < GRID_SIZE; i += 1 {
		game.main_grid[i] = .Dead
	}
	rand.shuffle(game.main_grid[:])
}

count_neighbors :: #force_inline proc(game: ^Game, x: int, y: int) -> int {
	count := 0
	for dy := -1; dy <= 1; dy += 1 {
		for dx := -1; dx <= 1; dx += 1 {
			if dx == 0 && dy == 0 {
				continue
			}

			nx := x + dx
			ny := y + dy

			if nx >= 0 && nx < GRID_X && ny >= 0 && ny < GRID_Y {
				i := ny * GRID_X + nx
				if game.main_grid[i] == .Alive {
					count += 1
				}
			}
		}
	}
	return count
}

step :: proc(game: ^Game) {
	for y := 0; y < GRID_Y; y += 1 {
		for x := 0; x < GRID_X; x += 1 {
			neighbors := count_neighbors(game, x, y)
			i := y * GRID_X + x
			current_state := game.main_grid[i]

			game.temp_grid[i] =
				.Alive if neighbors == 3 || (current_state == .Alive && neighbors == 2) else .Dead
		}
	}
	// Swap only the pointer addresses in O(1) time (avoiding a full copy of all elements)
	game.main_grid, game.temp_grid = game.temp_grid, game.main_grid
}
