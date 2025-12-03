// ==================== 游戏主逻辑 ====================

// 初始化游戏

///|
pub fn game_init() -> Unit {
  state.count = 0
  state.gameover = false
  state.game_started = false
  state.random_seed = 12345
  state.score = 0
  state.pipe_scored = false
  state.pipes = []
  state.pipe_speed = 1
  pos.x = 45
  pos.y = 80
  state.start_countdown_ticks = 0
  state.spawn_protection_ticks = 0
  state.evolution_stage = EvolutionStage::Chick
  state.player_stats = {
    jump_power: 20,
    speed: 9,
    size: 12,
    lives: 1,
    gold: 0,
    experience: 0,
  }
  state.items = []
  state.active_effects = []
  state.phoenix_effects = []
  state.difficulty_level = 1
  state.theme = 0
  state.combo_count = 0
  state.time_remaining = 0
  state.perfect_pipes = 0
  state.total_pipes_passed = 0
  state.player_combat = {
    attack_power: 1,
    attack_cooldown: 0,
    max_health: 3,
    current_health: 3,
  }
  state.nirvana_notification_time = 0
  state.phoenix_rebirth_active = false
  state.phoenix_rebirth_duration = 0
  state.dragon_auto_boost_timer = 0
  state.dragon_auto_boost_cooldown = 0
  state.dragon_charge = 0
  state.rush_meter = 0
  state.rush_mode_ticks = 0
  state.teleport_active = false
  state.teleport_total_distance = 0
  state.teleport_remaining_distance = 0
  state.teleport_duration = 0
  state.teleport_elapsed = 0

  // 冰冻初始化
  // 冰冻通过active_effects跟踪，无需额外状态
  state.classic_boost_ticks = 0
  state.classic_ramp_ticks = 0
}

// 开始游戏

///|
pub fn game_start() -> Unit {
  state.game_started = true
  state.gameover = false
  state.count = 0
  state.score = 0
  state.pipe_scored = false
  state.pipes = []
  // 启动时清理各模式道具与效果，避免跨模式残留
  state.items = []
  state.active_effects = []
  state.combo_count = 0
  state.total_pipes_passed = 0
  state.start_countdown_ticks = 180 // 3秒倒计时
  state.spawn_protection_ticks = 0 // 护体在倒计时结束后触发
  match state.game_mode {
    Hard => state.pipe_speed = 2
    Rush => state.pipe_speed = 2
    _ => state.pipe_speed = 1
  }
  pos.x = 45
  pos.y = 80
  state.evolution_stage = Chick

  // 根据游戏模式设置玩家属性
  let lives_count = match state.game_mode {
    Rush => 3
    Hard => 1
    _ => 1
  }
  state.player_stats = {
    jump_power: 20,
    speed: 9,
    size: 12,
    lives: lives_count,
    gold: 0,
    experience: 0,
  }
  state.nirvana_notification_time = 0
  state.phoenix_rebirth_active = false
  state.phoenix_rebirth_duration = 0
  state.dragon_auto_boost_timer = 0
  state.dragon_auto_boost_cooldown = 0
  state.dragon_charge = 0
  state.rush_meter = 0
  state.rush_mode_ticks = 0
  state.teleport_active = false
  state.teleport_total_distance = 0
  state.teleport_remaining_distance = 0
  state.teleport_duration = 0
  state.teleport_elapsed = 0

  // 冰冻在开始时无
  state.classic_boost_ticks = 0
  // 经典模式：开局线性加速到2
  if state.game_mode == Classic {
    state.classic_ramp_ticks = 120
    state.pipe_speed = 1
  } else {
    state.classic_ramp_ticks = 0
  }
}

// 更新游戏逻辑

