// ==================== 小鸟控制 ====================

///|
pub fn setbird(state : State, pos : Position) -> Unit {
  state.count += 1

  // 更新形态进化
  update_evolution(state)

  // 冰冻期间：禁用玩家操控，但重力仍然生效
  ignore(
    {
      let mut found = false
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == Freeze && effect.remaining_time > 0 {
          found = true
          break
        }
      }
      found
    },
  )

  // 重力 (根据形态和游戏模式调整)
  let gravity_factor = if state.count % 2 == 0 { 1 } else { 0 }
  let base_gravity_strength = match state.evolution_stage {
    Chick => 1
    Adult => 1
    Eagle => 1
    Phoenix => 1
    Dragon => 1
  }

  // 根据游戏模式调整重力强度
  let gravity_strength = match state.game_mode {
    Hard => base_gravity_strength
    _ => base_gravity_strength
  }
  let bird_size = get_effective_bird_size(state)

  // 检查是否有重力反转效果
  let mut gravity_reversed = false
  for i = 0; i < state.active_effects.length(); i = i + 1 {
    let effect = state.active_effects[i]
    if effect.item_type == Gravity && effect.remaining_time > 0 {
      gravity_reversed = true
      break
    }
  }
  if gravity_factor == 1 {
    if gravity_reversed {
      // 重力反转：持续向上移动（保持正常强度）
      if pos.y - bird_size / 2 > 0 {
        pos.y -= gravity_strength
      }
    } else if pos.y + bird_size / 2 < 160 {
      pos.y += gravity_strength
    }
  }

  // 边界检测：确保小鸟不会超出屏幕
  let bird_half_size = bird_size / 2
  if pos.y - bird_half_size < 0 {
    pos.y = bird_half_size
  }
  if pos.y + bird_half_size > 160 {
    pos.y = 160 - bird_half_size
  }
}
