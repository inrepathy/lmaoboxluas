local consolas = draw.CreateFont("Tahoma", 14, 500)

local function watermark()
  draw.SetFont(consolas)
  local time = os.date("*t")
  local current_time = string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
  local screen_width = draw.GetScreenSize()
  local text = "lmaobox | time: " .. current_time .. ""
  local text_width, text_height = draw.GetTextSize(text)
  local x_position = screen_width - text_width - 10
  local y_position = 10
  local padding = 2
  draw.Color(179, 91, 107, 150)
  draw.FilledRect(x_position - padding, y_position - padding, x_position + text_width + padding, y_position + text_height + padding)
  draw.Color(255, 255, 255, 255)
  draw.Text(x_position, y_position, text)
end

callbacks.Register("Draw", "draw", watermark)