///|
pub fn game_update() -> Unit {
  if state.game_started {
    // 倒计时阶段：不再阻塞游戏更新，仅作为免疫期的可视提示
    if state.start_countdown_ticks > 0 {
      state.start_countdown_ticks -= 1
      // 在倒计时期间持续给予护体判定
      if state.spawn_protection_ticks < 1 {
        state.spawn_protection_ticks = 1
      }
      // 倒计时结束后追加一小段护体时间，过渡更自然
      if state.start_countdown_ticks == 0 {
        state.spawn_protection_ticks = 60
      }
    }
    // 护体帧倒计时
    if state.spawn_protection_ticks > 0 {
      state.spawn_protection_ticks -= 1
    }
    setbird(state, pos)
    setpipe(state, pos)
    // 更新道具与传送（所有模式都支持）
    update_items(state)
    update_teleport(state)
    update_item_effects(state)
    update_phoenix_effects(state)
    update_dragon_auto_effects(state)

    // Rush 动量条：逐帧自然衰减
    if state.game_mode == Rush {
      if state.rush_meter > 0 {
        state.rush_meter = state.rush_meter - 1
        if state.rush_meter < 0 {
          state.rush_meter = 0
        }
      }
      state.rush_mode_ticks = state.rush_mode_ticks + 1
    }
    // 经典模式：线性加速到2，且允许道具加速突破到3；不触发阈值无敌
    if state.game_mode == Classic {
      state.classic_boost_ticks = 0
      // 线性加速阶段（120帧）：1 -> 2（若有Hard加速效果，目标提升到3）
      if state.classic_ramp_ticks > 0 {
        state.classic_ramp_ticks = state.classic_ramp_ticks - 1
        let mut has_speed_boost = false
        for i = 0; i < state.active_effects.length(); i = i + 1 {
          let effect = state.active_effects[i]
          if effect.item_type == Hard && effect.remaining_time > 0 {
            has_speed_boost = true
            break
          }
        }
        let target = if has_speed_boost { 3 } else { 2 }
        // 根据剩余帧计算进度：elapsed / total
        let total = 120
        let elapsed = total - state.classic_ramp_ticks
        if elapsed < 0 {
          // 防御性处理
          state.pipe_speed = 1
        } else {
          // 线性插值：1 -> target
          let mut interp = 1 + (target - 1) * elapsed / total
          // 避免回退
          if interp < state.pipe_speed {
            interp = state.pipe_speed
          }
          // 赋值
          state.pipe_speed = interp
        }
      } else {
        // 非加速阶段：保持在1~2（若有Hard则允许到3）
        let mut has_speed_boost = false
        for i = 0; i < state.active_effects.length(); i = i + 1 {
          let effect = state.active_effects[i]
          if effect.item_type == Hard && effect.remaining_time > 0 {
            has_speed_boost = true
            break
          }
        }
        let max_speed = if has_speed_boost { 3 } else { 2 }
        if state.pipe_speed < 1 {
          state.pipe_speed = 1
        }
        if state.pipe_speed > max_speed {
          state.pipe_speed = max_speed
        }
      }
    }
    // 屏幕震动计时
    if state.shake_ticks > 0 {
      state.shake_ticks = state.shake_ticks - 1
      if state.shake_ticks < 0 {
        state.shake_ticks = 0
      }
    }

    // 更新涅槃提示时间
    if state.nirvana_notification_time > 0 {
      state.nirvana_notification_time -= 1
    }
    check_pipe_passing()
    update_game_mode_logic(state)

    // 极速模式：速度逐渐加快（若存在加速效果，则在原有加速度上叠加）
    if state.game_mode == Rush {
      // 基础速度2，每通过10个管道速度增加1，最大速度3
      // 速度曲线：2 -> 3(10管+)
      let speed_increment = state.total_pipes_passed / 10
      let mut target_speed = 2 + speed_increment
      if target_speed > 3 {
        target_speed = 3
      }
      let mut has_speed_boost = false
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == Hard && effect.remaining_time > 0 {
          has_speed_boost = true
          break
        }
      }
      if has_speed_boost {
        if state.pipe_speed < target_speed {
          state.pipe_speed = target_speed
        }
      } else {
        state.pipe_speed = target_speed
      }
    }
    if check_collision(state, pos) {
      handle_collision()
    }
  } else {
    update_game_mode_logic(state)
  }
}

