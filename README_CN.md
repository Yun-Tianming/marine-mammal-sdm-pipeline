# codex_sdm

[English](README.md) | 简体中文

## 概述

本仓库是配置驱动的物种分布模型（SDM）流程的稳定 v1 版本。
默认运行保留了已完成的座头鲸分析，但项目结构现已可复用于其他物种和区域。

## 稳定 v1 状态

- 默认运行配置：`config/runs/humpback_cosmonaut.R`
- 正式输出根目录：`outputs/humpback_cosmonaut/`
- `outputs/`、`data_clean/` 和 `env_processed/` 下仍存在旧版兼容路径，但不再是推荐的数据源。
- `scripts/runners/` 是唯一推荐的入口目录。
- `scripts/legacy/` 仅保留用于可追溯性。
- `renv.lock` 目前是引导锁文件，因为本地机器未安装 `renv` 包。

## 目录结构

项目根目录保留的顶层文件和目录：

- `_targets.R`：targets 流程入口
- `README.md`：项目概述
- `.gitignore`：git 忽略规则
- `AGENTS.md`：项目级协作规则
- `config/`：配置层
- `R/`：可复用函数层
- `scripts/`：运行器、开发辅助工具和旧版脚本
- `docs/`：维护和使用说明
- `tests/`：最小测试框架
- `archive/`：归档的开发产物
- `data_raw/`：原始出现记录工作簿
- `data_clean/`：出现记录表的旧版兼容输出
- `env_raw/`：原始环境数据集
- `env_processed/`：处理后的环境栅格和研究区域文件
- `outputs/`：正式结果目录
- `renv.lock`：环境锁文件

### config/

- `config/species/`：物种级设置
- `config/regions/`：区域级设置
- `config/defaults/`：共享默认参数
- `config/runs/`：运行级组装文件
- `config/templates/`：新运行配置的模板

推荐关系：

- `species`：建模的物种
- `regions`：区域的显示或定义方式
- `defaults`：可复用的参数默认值
- `runs`：从物种、区域、默认值、输入文件和输出路径组装的具体运行

### scripts/

- `scripts/runners/`：唯一推荐的入口点
- `scripts/dev/`：调试、检查和临时辅助脚本
- `scripts/legacy/`：为兼容性和可追溯性保留的历史脚本

### outputs/

正式输出应从以下位置读取：

- `outputs/<run_id>/figures/`
- `outputs/<run_id>/tables/`
- `outputs/<run_id>/rasters/`
- `outputs/<run_id>/reports/`
- `outputs/<run_id>/biomod2_full/`
- `outputs/<run_id>/biomod2_matched/`

当前默认运行：

- `outputs/humpback_cosmonaut/`

## 正式输出 vs 旧版兼容

正式数据源：

- `outputs/<run_id>/...`

仅用于旧版兼容：

- `outputs/` 根目录下的历史文件
- `data_clean/` 下的历史出现记录表
- `env_processed/` 下的历史研究区域和栅格路径

新代码应使用 `R/config.R` 中的辅助函数，而非硬编码的输出路径。

## 快速开始

使用默认配置运行流程：

```r
Rscript scripts/runners/run_targets_pipeline.R config/runs/humpback_cosmonaut.R
```

运行最小测试：

```r
Rscript tests/testthat.R
```

## 环境说明

`renv.lock` 存在，但它是从已安装包生成的引导清单。
要获得完整的锁文件，请在本地安装 `renv` 并在项目根目录运行 `renv::snapshot()`。

## Excel 说明

如果 CSV 在 Excel 中打开时显示乱码，请优先使用可用的 `.xlsx` 版本。
