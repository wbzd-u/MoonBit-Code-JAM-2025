// ==================== 导出函数供JavaScript调用 ====================

// 获取游戏状态

// ==================== 简单类型导出：基础状态 ====================

///|
pub fn get_bird_x() -> Int {
  pos.x
}

///|
pub fn get_bird_y() -> Int {
  pos.y
}

///|
pub fn get_score() -> Int {
  state.score
}

///|
pub fn is_game_started() -> Int {
  if state.game_started {
    1
  } else {
    0
  }
}

///|
pub fn is_game_over() -> Int {
  if state.gameover {
    1
  } else {
    0
  }
}

///|
pub fn get_pipe_speed() -> Int {
  state.pipe_speed
}

// ==================== 简单类型导出：管道只读视图 ====================

///|
pub fn get_pipes_count() -> Int {
  state.pipes.length()
}

///|
fn get_pipe_or_default(i : Int) -> Pipe {
  if i >= 0 && i < state.pipes.length() {
    state.pipes[i]
  } else {
    {
      x: 0,
      y: 0,
      h: 0,
      rand: 0,
      randgap: 0,
      scored: false,
      next_pipe_generated: false,
    }
  }
}

///|
pub fn get_pipe_x(i : Int) -> Int {
  let p = get_pipe_or_default(i)
  p.x
}

///|
pub fn get_pipe_y(i : Int) -> Int {
  let p = get_pipe_or_default(i)
  p.y
}

///|
pub fn get_pipe_h(i : Int) -> Int {
  let p = get_pipe_or_default(i)
  p.h
}

///|
pub fn get_pipe_rand(i : Int) -> Int {
  let p = get_pipe_or_default(i)
  p.rand
}

///|
pub fn get_pipe_randgap(i : Int) -> Int {
  let p = get_pipe_or_default(i)
  p.randgap
}

///|
pub fn is_pipe_scored(i : Int) -> Int {
  let p = get_pipe_or_default(i)
  if p.scored {
    1
  } else {
    0
  }
}

///|
pub fn is_pipe_next_generated(i : Int) -> Int {
  let p = get_pipe_or_default(i)
  if p.next_pipe_generated {
    1
  } else {
    0
  }
}

// ==================== 扩展状态导出函数 ====================

///|
pub fn get_evolution_stage() -> Int {
  match state.evolution_stage {
    EvolutionStage::Chick => 0
    EvolutionStage::Adult => 1
    EvolutionStage::Eagle => 2
    EvolutionStage::Phoenix => 3
    EvolutionStage::Dragon => 4
  }
}

///|
pub fn get_player_lives() -> Int {
  state.player_stats.lives
}

///|
pub fn get_player_skill_points() -> Int {
  state.player_stats.experience / 100
}

// get_bird_position() 已删除 - 使用 get_bird_x() 和 get_bird_y() 代替

///|
pub fn get_bird_size() -> Int {
  get_effective_bird_size(state)
}

///|
pub fn get_player_gold() -> Int {
  state.player_stats.gold
}

///|
pub fn get_player_experience() -> Int {
  state.player_stats.experience
}

///|
pub fn get_difficulty_level() -> Int {
  state.difficulty_level
}

///|
pub fn get_theme() -> Int {
  state.theme
}

///|
pub fn get_combo_count() -> Int {
  state.combo_count
}

///|
pub fn get_time_remaining() -> Int {
  state.time_remaining
}

///|
pub fn get_start_countdown_ticks() -> Int {
  state.start_countdown_ticks
}

///|
pub fn get_spawn_protection_ticks() -> Int {
  state.spawn_protection_ticks
}

///|
pub fn get_perfect_pipes() -> Int {
  state.perfect_pipes
}

///|
pub fn get_total_pipes_passed() -> Int {
  state.total_pipes_passed
}

// ==================== 道具系统导出函数 ====================

///|
pub fn get_items_count() -> Int {
  state.items.length()
}

///|
pub fn get_item_x(i : Int) -> Int {
  if i >= 0 && i < state.items.length() {
    state.items[i].x
  } else {
    0
  }
}

///|
pub fn get_item_y(i : Int) -> Int {
  if i >= 0 && i < state.items.length() {
    state.items[i].y
  } else {
    0
  }
}

