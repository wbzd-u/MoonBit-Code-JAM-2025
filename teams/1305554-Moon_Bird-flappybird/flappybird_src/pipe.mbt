// ==================== 管道控制 ====================

///|
pub fn setpipe(state : State, _pos : Position) -> Unit {
  // 计算本帧应移动的像素（使用千分位缩放的亚像素累计，带线性加速）
  let mut speed_scaled = state.pipe_speed * 1000
  if state.game_mode == Classic && state.classic_ramp_ticks > 0 {
    let total = 120
    let mut elapsed = total - state.classic_ramp_ticks
    if elapsed < 0 {
      elapsed = 0
    }
    if elapsed > total {
      elapsed = total
    }
    let mut has_speed_boost = false
    for i = 0; i < state.active_effects.length(); i = i + 1 {
      let effect = state.active_effects[i]
      if effect.item_type == Hard && effect.remaining_time > 0 {
        has_speed_boost = true
        break
      }
    }
    let target = if has_speed_boost { 3 } else { 2 }
    // 线性：1 -> target（千分位缩放）
    speed_scaled = 1000 + (target - 1) * 1000 * elapsed / total
  }
  state.pipe_move_accum = state.pipe_move_accum + speed_scaled
  let displacement = state.pipe_move_accum / 1000
  state.pipe_move_accum = state.pipe_move_accum % 1000
  // 存储当前帧的位移值，供道具使用
  state.current_displacement = displacement

  // 移动所有现有管道
  if displacement > 0 {
    for i = 0; i < state.pipes.length(); i = i + 1 {
      let pipe = state.pipes[i]
      pipe.x = pipe.x - displacement
    }
  }

  // 移除已经离开屏幕的管道
  state.pipes = state.pipes.filter(fn(pipe) {
    let top_pipe_right = pipe.x + 20
    let bottom_pipe_right = pipe.x + pipe.rand + 20
    let rightmost_pipe = if top_pipe_right > bottom_pipe_right {
      top_pipe_right
    } else {
      bottom_pipe_right
    }
    rightmost_pipe > -20
  })
  if state.pipes.length() > 0 {
    // 找到最左边的管道
    let mut leftmost_pipe = state.pipes[0]
    let mut leftmost_index = 0
    let mut leftmost_x = leftmost_pipe.x
    for i = 1; i < state.pipes.length(); i = i + 1 {
      let pipe = state.pipes[i]
      let pipe_left = if pipe.rand < 0 { pipe.x + pipe.rand } else { pipe.x }
      let current_leftmost = if leftmost_pipe.rand < 0 {
        leftmost_pipe.x + leftmost_pipe.rand
      } else {
        leftmost_pipe.x
      }
      if pipe_left < current_leftmost {
        leftmost_pipe = pipe
        leftmost_x = pipe_left
        leftmost_index = i
      }
    }

    // 动态调整生成距离（极速模式略微紧凑，并按速度归一化）
    let mut generation_distance = 80
    match state.game_mode {
      Hard =>
        if state.score < 5 {
          generation_distance = 110
        } else if state.score < 15 {
          generation_distance = 90
        } else if state.score < 30 {
          generation_distance = 70
        } else {
          generation_distance = 60
        }
      Classic =>
        if state.score < 10 {
          generation_distance = 80
        } else {
          generation_distance = 70
        }
      Rush => {
        // 极速模式：根据通过的管道数逐渐增加密度
        if state.total_pipes_passed < 10 {
          generation_distance = 100
        } else if state.total_pipes_passed < 20 {
          generation_distance = 90
        } else if state.total_pipes_passed < 30 {
          generation_distance = 80
        } else {
          generation_distance = 70
        }
        // 按速度归一化
        if state.pipe_speed > 1 {
          generation_distance = generation_distance * state.pipe_speed / 2
        }
      }
      _ => generation_distance = if state.pipe_speed > 1 { 120 } else { 80 }
    }
    if state.game_mode != Rush && state.pipe_speed > 1 {
      generation_distance = generation_distance * state.pipe_speed / 2
    }
    if leftmost_x <= generation_distance && !leftmost_pipe.next_pipe_generated {
      create_new_pipe(state)
      state.pipes[leftmost_index].next_pipe_generated = true
    }
  } else if state.game_started {
    create_new_pipe(state)
  }
}