// 检查管道通过情况

///|
fn check_pipe_passing() -> Unit {
  for i = 0; i < state.pipes.length(); i = i + 1 {
    let pipe = state.pipes[i]
    if !pipe.scored && pos.x > pipe.x + 20 {
      pipe.scored = true
      state.total_pipes_passed += 1
      // Rush 模式：通过管道提升动量
      if state.game_mode == Rush {
        let mut threshold = 200
        // 与导出函数保持一致：非 Rush 给 240，这里 Rush 固定 200
        threshold = 200
        state.rush_meter = state.rush_meter + 30
        if state.rush_meter > threshold {
          state.rush_meter = threshold
        }
      }
      // 经典模式：累积神龙充能，用于触发龙威
      if state.game_mode == Classic {
        add_dragon_charge(state, 30)
      }
      if state.game_mode == Perfect {
        state.perfect_pipes += 1
      }

      // 每成功通过一个管道则增加连击数；在碰撞与复活等处会被重置
      state.combo_count = state.combo_count + 1

      // 连击奖励：在5连与10连各赠送一次金币与+1分数（受分数加倍影响）
      let mut score_multiplier_combo = 1
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == ScoreDouble && effect.remaining_time > 0 {
          score_multiplier_combo = 2
          break
        }
      }
      if state.combo_count == 5 {
        state.player_stats.gold += 1
        state.score += 1 * score_multiplier_combo
      }
      if state.combo_count == 10 {
        state.player_stats.gold += 1
        state.score += 1 * score_multiplier_combo
      }
      let combo_bonus = if state.combo_count >= 10 {
        2
      } else if state.combo_count >= 5 {
        1
      } else {
        0
      }
      let base_score = match state.game_mode {
        Classic => 1
        Timed => 1 // 无道具经典模式，分数与经典模式相同
        Perfect => 1
        Rush => 2
        Hard => 3
        _ => 1
      }
      // 极速模式：根据动量条高度增加额外分数
      let mut momentum_bonus = 0
      if state.game_mode == Rush {
        let threshold = 200
        let meter = state.rush_meter
        // 根据动量条百分比计算额外分数
        // 0-50%: +0分, 50-75%: +1分, 75-100%: +2分
        if meter >= threshold * 3 / 4 {
          momentum_bonus = 2
        } else if meter >= threshold / 2 {
          momentum_bonus = 1
        } else {
          momentum_bonus = 0
        }
      }
      let mut score_multiplier = 1
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == ScoreDouble && effect.remaining_time > 0 {
          score_multiplier = 2
          break
        }
      }
      state.score += (base_score + combo_bonus + momentum_bonus) *
        score_multiplier
    }
  }
}

///|
fn handle_collision() -> Unit {
  // 涅槃是凤凰的专属特技
  if state.evolution_stage == Phoenix {
    if random_int(100, state) < 60 {
      // 创建凤凰重生特效
      create_phoenix_rebirth_effect(state, pos.x, pos.y)

      // 触发涅槃提示（显示3秒，180帧）
      state.nirvana_notification_time = 180
      pos.x = 45
      pos.y = 80
      state.pipes = []
      state.combo_count = 0
      // 涅槃后恢复速度：极速模式根据通过的管道数动态计算，Hard模式保持2，其它模式1
      let base_speed = match state.game_mode {
        Rush => {
          let speed_increment = state.total_pipes_passed / 10
          let target_speed = 2 + speed_increment
          if target_speed > 3 {
            3
          } else {
            target_speed
          }
        }
        Hard => 2
        _ => 1
      }
      state.pipe_speed = base_speed
      return
    }
  }
  if state.player_stats.lives > 1 {
    state.player_stats.lives -= 1
    // 碰撞但仍有生命：触发轻微震动
    state.shake_ticks = 12
    state.shake_magnitude = 2
    pos.x = 45
    pos.y = 80
    state.pipes = []
    state.combo_count = 0
    let base_speed = match state.game_mode {
      Rush => {
        let speed_increment = state.total_pipes_passed / 10
        let target_speed = 2 + speed_increment
        if target_speed > 3 {
          3
        } else {
          target_speed
        }
      }
      Hard => 2
      _ => 1
    }
    state.pipe_speed = base_speed
    // 经典模式：复活后触发线性加速到2
    if state.game_mode == Classic {
      state.classic_ramp_ticks = 120
      if state.pipe_speed < 1 {
        state.pipe_speed = 1
      }
    }
  } else {
    state.gameover = true
    state.game_started = false
    state.combo_count = 0
  }
}

