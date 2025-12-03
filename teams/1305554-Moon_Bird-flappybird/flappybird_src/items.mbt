// ==================== 道具系统 ====================

///|
pub fn spawn_item(
  x : Int,
  y : Int,
  item_type : ItemType,
  state : State,
) -> Unit {
  let new_item = { x, y, item_type, duration: 300, collected: false }
  state.items.push(new_item)
}

// 获取随机道具类型

///|
pub fn get_random_item_type(state : State) -> ItemType {
  match state.game_mode {
    Hard => {
      let rand = random_int(100, state)
      if rand < 60 {
        Shield
      } else if rand < 85 {
        Teleport
      } else {
        Hard // 加速（自带护盾）
      }
    }
    Rush => {
      // 极速模式：只生成传送、加速、护盾三个道具
      let rand = random_int(100, state)
      if rand < 25 {
        Shield
      } else if rand < 75 {
        Teleport
      } else {
        Hard // 加速（自带护盾）
      }
    }
    _ => {
      let rand = random_int(100, state)
      if rand < 10 {
        Gold
      } else if rand < 18 {
        Life
      } else if rand < 28 {
        Shield
      } else if rand < 38 {
        Hard
      } else if rand < 48 {
        Shrink
      } else if rand < 56 {
        Magnet
      } else if rand < 64 {
        Gravity
      } else if rand < 70 {
        ScoreDouble
      } else if rand < 76 {
        Teleport
      } else if rand < 82 {
        Evolution
      } else if rand < 88 {
        Invisible
      } else if rand < 94 {
        Freeze
      } else if rand < 98 {
        AttackBoost
      } else {
        Enlarge
      }
    }
  }
}

///|
pub fn update_items(state : State) -> Unit {
  // 使用与管道相同的位移值，确保同步移动
  let displacement = state.current_displacement
  if displacement > 0 {
    for i = 0; i < state.items.length(); i = i + 1 {
      let item = state.items[i]
      if !item.collected {
        item.x -= displacement
      }
    }
  }
  state.items = state.items.filter(fn(item) { !item.collected && item.x > -20 })
  check_item_collision(state)
}

// 传送动画：逐帧推进，将世界左移直到完成

///|
pub fn update_teleport(state : State) -> Unit {
  if !state.teleport_active {
    return
  }
  if state.teleport_remaining_distance <= 0 || state.teleport_duration <= 0 {
    state.teleport_active = false
    state.teleport_total_distance = 0
    state.teleport_remaining_distance = 0
    state.teleport_duration = 0
    state.teleport_elapsed = 0
    return
  }
  let frames_left = state.teleport_duration - state.teleport_elapsed
  let step = if frames_left > 0 {
    // 均匀分配剩余距离，保证最后一帧对齐
    let avg = state.teleport_remaining_distance / frames_left
    if avg <= 0 {
      1
    } else {
      avg
    }
  } else {
    state.teleport_remaining_distance
  }

  // 左移管道
  for i = 0; i < state.pipes.length(); i = i + 1 {
    state.pipes[i].x = state.pipes[i].x - step
  }

  // 左移动态（未拾取）的道具
  for i = 0; i < state.items.length(); i = i + 1 {
    let item = state.items[i]
    if !item.collected {
      item.x = item.x - step
    }
  }

  // 递进进度
  state.teleport_remaining_distance = state.teleport_remaining_distance - step
  state.teleport_elapsed = state.teleport_elapsed + 1
  if state.teleport_remaining_distance <= 0 ||
    state.teleport_elapsed >= state.teleport_duration {
    state.teleport_active = false
    state.teleport_remaining_distance = 0
    state.teleport_elapsed = state.teleport_duration
  }
}

///|
fn check_item_collision(state : State) -> Unit {
  let bird_size = get_effective_bird_size(state)
  let bird_x = pos.x - bird_size / 2
  let bird_y = pos.y - bird_size / 2
  let bird_width = bird_size
  let bird_height = bird_size
  for i = 0; i < state.items.length(); i = i + 1 {
    let item = state.items[i]
    if !item.collected {
      let item_x = item.x
      let item_y = item.y
      let item_width = 10
      let item_height = 10
      if rect_collision(
          bird_x, bird_y, bird_width, bird_height, item_x, item_y, item_width, item_height,
        ) {
        item.collected = true
        apply_item_effect(item.item_type, state)
      }
    }
  }
}

