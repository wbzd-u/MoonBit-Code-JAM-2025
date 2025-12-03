// ==================== 形态进化系统 ====================

///|
pub fn update_evolution(state : State) -> Unit {
  // 基于分数的目标阶段
  let target_stage = if state.score >= 50 {
    EvolutionStage::Dragon
  } else if state.score >= 15 {
    EvolutionStage::Phoenix
  } else if state.score >= 10 {
    EvolutionStage::Eagle
  } else if state.score >= 5 {
    EvolutionStage::Adult
  } else {
    EvolutionStage::Chick
  }

  // 仅当分数目标阶段高于当前阶段时才升级
  match state.evolution_stage {
    Chick =>
      if target_stage != EvolutionStage::Chick {
        state.evolution_stage = target_stage
        apply_evolution_bonuses(state)
      }
    Adult =>
      if target_stage == EvolutionStage::Eagle ||
        target_stage == EvolutionStage::Phoenix ||
        target_stage == EvolutionStage::Dragon {
        state.evolution_stage = target_stage
        apply_evolution_bonuses(state)
      }
    Eagle =>
      if target_stage == EvolutionStage::Phoenix ||
        target_stage == EvolutionStage::Dragon {
        state.evolution_stage = target_stage
        apply_evolution_bonuses(state)
      }
    Phoenix =>
      if target_stage == EvolutionStage::Dragon {
        state.evolution_stage = target_stage
        apply_evolution_bonuses(state)
      }
    Dragon => ()
  }
}

///|
pub fn apply_evolution_bonuses(state : State) -> Unit {
  match state.evolution_stage {
    Chick =>
      state.player_stats.experience = state.player_stats.experience * 6 / 5
    Adult => ()
    Eagle => {
      state.player_stats.jump_power = 22
      state.player_stats.speed = 10
      state.player_stats.size = 10
      state.player_stats.lives = 2
    }
    Phoenix => {
      state.player_stats.jump_power = 24
      state.player_stats.speed = 13
      state.player_stats.size = 9
      state.player_stats.lives = 2
    }
    Dragon => {
      state.player_stats.jump_power = 25
      state.player_stats.speed = 16
      state.player_stats.size = 8
      state.player_stats.lives = 5
    }
  }
}
