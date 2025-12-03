// ==================== 凤凰重生特效系统 ====================

///|
pub fn create_phoenix_rebirth_effect(state : State, x : Int, y : Int) -> Unit {
  // 设置凤凰涅槃特效激活状态
  state.phoenix_rebirth_active = true
  state.phoenix_rebirth_duration = 100 // 100帧持续时间

  // 创建多个火焰粒子效果 - 缩小粒子大小
  for i = 0; i < 6; i = i + 1 {
    let effect = {
      x: x + (i % 3 - 1) * 4, // 减少粒子间距
      y: y + (i / 3 - 1) * 4, // 减少粒子间距
      life: 45, // 0.75秒特效
      size: 3 + i % 3,
      intensity: 80,
      phase: 0,
    } // 从6+2*i减少到3+i，缩小一半
    state.phoenix_effects.push(effect)
  }

  // 创建中心光芒效果 - 缩小光芒大小
  let center_effect = { x, y, life: 60, size: 6, intensity: 120, phase: 1 } // 从12减少到6，缩小一半
  state.phoenix_effects.push(center_effect)

  // 创建重生光环效果 - 缩小光圈大小
  let rebirth_effect = { x, y, life: 75, size: 9, intensity: 150, phase: 2 } // 从18减少到9，缩小一半
  state.phoenix_effects.push(rebirth_effect)
}

///|
pub fn update_phoenix_effects(state : State) -> Unit {
  // 更新凤凰涅槃特效激活状态
  if state.phoenix_rebirth_active {
    state.phoenix_rebirth_duration -= 1
    if state.phoenix_rebirth_duration <= 0 {
      state.phoenix_rebirth_active = false
    }
  }
  let mut i = 0
  while i < state.phoenix_effects.length() {
    let effect = state.phoenix_effects[i]
    effect.life -= 1

    // 更新特效属性
    match effect.phase {
      0 => {
        // 火焰阶段：逐渐变大变亮
        effect.size += 1
        effect.intensity = 80 + (45 - effect.life) * 1
      }
      1 => {
        // 光芒阶段：温和闪烁效果 - 缩小闪烁范围
        effect.intensity = 120 + effect.life % 8 * 3
        effect.size = 6 + effect.life % 2
      } // 从12+4减少到6+2，缩小一半
      2 => {
        // 重生阶段：温和扩散效果 - 减慢扩散速度
        effect.size += 1 // 保持每帧增加1，但由于初始大小减半，最终大小也会减半
        effect.intensity = 150 - (75 - effect.life) * 4 / 5
      }
      _ => ()
    }

    // 移除过期的特效
    if effect.life <= 0 {
      ignore(state.phoenix_effects.remove(i))
    } else {
      i += 1
    }
  }
}

///|
pub fn render_phoenix_effects(state : State) -> Unit {
  for i = 0; i < state.phoenix_effects.length(); i = i + 1 {
    let effect = state.phoenix_effects[i]
    render_phoenix_effect(effect)
  }
}

///|
fn render_phoenix_effect(effect : PhoenixEffect) -> Unit {
  match effect.phase {
    0 =>
      // 渲染火焰粒子
      render_fire_particle(effect.x, effect.y, effect.size, effect.intensity)
    1 =>
      // 渲染光芒效果
      render_light_effect(effect.x, effect.y, effect.size, effect.intensity)
    2 =>
      // 渲染重生光环
      render_rebirth_ring(effect.x, effect.y, effect.size, effect.intensity)
    _ => ()
  }
}

///|
fn render_fire_particle(x : Int, y : Int, size : Int, intensity : Int) -> Unit {
  // 火焰粒子渲染 - 使用红色到橙色的渐变
  let red = 255
  let green = 100 + intensity / 3
  let blue = 0
  let alpha = intensity * 2 / 3

  // 绘制火焰粒子（圆形）
  draw_circle(x, y, size, red, green, blue, alpha)

  // 添加火焰边缘效果
  let edge_size = size + 2
  let edge_alpha = alpha / 2
  draw_circle(x, y, edge_size, red, green + 50, blue, edge_alpha)
}

///|
fn render_light_effect(x : Int, y : Int, size : Int, intensity : Int) -> Unit {
  // 光芒效果渲染 - 使用金色光芒
  let red = 255
  let green = 215 + intensity / 5
  let blue = 0
  let alpha = intensity

  // 绘制光芒核心
  draw_circle(x, y, size, red, green, blue, alpha)

  // 绘制光芒外圈
  let outer_size = size + 4
  let outer_alpha = alpha / 3
  draw_circle(x, y, outer_size, red, green, blue, outer_alpha)
}

///|
fn render_rebirth_ring(x : Int, y : Int, size : Int, intensity : Int) -> Unit {
  // 重生光环渲染 - 使用紫色到白色的渐变
  let red = 200 + intensity / 4
  let green = 100 + intensity / 2
  let blue = 255
  let alpha = intensity * 3 / 4

  // 绘制重生光环
  draw_ring(x, y, size, size - 2, red, green, blue, alpha)

  // 绘制光环内圈
  let inner_size = size - 4
  let inner_alpha = alpha / 2
  draw_ring(x, y, inner_size, inner_size - 2, red, green, blue, inner_alpha)

  // 绘制重生符文
  draw_rebirth_rune(x, y, size / 3, red, green, blue, alpha)
}

///|
fn draw_circle(
  _x : Int,
  _y : Int,
  _radius : Int,
  _r : Int,
  _g : Int,
  _b : Int,
  _a : Int,
) -> Unit {
  // 简化的圆形绘制函数
  // 在实际实现中，这里会调用具体的图形API
  // 这里只是占位符，实际渲染需要根据具体的图形库来实现
}

///|
// 删除未使用的占位绘制函数以修正警告

///|
fn draw_ring(
  _x : Int,
  _y : Int,
  _outer_radius : Int,
  _inner_radius : Int,
  _r : Int,
  _g : Int,
  _b : Int,
  _a : Int,
) -> Unit {
  // 简化的环形绘制函数
  // 在实际实现中，这里会调用具体的图形API
}

///|
fn draw_rebirth_rune(
  _x : Int,
  _y : Int,
  _size : Int,
  _r : Int,
  _g : Int,
  _b : Int,
  _a : Int,
) -> Unit {
  // 绘制重生符文
  // 这里可以绘制一个简单的凤凰符号或重生符文
}

///|
// 删除未使用的cos占位函数

///|
// 删除未使用的sin占位函数
