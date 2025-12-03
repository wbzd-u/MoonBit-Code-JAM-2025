// ==================== 枚举类型定义 ====================

// 游戏模式枚举

///|
pub enum GameMode {
  Classic // 经典模式
  Timed // 限时模式
  Perfect // 完美模式
  Rush // 极速模式（高压挑战，无Boss）
  Hard // 困难模式
  Multiplayer // 多人模式
} derive(Eq)

// 形态进化枚举

///|
pub enum EvolutionStage {
  Chick // 雏鸟 (0分)
  Adult // 成鸟 (5分)
  Eagle // 雄鹰 (10分)
  Phoenix // 凤凰 (15分)
  Dragon // 神龙 (50分)
} derive(Eq)

// 道具类型枚举

///|
pub enum ItemType {
  Shield // 护盾（ 临时无敌）
  Hard // 加速（瞬间加速并无敌）
  Shrink // 缩小（体型变小）
  Magnet // 磁铁(按键上下反转)
  Gravity // 重力反转
  Teleport // 传送门（瞬移）
  ScoreDouble // 分数翻倍
  Life // 生命值
  Gold // 金币
  Evolution // 形态加速器（进化到下一阶段）
  Invisible // 隐形道具 (debuff)
  Enlarge // 放大道具 (debuff)
  DragonPower // 龙威（神龙被动技能：加速+护盾）
  Freeze // 冰冻（约0.3秒无法操控，保留重力）
  AttackBoost // 攻击力提升（临时）
} derive(Eq)

// ==================== 结构体定义 ====================

// 玩家战斗系统结构体

///|
pub struct PlayerCombat {
  mut attack_power : Int
  attack_cooldown : Int
  mut max_health : Int
  mut current_health : Int
}

// 道具结构体

///|
pub struct Item {
  mut x : Int
  y : Int
  item_type : ItemType
  duration : Int // 持续时间（帧数）
  mut collected : Bool
}

// 道具效果状态

///|
pub struct ItemEffect {
  item_type : ItemType
  mut remaining_time : Int // 剩余时间（帧数）
  original_value : Int // 原始值（用于恢复）
}

// 管道结构体

///|
pub struct Pipe {
  mut x : Int
  y : Int
  h : Int
  rand : Int
  randgap : Int // 添加randgap字段
  mut scored : Bool
  mut next_pipe_generated : Bool
}

// 玩家属性结构体

///|
pub struct PlayerStats {
  mut jump_power : Int // 跳跃力 (18-38, 基础18)
  mut speed : Int // 速度 (9-16, 基础9)
  mut size : Int // 体型 (12-6, 基础12)
  mut lives : Int // 生命值
  mut gold : Int // 金币
  mut experience : Int // 经验值
}

// 游戏状态

///|
pub struct State {
  mut count : Int
  mut gameover : Bool
  mut game_started : Bool
  mut random_seed : Int
  mut score : Int
  mut pipe_scored : Bool
  mut pipes : Array[Pipe]
  mut pipe_speed : Int
  // 用于亚像素级平滑移动的累计器（千分位缩放）
  mut pipe_move_accum : Int
  // 当前帧的位移值（用于同步道具和管道的移动）
  mut current_displacement : Int
  mut game_mode : GameMode
  mut evolution_stage : EvolutionStage
  mut player_stats : PlayerStats
  mut items : Array[Item]
  mut active_effects : Array[ItemEffect]
  mut difficulty_level : Int
  mut theme : Int
  mut combo_count : Int
  mut time_remaining : Int
  mut perfect_pipes : Int
  mut total_pipes_passed : Int
  mut player_combat : PlayerCombat
  mut phoenix_effects : Array[PhoenixEffect]
  mut nirvana_notification_time : Int // 涅槃提示显示时间
  mut phoenix_rebirth_active : Bool // 凤凰涅槃特效激活状态
  mut phoenix_rebirth_duration : Int // 凤凰涅槃特效持续时间
  mut dragon_auto_boost_timer : Int // 神龙自动加速计时器（帧数）
  mut dragon_auto_boost_cooldown : Int // 神龙自动加速冷却时间（帧数）
  mut dragon_charge : Int // 神龙充能槽（经典模式）
  mut rush_meter : Int // 极速模式动量槽
  mut rush_mode_ticks : Int // 极速阶段累计帧
  mut teleport_active : Bool // 传送动画是否进行中
  mut teleport_total_distance : Int // 传送总距离（像素）
  mut teleport_remaining_distance : Int // 剩余需要左移的距离
  mut teleport_duration : Int // 传送动画总帧数
  mut teleport_elapsed : Int // 已经经历的帧数
  mut start_countdown_ticks : Int // 开局倒计时（帧），>0 表示倒计时中
  mut spawn_protection_ticks : Int // 开局护体（帧），>0 则忽略碰撞
  mut classic_boost_ticks : Int // 经典模式阈值触发的无敌提速剩余帧
  mut shake_ticks : Int // 屏幕震动剩余帧
  mut shake_magnitude : Int // 屏幕震动幅度
  mut classic_ramp_ticks : Int // 经典模式开局/复活线性加速剩余帧
}

// 位置结构体

///|
pub struct Position {
  mut x : Int
  mut y : Int
}

// 凤凰重生特效结构体

///|
pub struct PhoenixEffect {
  x : Int
  y : Int
  mut life : Int // 特效生命周期
  mut size : Int // 特效大小
  mut intensity : Int // 特效强度
  phase : Int // 特效阶段 (0=火焰, 1=光芒, 2=重生)
}
