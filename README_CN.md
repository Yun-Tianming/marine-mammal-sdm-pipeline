# codex_sdm

[English](README.md) | 简体中文

## 概述

本仓库提供基于配置驱动的物种分布模型（SDM）分析流程，当前为稳定 v1 版本。
默认配置保留了已完成的座头鲸案例分析，项目结构已优化为可复用框架，支持不同物种和研究区域的建模需求。

## v1 版本状态

- 默认运行配置：`config/runs/humpback_cosmonaut.R`
- 正式输出目录：`outputs/humpback_cosmonaut/`
- `outputs/`、`data_clean/` 和 `env_processed/` 根目录下保留了旧版兼容路径，但已不再推荐使用
- `scripts/runners/` 为唯一推荐的流程入口
- `scripts/legacy/` 仅作历史追溯保留
- `renv.lock` 当前为引导性锁文件（本地环境暂未启用 `renv` 包管理）

## 目录结构

项目根目录主要文件和目录说明：

- `_targets.R`：targets 流程入口文件
- `README.md`：项目说明文档
- `.gitignore`：Git 版本控制忽略规则
- `AGENTS.md`：项目协作规范
- `config/`：配置文件目录
- `R/`：可复用函数库
- `scripts/`：脚本目录（包含运行器、开发工具和历史脚本）
- `docs/`：项目文档
- `tests/`：测试框架
- `archive/`：历史开发文件归档
- `data_raw/`：原始物种出现记录
- `data_clean/`：清洗后的出现记录（旧版兼容）
- `env_raw/`：原始环境数据
- `env_processed/`：处理后的环境栅格和研究区域
- `outputs/`：模型输出结果
- `renv.lock`：R 包环境锁定文件

### config/

配置文件组织结构：

- `config/species/`：物种参数配置
- `config/regions/`：研究区域配置
- `config/defaults/`：共享默认参数
- `config/runs/`：具体运行配置
- `config/templates/`：新配置模板

配置层级关系：

- `species`：定义目标物种的建模参数
- `regions`：定义研究区域的范围和展示方式
- `defaults`：提供可复用的参数默认值
- `runs`：整合物种、区域、默认参数、输入文件和输出路径的完整运行配置

### scripts/

- `scripts/runners/`：推荐的流程入口脚本
- `scripts/dev/`：开发调试和辅助工具
- `scripts/legacy/`：历史脚本（仅作兼容性保留）

### outputs/

正式输出结果的标准路径：

- `outputs/<run_id>/figures/` - 图表
- `outputs/<run_id>/tables/` - 数据表
- `outputs/<run_id>/rasters/` - 栅格文件
- `outputs/<run_id>/reports/` - 分析报告
- `outputs/<run_id>/biomod2_full/` - 完整 biomod2 模型
- `outputs/<run_id>/biomod2_matched/` - 匹配后的 biomod2 模型

当前默认运行输出：

- `outputs/humpback_cosmonaut/`

## 正式输出与旧版兼容

推荐使用的数据源：

- `outputs/<run_id>/...` - 所有正式输出结果

仅作旧版兼容保留：

- `outputs/` 根目录下的历史文件
- `data_clean/` 下的历史出现记录
- `env_processed/` 下的历史环境数据路径

新代码应使用 `R/config.R` 中的配置辅助函数，避免硬编码输出路径。

## 快速开始

运行默认配置的完整流程：

```r
Rscript scripts/runners/run_targets_pipeline.R config/runs/humpback_cosmonaut.R
```

运行测试：

```r
Rscript tests/testthat.R
```

## 环境管理

项目包含 `renv.lock` 文件，但当前为引导性清单（从已安装包生成）。
如需完整的包管理，请安装 `renv` 包并在项目根目录运行 `renv::snapshot()`。

## Excel 文件说明

若 CSV 文件在 Excel 中显示乱码，请优先使用对应的 `.xlsx` 格式文件。