// 获取涅槃提示状态

///|
pub fn get_nirvana_notification_active() -> Bool {
  state.nirvana_notification_time > 0
}

// 处理输入

///|
pub fn handle_input(
  button_up : Bool,
  button_down : Bool,
  button_left : Bool,
  button_right : Bool,
  button_1 : Bool,
) -> Unit {
  if button_1 && !state.game_started {
    if state.game_mode == Classic {
      game_start()
    } else {
      game_start()
    }
  }
  if state.game_started {
    // 冰冻期间禁用玩家输入（上下左右与按钮），但允许开始键在未开始时
    let mut is_frozen = false
    for i = 0; i < state.active_effects.length(); i = i + 1 {
      let effect = state.active_effects[i]
      if effect.item_type == Freeze && effect.remaining_time > 0 {
        is_frozen = true
        break
      }
    }
    if is_frozen {
      // 跳过输入处理，直接返回
      return
    }
    let bird_size = get_effective_bird_size(state)
    let bird_half_size = bird_size / 2
    let (up_jump_power, down_jump_power, can_jump) = match state.game_mode {
      Hard => (2, 2, (true, true))
      _ => (2, 2, (true, true))
    }
    let mut gravity_reversed = false
    for i = 0; i < state.active_effects.length(); i = i + 1 {
      let effect = state.active_effects[i]
      if effect.item_type == Gravity && effect.remaining_time > 0 {
        gravity_reversed = true
        break
      }
    }
    let mut magnet_reversed = false
    for i = 0; i < state.active_effects.length(); i = i + 1 {
      let effect = state.active_effects[i]
      if effect.item_type == Magnet && effect.remaining_time > 0 {
        magnet_reversed = true
        break
      }
    }
    let (can_jump_up, can_jump_down) = can_jump
    if gravity_reversed {
      if button_up && can_jump_up && pos.y - bird_half_size > 0 {
        pos.y -= up_jump_power
      } else if button_down && can_jump_down && pos.y + bird_half_size < 160 {
        pos.y += down_jump_power
      }
    } else if magnet_reversed {
      if button_up && can_jump_up && pos.y + bird_half_size < 160 {
        pos.y += up_jump_power
      } else if button_down && can_jump_down && pos.y - bird_half_size > 0 {
        pos.y -= down_jump_power
      }
    } else if button_up && can_jump_up && pos.y - bird_half_size > 0 {
      pos.y -= up_jump_power
    } else if button_down && can_jump_down && pos.y + bird_half_size < 160 {
      pos.y += down_jump_power
    }
    // 极速模式下锁定移动速率为2，忽略左右键速度调整
    if state.game_mode != Hard && state.game_mode != Rush {
      if button_left {
        state.pipe_speed = 1
      }
      if button_right {
        state.pipe_speed = 2
      }
    }
  }
}

///|
pub fn handle_input_i(
  button_up : Int,
  button_down : Int,
  button_left : Int,
  button_right : Int,
  button_1 : Int,
) -> Unit {
  let up_b = button_up != 0
  let down_b = button_down != 0
  let left_b = button_left != 0
  let right_b = button_right != 0
  let b1_b = button_1 != 0
  handle_input(up_b, down_b, left_b, right_b, b1_b)
}
