# 绘图函数 ----------------------------------------------------------------------

# 中文说明：统一绘图主题，默认白底。
sdm_plot_theme <- function(base_size = 13) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.grid.major = ggplot2::element_line(color = "grey84", linewidth = 0.35),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(color = "grey20"),
      axis.title = ggplot2::element_text(color = "grey15"),
      plot.title = ggplot2::element_text(color = "grey10", face = "bold"),
      plot.subtitle = ggplot2::element_text(color = "grey25"),
      legend.background = ggplot2::element_rect(fill = "white", color = NA),
      legend.key = ggplot2::element_rect(fill = "white", color = NA)
    )
}

# 中文说明：返回图件正式输出路径。
sdm_plot_output_path <- function(run_paths, file_name) {
  sdm_output_path(run_paths, "figures", file_name)
}

# 中文说明：当前研究区扇区图仍由 legacy 脚本实现。
sdm_plot_study_area_sector <- function(message_only = TRUE) {
  if (message_only) {
    message("Study area sector plotting is currently implemented in scripts/legacy/09_plot_study_area_map_pub.R and should use outputs/<run_id>/figures/ as the formal destination when migrated.")
  }
  invisible(TRUE)
}