///|
pub fn get_item_type(i : Int) -> Int {
  if i >= 0 && i < state.items.length() {
    match state.items[i].item_type {
      Shield => 0
      Hard => 1
      Shrink => 2
      Magnet => 3
      Gravity => 4
      Teleport => 5
      ScoreDouble => 6
      Life => 7
      Gold => 8
      Evolution => 9
      Invisible => 10
      Enlarge => 11
      DragonPower => 12
      Freeze => 13
      AttackBoost => 14
    }
  } else {
    0
  }
}

///|
pub fn is_item_collected(i : Int) -> Int {
  if i >= 0 && i < state.items.length() {
    if state.items[i].collected {
      1
    } else {
      0
    }
  } else {
    0
  }
}

// ==================== 道具效果导出函数 ====================

///|
pub fn get_active_effects_count() -> Int {
  state.active_effects.length()
}

///|
pub fn get_effect_type(i : Int) -> Int {
  if i >= 0 && i < state.active_effects.length() {
    match state.active_effects[i].item_type {
      Shield => 0
      Hard => 1
      Shrink => 2
      Magnet => 3
      Gravity => 4
      Teleport => 5
      ScoreDouble => 6
      Life => 7
      Gold => 8
      Evolution => 9
      Invisible => 10
      Enlarge => 11
      DragonPower => 12
      Freeze => 13
      AttackBoost => 14
    }
  } else {
    0
  }
}

///|
pub fn get_effect_remaining_time(i : Int) -> Int {
  if i >= 0 && i < state.active_effects.length() {
    state.active_effects[i].remaining_time
  } else {
    0
  }
}

///|
pub fn get_effective_bird_size_export() -> Int {
  get_effective_bird_size(state)
}

///|
pub fn get_teleport_active() -> Int {
  if state.teleport_active {
    1
  } else {
    0
  }
}

///|
pub fn get_teleport_progress() -> Int {
  if state.teleport_total_distance <= 0 {
    0
  } else {
    let progressed = state.teleport_total_distance -
      state.teleport_remaining_distance
    // 返回0-100的百分比
    progressed * 100 / state.teleport_total_distance
  }
}

///|
pub fn get_teleport_total_distance() -> Int {
  state.teleport_total_distance
}

///|
pub fn get_teleport_remaining_distance() -> Int {
  state.teleport_remaining_distance
}

///|
pub fn get_teleport_duration() -> Int {
  state.teleport_duration
}

///|
pub fn get_teleport_elapsed() -> Int {
  state.teleport_elapsed
}

// ==================== 冰冻效果导出函数 ====================

///|
pub fn has_freeze_effect_export() -> Int {
  let mut active = false
  for i = 0; i < state.active_effects.length(); i = i + 1 {
    let effect = state.active_effects[i]
    if effect.item_type == Freeze && effect.remaining_time > 0 {
      active = true
      break
    }
  }
  if active {
    1
  } else {
    0
  }
}

///|
pub fn get_rush_meter() -> Int {
  state.rush_meter
}

///|
pub fn get_rush_threshold() -> Int {
  if state.game_mode == Rush {
    200
  } else {
    240
  }
}

///|
pub fn get_rush_mode_ticks() -> Int {
  state.rush_mode_ticks
}

///|
pub fn get_dragon_charge() -> Int {
  state.dragon_charge
}

///|
pub fn get_dragon_charge_threshold() -> Int {
  get_dragon_charge_threshold_value()
}

///|
pub fn get_shake_ticks() -> Int {
  state.shake_ticks
}

///|
pub fn get_shake_magnitude() -> Int {
  state.shake_magnitude
}

///|
pub fn get_classic_boost_ticks() -> Int {
  state.classic_boost_ticks
}

///|
pub fn get_player_attack_power() -> Int {
  state.player_combat.attack_power
}

///|
pub fn get_player_current_health() -> Int {
  state.player_combat.current_health
}

///|
pub fn get_player_max_health() -> Int {
  state.player_combat.max_health
}

// ==================== 游戏模式统计导出函数 ====================

///|
pub fn set_game_mode(mode : Int) -> Unit {
  set_game_mode_internal(mode, state)
}

