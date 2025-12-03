// ==================== 工具函数 ====================

// LCG随机数生成器 用于生成随机间隙
// 线性同余生成器 - 生成0到max-1之间的随机整数

///|
pub fn random_int(max : Int, state : State) -> Int {
  state.random_seed = (state.random_seed * 1664525 + 1013904223) % 2147483647
  (state.random_seed % max).abs() // 确保结果是正数
}

// 生成min到max-1之间的随机整数

///|
pub fn random_range(min : Int, max : Int, state : State) -> Int {
  min + random_int(max - min, state)
}

// 生成min到max之间的随机整数（包括min和max）

///|
pub fn random_range_inclusive(min : Int, max : Int, state : State) -> Int {
  random_range(min, max + 1, state)
}
