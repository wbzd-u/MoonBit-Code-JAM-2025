// ==================== 神龙自动效果系统 ====================

///|
pub fn update_dragon_auto_effects(state : State) -> Unit {
  // 始终更新神龙自动效果计时器
  if state.dragon_auto_boost_timer > 0 {
    state.dragon_auto_boost_timer -= 1
    if state.dragon_auto_boost_timer < 0 {
      state.dragon_auto_boost_timer = 0
    }
  }

  // 经典模式：改为基于充能的触发逻辑
  if state.game_mode == Classic {
    // 经典模式不再使用冷却计时器
    state.dragon_auto_boost_cooldown = 0
    if state.evolution_stage != Dragon {
      state.dragon_charge = 0
      return
    }
    let threshold = dragon_charge_threshold()
    if state.dragon_charge >= threshold && state.dragon_auto_boost_timer == 0 {
      trigger_dragon_auto_boost(state)
      state.dragon_charge = 0
    }
    return
  }

  // 非经典模式保留原有的定时触发逻辑
  if state.evolution_stage != Dragon {
    state.dragon_charge = 0
    if state.dragon_auto_boost_cooldown > 0 {
      state.dragon_auto_boost_cooldown -= 1
      if state.dragon_auto_boost_cooldown < 0 {
        state.dragon_auto_boost_cooldown = 0
      }
    }
    return
  }
  if state.dragon_auto_boost_cooldown > 0 {
    state.dragon_auto_boost_cooldown -= 1
    if state.dragon_auto_boost_cooldown < 0 {
      state.dragon_auto_boost_cooldown = 0
    }
  }
  if state.dragon_auto_boost_cooldown == 0 && state.dragon_auto_boost_timer == 0 {
    trigger_dragon_auto_boost(state)
    // 设置冷却时间：5秒 = 300帧
    state.dragon_auto_boost_cooldown = 300
  }
}

///|
fn dragon_charge_threshold() -> Int {
  240
}

///|
pub fn get_dragon_charge_threshold_value() -> Int {
  dragon_charge_threshold()
}

///|
pub fn add_dragon_charge(state : State, amount : Int) -> Unit {
  if amount <= 0 {
    return
  }
  if state.game_mode != Classic {
    return
  }
  if state.evolution_stage != Dragon {
    return
  }
  let threshold = dragon_charge_threshold()
  state.dragon_charge = state.dragon_charge + amount
  if state.dragon_charge > threshold {
    state.dragon_charge = threshold
  }
  if state.dragon_charge >= threshold {
    if state.dragon_auto_boost_timer == 0 {
      trigger_dragon_auto_boost(state)
      state.dragon_charge = 0
    } else {
      // 效果尚在持续时保持满槽显示
      state.dragon_charge = threshold
    }
  }
}

///|
fn trigger_dragon_auto_boost(state : State) -> Unit {
  // 触发龙威效果（加速+护盾的组合效果）
  // 只显示龙威效果，不显示单独的护盾和加速

  // 应用加速效果（但不添加到显示列表）
  let mut has_speed_effect = false
  for i = 0; i < state.active_effects.length(); i = i + 1 {
    let effect = state.active_effects[i]
    if effect.item_type == Hard && effect.remaining_time > 0 {
      has_speed_effect = true
      break
    }
  }
  if !has_speed_effect {
    // 允许神龙自动加速在 Hard 生效
    let original_speed = state.pipe_speed
    state.pipe_speed = state.pipe_speed * 2
    // 添加加速效果但不显示（通过设置特殊标记）
    add_item_effect(Hard, 120, original_speed, state)
  }

  // 添加护盾效果但不显示
  add_item_effect(Shield, 120, 0, state)

  // 只显示龙威效果
  add_item_effect(DragonPower, 120, 0, state)

  // 设置效果持续时间（2秒 = 120帧）
  state.dragon_auto_boost_timer = 120
}

///|
pub fn get_dragon_auto_boost_active() -> Bool {
  state.dragon_auto_boost_timer > 0
}

///|
pub fn get_dragon_auto_boost_duration() -> Int {
  state.dragon_auto_boost_timer
}

///|
pub fn get_dragon_auto_boost_cooldown() -> Int {
  state.dragon_auto_boost_cooldown
}
