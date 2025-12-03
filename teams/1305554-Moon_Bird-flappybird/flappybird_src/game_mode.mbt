// ==================== 游戏模式系统 ====================

///|
/// 内部函数：设置游戏模式并初始化相关参数
fn set_game_mode_internal(mode : Int, state : State) -> Unit {
  state.game_mode = match mode {
    0 => Classic
    1 => Timed
    2 => Perfect
    3 => Rush
    4 => Hard
    5 => Multiplayer
    _ => Classic
  }

  // 根据模式设置初始参数
  match state.game_mode {
    Rush => {
      state.pipe_speed = 2
      state.player_stats.lives = 3
      state.rush_meter = 0
      state.rush_mode_ticks = 0
      state.player_combat.current_health = 3
      state.player_combat.max_health = 3
    }
    Hard => {
      state.pipe_speed = 2
      state.player_stats.lives = 1
    }
    _ => {
      state.pipe_speed = 1
      state.player_stats.lives = 1
      if state.game_mode != Perfect {
        state.perfect_pipes = 0
      }
    }
  }
  // Timed 模式改为无道具的经典模式，不再限时
  state.time_remaining = 0
  if state.game_mode == Perfect {
    state.perfect_pipes = 0
  }

  // 清除所有活跃的道具效果
  state.active_effects = []
}

///|
/// JS 兼容的零参导出：读取全局 state
pub fn get_game_mode_export() -> Int {
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
pub fn update_game_mode_logic(state : State) -> Unit {
  match state.game_mode {
    _ => ()
  }
}