///|
fn apply_item_effect(item_type : ItemType, state : State) -> Unit {
  match item_type {
    Shield => add_item_effect(item_type, 180, 0, state)
    Hard => {
      let mut has_speed_effect = false
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == Hard && effect.remaining_time > 0 {
          has_speed_effect = true
          break
        }
      }
      if !has_speed_effect {
        // 允许道具在任何模式生效（包括 Hard），仅玩家输入被屏蔽
        let original_speed = state.pipe_speed
        state.pipe_speed = state.pipe_speed * 2
        add_item_effect(item_type, 120, original_speed, state)
      }
      add_item_effect(Shield, 120, 0, state)
    }
    AttackBoost => {
      let original_ap = state.player_combat.attack_power
      let mut boosted = original_ap + 2
      if boosted > 5 {
        boosted = 5
      }
      state.player_combat.attack_power = boosted
      add_item_effect(item_type, 180, original_ap, state)
    }
    Shrink => {
      let mut has_shrink_effect = false
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == Shrink && effect.remaining_time > 0 {
          has_shrink_effect = true
          break
        }
      }
      if !has_shrink_effect {
        let original_size = state.player_stats.size
        state.player_stats.size = state.player_stats.size / 2
        add_item_effect(item_type, 300, original_size, state)
      }
    }
    ScoreDouble => add_item_effect(item_type, 300, 0, state)
    Magnet => add_item_effect(item_type, 120, 0, state)
    Life => state.player_stats.lives += 1
    Gold => {
      state.player_stats.gold += 1
      // 金币也可受分数加倍影响
      let mut score_multiplier_gold = 1
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == ScoreDouble && effect.remaining_time > 0 {
          score_multiplier_gold = 2
          break
        }
      }
      state.score += 1 * score_multiplier_gold
    }
    Evolution => {
      if state.evolution_stage == EvolutionStage::Chick {
        state.evolution_stage = EvolutionStage::Adult
      } else if state.evolution_stage == EvolutionStage::Adult {
        state.evolution_stage = EvolutionStage::Eagle
      } else if state.evolution_stage == EvolutionStage::Eagle {
        state.evolution_stage = EvolutionStage::Phoenix
      } else if state.evolution_stage == EvolutionStage::Phoenix {
        state.evolution_stage = EvolutionStage::Dragon
      }
      apply_evolution_bonuses(state)
    }
    Gravity => add_item_effect(item_type, 120, 0, state)
    Teleport => start_teleport(state)
    Invisible => add_item_effect(item_type, 30, 0, state)
    Enlarge => {
      let original_size = state.player_stats.size
      state.player_stats.size = 12
      add_item_effect(item_type, 120, original_size, state)
    }
    DragonPower => {
      // 龙威效果：加速+护盾的组合效果
      let mut has_speed_effect = false
      for i = 0; i < state.active_effects.length(); i = i + 1 {
        let effect = state.active_effects[i]
        if effect.item_type == Hard && effect.remaining_time > 0 {
          has_speed_effect = true
          break
        }
      }
      if !has_speed_effect {
        let original_speed = state.pipe_speed
        state.pipe_speed = state.pipe_speed * 2
        add_item_effect(Hard, 120, original_speed, state)
      }
      add_item_effect(Shield, 120, 0, state)
      add_item_effect(item_type, 120, 0, state)
    }
    Freeze =>
      // 冰冻：禁用玩家输入，保留重力，持续约0.3秒（18帧）
      add_item_effect(item_type, 18, 0, state)
  }
}

// 开始传送：计算目标距离并设置动画参数

///|
fn start_teleport(state : State) -> Unit {
  if state.pipes.length() == 0 {
    return
  }
  let mut nearest_pipe_x = 200
  for i = 0; i < state.pipes.length(); i = i + 1 {
    let pipe = state.pipes[i]
    if pipe.x > pos.x && pipe.x < nearest_pipe_x {
      nearest_pipe_x = pipe.x
    }
  }
  let mut teleport_distance = nearest_pipe_x - pos.x + 100
  if teleport_distance < 0 {
    teleport_distance = 0
  }
  if teleport_distance == 0 {
    return
  }
  state.teleport_active = true
  state.teleport_total_distance = teleport_distance
  state.teleport_remaining_distance = teleport_distance
  state.teleport_duration = 12 // 约0.2秒@60fps
  state.teleport_elapsed = 0

  // 给予短暂护盾
  add_item_effect(Shield, 60, 0, state)
}

// 添加道具效果到激活列表

///|
fn add_item_effect(
  item_type : ItemType,
  duration : Int,
  original_value : Int,
  state : State,
) -> Unit {
  let effect : ItemEffect = {
    item_type,
    remaining_time: duration,
    original_value,
  }
  state.active_effects.push(effect)
}

// 更新道具效果

///|
pub fn update_item_effects(state : State) -> Unit {
  for i = 0; i < state.active_effects.length(); i = i + 1 {
    let effect = state.active_effects[i]
    effect.remaining_time -= 1
  }
  state.active_effects = state.active_effects.filter(fn(effect) {
    if effect.remaining_time <= 0 {
      match effect.item_type {
        Hard => {
          let mut has_other_speed_effect = false
          for j = 0; j < state.active_effects.length(); j = j + 1 {
            let other_effect = state.active_effects[j]
            if other_effect.item_type == Hard && other_effect.remaining_time > 0 {
              has_other_speed_effect = true
              break
            }
          }
          if !has_other_speed_effect {
            // 恢复基础速度：极速模式根据通过的管道数动态计算，Hard模式保持2，其他模式恢复到1
            let base_speed = match state.game_mode {
              Rush => {
                // 极速模式：每通过10个管道速度增加1，最大速度3
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
          }
        }
        Shrink => {
          let current_evolution_size = match state.evolution_stage {
            EvolutionStage::Chick => 12
            EvolutionStage::Adult => 12
            EvolutionStage::Eagle => 10
            EvolutionStage::Phoenix => 9
            EvolutionStage::Dragon => 8
          }
          state.player_stats.size = current_evolution_size
        }
        Enlarge => {
          let current_evolution_size = match state.evolution_stage {
            EvolutionStage::Chick => 12
            EvolutionStage::Adult => 12
            EvolutionStage::Eagle => 10
            EvolutionStage::Phoenix => 9
            EvolutionStage::Dragon => 8
          }
          state.player_stats.size = current_evolution_size
        }
        Invisible => ignore(())
        Shield => ignore(())
        ScoreDouble => ()
        Magnet => ()
        Gravity => ()
        Teleport => ()
        DragonPower => ignore(())
        AttackBoost => state.player_combat.attack_power = effect.original_value
        _ => ()
      }
      false
    } else {
      true
    }
  })
}
