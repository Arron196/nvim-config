return {
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    opts = {
      hide_cursor = true,
      stop_eof = true,
      cursor_scrolls_alone = false,
      easing = "quadratic",
      respect_scrolloff = true,
    },
  },
  {
    "sphamba/smear-cursor.nvim",
    lazy = false,
    opts = {
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      scroll_buffer_space = true,
      smear_insert_mode = false,
      legacy_computing_symbols_support = false,
      transparent_bg_fallback_color = "#1f2335",
      stiffness = 0.6,
      trailing_stiffness = 0.45,
      damping = 0.95,
      stiffness_insert_mode = 0.55,
      trailing_stiffness_insert_mode = 0.4,
      damping_insert_mode = 0.97,
      hide_target_hack = true,
      never_draw_over_target = true,
    },
  },
}