///|
pub fn get_game_mode() -> Int {
  match state.game_mode {
    Classic => 0
    Timed => 1
    Perfect => 2
    Rush => 3
    Hard => 4
    Multiplayer => 5
  }
}

///|
pub fn set_difficulty_level(level : Int) -> Unit {
  if level >= 1 && level <= 5 {
    state.difficulty_level = level
  }
}

///|
pub fn test_rush_mode() -> Unit {
  // 直接进入极速模式并启用冲刺机制
  set_game_mode_internal(3, state)
  state.game_started = true
  state.gameover = false
  state.count = 0
  state.score = 0
  state.pipe_scored = false
  state.pipes = []
  state.pipe_speed = 2
  state.combo_count = 0
  state.rush_meter = 220
  state.rush_mode_ticks = 0
  pos.x = 45
  pos.y = 80

  // 设置玩家属性
  state.player_stats.lives = 3
  state.player_combat.current_health = 3
  state.player_combat.max_health = 3
  state.player_combat.attack_power = 1
}

// ==================== 凤凰特效导出函数 ====================

///|
pub fn get_phoenix_effects_count() -> Int {
  state.phoenix_effects.length()
}

///|
fn get_phoenix_effect_or_default(i : Int) -> PhoenixEffect {
  if i >= 0 && i < state.phoenix_effects.length() {
    state.phoenix_effects[i]
  } else {
    { x: 0, y: 0, life: 0, size: 0, intensity: 0, phase: 0 }
  }
}

///|
pub fn get_phoenix_effect_x(i : Int) -> Int {
  let effect = get_phoenix_effect_or_default(i)
  effect.x
}

///|
pub fn get_phoenix_effect_y(i : Int) -> Int {
  let effect = get_phoenix_effect_or_default(i)
  effect.y
}

///|
pub fn get_phoenix_effect_life(i : Int) -> Int {
  let effect = get_phoenix_effect_or_default(i)
  effect.life
}

///|
pub fn get_phoenix_effect_size(i : Int) -> Int {
  let effect = get_phoenix_effect_or_default(i)
  effect.size
}

///|
pub fn get_phoenix_effect_intensity(i : Int) -> Int {
  let effect = get_phoenix_effect_or_default(i)
  effect.intensity
}

///|
pub fn get_phoenix_effect_phase(i : Int) -> Int {
  let effect = get_phoenix_effect_or_default(i)
  effect.phase
}

// ==================== 护盾和特效导出函数 ====================

///|
pub fn has_shield_effect_export() -> Int {
  if has_shield_effect(state) {
    1
  } else {
    0
  }
}

///|
pub fn update_phoenix_effects_export() -> Unit {
  update_phoenix_effects(state)
}

///|
pub fn get_phoenix_rebirth_active() -> Int {
  if state.phoenix_rebirth_active {
    1
  } else {
    0
  }
}

///|
pub fn get_phoenix_rebirth_duration() -> Int {
  state.phoenix_rebirth_duration
}

// ==================== 神龙自动效果导出函数 ====================

///|
pub fn export_get_dragon_auto_boost_active() -> Int {
  if get_dragon_auto_boost_active() {
    1
  } else {
    0
  }
}

///|
pub fn export_get_dragon_auto_boost_duration() -> Int {
  get_dragon_auto_boost_duration()
}

///|
pub fn export_get_dragon_auto_boost_cooldown() -> Int {
  get_dragon_auto_boost_cooldown()
}

// ==================== 测试函数 ====================

///|
pub fn test_phoenix_rebirth() -> Unit {
  // 强制设置为凤凰状态
  state.evolution_stage = EvolutionStage::Phoenix

  // 在当前位置创建凤凰重生特效
  create_phoenix_rebirth_effect(state, pos.x, pos.y)

  // 触发涅槃提示
  state.nirvana_notification_time = 180
}

///|
pub fn test_dragon_passive() -> Unit {
  // 强制设置为神龙状态
  state.evolution_stage = EvolutionStage::Dragon

  // 重置神龙自动效果状态
  state.dragon_auto_boost_timer = 0
  state.dragon_auto_boost_cooldown = 0

  // 触发神龙自动效果
  trigger_dragon_auto_boost(state)
}
