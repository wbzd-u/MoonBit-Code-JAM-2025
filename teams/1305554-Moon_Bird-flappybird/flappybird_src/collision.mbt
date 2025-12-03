// ==================== 碰撞检测 ====================

// 碰撞检测函数模块

///|
pub fn rect_collision(
  x1 : Int,
  y1 : Int,
  w1 : Int,
  h1 : Int,
  x2 : Int,
  y2 : Int,
  w2 : Int,
  h2 : Int,
) -> Bool {
  x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2
}

// 获取小鸟的有效大小（考虑形态和道具效果）

///|
pub fn get_effective_bird_size(state : State) -> Int {
  // 应用玩家属性中的体型调整（已经考虑了形态进化）
  let adjusted_size = state.player_stats.size

  // 确保大小在合理范围内
  if adjusted_size < 4 {
    4
  } else if adjusted_size > 16 {
    16
  } else {
    adjusted_size
  }
}

// 检查是否有护盾效果激活

///|
pub fn has_shield_effect(state : State) -> Bool {
  // 普通效果池中的护盾
  for i = 0; i < state.active_effects.length(); i = i + 1 {
    let effect = state.active_effects[i]
    if effect.item_type == Shield && effect.remaining_time > 0 {
      return true
    }
  }
  false
}

// 检查小鸟与管道的碰撞（只检测管道）

///|
pub fn check_collision(state : State, pos : Position) -> Bool {
  // 如果有护盾效果激活，则不检测碰撞
  if has_shield_effect(state) {
    return false
  }
  // 经典模式阈值提速期间：无敌，忽略碰撞
  if state.game_mode == Classic && state.classic_boost_ticks > 0 {
    return false
  }
  // 开局护体期间忽略碰撞
  if state.spawn_protection_ticks > 0 {
    return false
  }

  // 获取当前小鸟的实际大小（考虑形态和道具效果）
  let bird_size = get_effective_bird_size(state)
  let bird_x = pos.x - bird_size / 2
  let bird_y = pos.y - bird_size / 2
  let bird_width = bird_size
  let bird_height = bird_size

  // 检查与屏幕边界的碰撞
  if bird_x < 0 ||
    bird_x + bird_width > 160 ||
    bird_y < 0 ||
    bird_y + bird_height > 160 {
    return true
  }

  // 检查与所有管道的碰撞
  for i = 0; i < state.pipes.length(); i = i + 1 {
    let pipe = state.pipes[i]

    // 上管道
    let pipe_top_x = pipe.x
    let pipe_top_y = pipe.y
    let pipe_top_width = 20
    let pipe_top_height = 160 - pipe.randgap - pipe.h

    // 下管道
    let pipe_bottom_x = pipe.x + pipe.rand
    let pipe_bottom_y = 160 - pipe.h
    let pipe_bottom_width = 20
    let pipe_bottom_height = pipe.h

    // 检查碰撞
    let top_collision = rect_collision(
      bird_x, bird_y, bird_width, bird_height, pipe_top_x, pipe_top_y, pipe_top_width,
      pipe_top_height,
    )
    let bottom_collision = rect_collision(
      bird_x, bird_y, bird_width, bird_height, pipe_bottom_x, pipe_bottom_y, pipe_bottom_width,
      pipe_bottom_height,
    )
    if top_collision || bottom_collision {
      return true
    }
  }
  return false
}