///|
pub fn create_new_pipe(state : State) -> Unit {
  let h = random_range_inclusive(20, 100, state)
  let rand = random_range_inclusive(-20, 20, state)
  let mut randgap = 30
  if state.score >= 0 && state.score <= 4 {
    randgap = random_range_inclusive(30, 34, state)
  } else if state.score >= 5 && state.score <= 10 {
    randgap = random_range_inclusive(25, 29, state)
  } else if state.score > 10 {
    randgap = random_range_inclusive(22, 25, state)
  }

  // 动态调整管道间距
  let mut final_spacing = 100
  match state.game_mode {
    Hard =>
      if state.score < 5 {
        final_spacing = 110
      } else if state.score < 15 {
        final_spacing = 90
      } else if state.score < 30 {
        final_spacing = 75
      } else {
        final_spacing = 65
      }
    Classic => final_spacing = 100
    Rush =>
      // 极速模式：根据通过的管道数逐渐增加密度
      if state.total_pipes_passed < 10 {
        final_spacing = 95
      } else if state.total_pipes_passed < 20 {
        final_spacing = 90
      } else if state.total_pipes_passed < 30 {
        final_spacing = 85
      } else {
        final_spacing = 80
      }
    _ => final_spacing = 100
  }

  // 计算新管道的起始位置
  let new_x = if state.pipes.length() > 0 {
    let mut rightmost_x = 0
    for i = 0; i < state.pipes.length(); i = i + 1 {
      let pipe = state.pipes[i]
      let pipe_right = if pipe.rand > 0 {
        pipe.x + pipe.rand + 20
      } else {
        pipe.x + 20
      }
      if pipe_right > rightmost_x {
        rightmost_x = pipe_right
      }
    }
    rightmost_x + final_spacing
  } else {
    160
  }
  let adjusted_x = if rand < 0 { new_x - rand } else { new_x }
  let new_pipe = {
    x: adjusted_x,
    y: 0,
    h,
    rand,
    randgap,
    scored: false,
    next_pipe_generated: false,
  }
  state.pipes.push(new_pipe)

  // 生成道具：
  // - Rush（极速）模式：降低为约45%概率生成道具，最多2个
  // - 其他模式：30% 概率生成1个道具；Timed 模式不生成
  let should_spawn_items = state.game_mode != Timed &&
    (
      (state.game_mode == Rush && random_int(100, state) < 45) ||
      (state.game_mode != Rush && random_int(100, state) < 30)
    )
  if should_spawn_items {
    let pipe_top_bottom = 160 - randgap - h
    let pipe_bottom_top = 160 - h
    let mut spawn_count = 1
    if state.game_mode == Rush {
      // 15% 概率生成第二个道具
      spawn_count = if random_int(100, state) < 15 { 2 } else { 1 }
    }
    for i = 0; i < spawn_count; i = i + 1 {
      let mut item_y = 0
      let mut attempts = 0
      let max_attempts = 10
      while attempts < max_attempts {
        item_y = random_range_inclusive(20, 140, state)
        let item_size = 10
        let item_top = item_y - item_size / 2
        let item_bottom = item_y + item_size / 2
        let pipe_top_collision = item_bottom > 0 && item_top < pipe_top_bottom
        let pipe_bottom_collision = item_bottom > pipe_bottom_top &&
          item_top < 160
        if !pipe_top_collision && !pipe_bottom_collision {
          break
        }
        attempts += 1
      }
      if attempts >= max_attempts {
        item_y = if random_int(2, state) == 0 {
          random_range_inclusive(10, pipe_top_bottom - 20, state)
        } else {
          random_range_inclusive(pipe_bottom_top + 20, 150, state)
        }
      }
      // 道具的x偏移：第一个更靠近缝隙入口，第二个稍微靠后，避免重叠
      let base_offset = random_range_inclusive(20, 35, state)
      let extra_offset = if i == 0 {
        0
      } else {
        random_range_inclusive(10, 20, state)
      }
      let item_x = adjusted_x + base_offset + extra_offset
      let item_type = get_random_item_type(state)
      spawn_item(item_x, item_y, item_type, state)
    }
  }
}
