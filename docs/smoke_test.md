# Smoke Test 说明

本文件用于做最小级别的项目结构自检，不触发任何数据分析、环境变量处理或 biomod2 建模。

## 1. 验证 config 可加载

在项目根目录运行：

```r
Rscript -e "source('R/config.R'); cfg <- sdm_load_config('config/runs/humpback_cosmonaut.R'); cat(cfg$run_id, '\n')"
```

预期：输出 `humpback_cosmonaut`。

## 2. 验证 _targets.R 可识别

在项目根目录运行：

```r
Rscript -e "parse(file = '_targets.R'); cat('targets file parse ok\n')"
```

预期：输出 `targets file parse ok`。

## 3. 验证 outputs/<run_id>/ 路径构建正确

在项目根目录运行：

```r
Rscript -e "source('R/config.R'); cfg <- sdm_load_config('config/runs/humpback_cosmonaut.R'); paths <- sdm_build_run_paths(cfg); cat(paths$formal_output_root, '\n'); cat(sdm_output_path(paths, 'tables', 'demo.csv'), '\n')"
```

预期：

- 第一行应指向 `E:/MyProject/myBlog/codex_sdm/outputs/humpback_cosmonaut`
- 第二行应指向 `E:/MyProject/myBlog/codex_sdm/outputs/humpback_cosmonaut/tables/demo.csv`

## 4. 可选：运行最小测试骨架

```r
Rscript tests/testthat.R
```

预期：测试通过，且不会触发任何实际建模。