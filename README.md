# codex_sdm

## 椤圭洰瀹氫綅

鏈」鐩凡鏁寸悊涓衡€滈厤缃┍鍔?+ 鍑芥暟灞?+ targets pipeline鈥濈殑閫氱敤 SDM 宸ョ▼銆?褰撳墠榛樿 run 浠嶅搴斿凡缁忚窇閫氱殑鈥滃骇澶撮哺 / 瀹囪埅鍛樿皟鏌?/ 鍗楁瀬娌垮哺鐮旂┒鍖衡€濆垎鏋愶紝浣嗙洰褰曞拰閰嶇疆宸茬粡鏀规垚渚夸簬鍚庣画鍒囨崲鐗╃銆佸尯鍩熷拰鍙傛暟鐨勫舰寮忋€?
## 椤圭洰鐩綍缁撴瀯

涓荤洰褰曞綋鍓嶄繚鐣欙細

- `_targets.R`锛歵argets pipeline 鍏ュ彛
- `README.md`锛氶」鐩鏄?- `.gitignore`锛欸it 蹇界暐瑙勫垯
- `AGENTS.md`锛氶」鐩骇鍗忎綔绾﹀畾
- `config/`锛氶厤缃眰
- `R/`锛氬嚱鏁板眰
- `scripts/`锛氳繍琛屽叆鍙ｃ€佽皟璇曡剼鏈拰 legacy 鑴氭湰
- `docs/`锛氱粨鏋勮鏄庝笌琛ュ厖鏂囨。
- `tests/`锛氭渶灏忔祴璇曢鏋?- `archive/`锛氬巻鍙茶皟璇曠粨鏋滃綊妗?- `data_raw/`锛氬師濮嬭娴嬫暟鎹?- `data_clean/`锛歭egacy compatibility 涓嬩繚鐣欑殑娓呮礂缁撴灉
- `env_raw/`锛氬師濮嬬幆澧冨彉閲?- `env_processed/`锛氬鐞嗗悗鐨勭爺绌跺尯涓庣幆澧冨彉閲忔爤
- `outputs/`锛氭寮忚緭鍑虹洰褰?- `renv.lock`锛氶」鐩幆澧冮攣瀹氭枃浠讹紙褰撳墠涓?bootstrap 鐗堬級

### config/ 鐨勫叧绯?
- `config/species/`锛氱墿绉嶉厤缃紝濡?`humpback.R`
- `config/regions/`锛氬尯鍩熼厤缃紝濡?`cosmonaut.R`
- `config/defaults/`锛氶粯璁ゅ弬鏁帮紝濡?`biomod_defaults.R`銆乣predictor_defaults.R`
- `config/runs/`锛歳un 绾ф嫾瑁呭叆鍙ｏ紝濡?`humpback_cosmonaut.R`
- `config/templates/`锛氭柊寤?run config 鐨勬ā鏉?
鎺ㄨ崘鐞嗚В鏂瑰紡锛?
- `species` 璐熻矗鈥滅爺绌朵粈涔堢墿绉嶁€?- `regions` 璐熻矗鈥滅爺绌跺尯濡備綍灞曠ず / 濡備綍瀹氫箟鈥?- `defaults` 璐熻矗鈥滈€氱敤鍙傛暟榛樿鍊尖€?- `runs` 璐熻矗鈥滄妸鐗╃銆佸尯鍩熴€佽緭鍏ユ枃浠跺拰杈撳嚭鐩綍鎷兼垚涓€娆″畬鏁磋繍琛屸€?
### scripts/ 鐨勫叧绯?
- `scripts/runners/`锛氬綋鍓嶆帹鑽愬叆鍙?- `scripts/dev/`锛氳皟璇曘€佹鏌ャ€佹祴璇曞拰涓存椂鑴氭湰
- `scripts/legacy/`锛氭棫鐗堥樁娈佃剼鏈拰鏃х増缁樺浘鑴氭湰

## 姝ｅ紡杈撳嚭璺緞涓?legacy 鍏煎

### 姝ｅ紡鐪熸簮

鏂扮殑姝ｅ紡杈撳嚭缁熶竴鍐欏叆锛?
- `outputs/<run_id>/figures/`
- `outputs/<run_id>/tables/`
- `outputs/<run_id>/rasters/`
- `outputs/<run_id>/reports/`
- `outputs/<run_id>/biomod2_full/`
- `outputs/<run_id>/biomod2_matched/`

褰撳墠榛樿 run 涓猴細`outputs/humpback_cosmonaut/`

### legacy compatibility

浠ヤ笅鏃ц矾寰勪粛淇濈暀锛屼絾鍙綔涓哄吋瀹瑰眰锛屼笉鍐嶆帹鑽愪綔涓烘寮忕湡婧愶細

- `outputs/` 鏍圭洰褰曚笅鐨勫巻鍙叉枃浠?- `data_clean/` 涓殑鍘嗗彶 occurrence 杈撳嚭
- `env_processed/` 涓殑鍘嗗彶 study area / predictor 鏍堣矾寰?
鍚庣画鏂板鑴氭湰鎴栧嚱鏁板簲浼樺厛浣跨敤 `R/config.R` 涓殑杈撳嚭璺緞杈呭姪鍑芥暟锛屼笉瑕佸啀鎵嬪啓鏃ц矾寰勩€?
## R/ 鐩綍涓殑鍑芥暟鍒嗗伐

- `R/config.R`锛氶厤缃鍙栥€侀粯璁?config銆佹寮忚緭鍑鸿矾寰勩€乴egacy 鍏煎璺緞
- `R/coords.R`锛氬潗鏍囪В鏋?- `R/io_occurrence.R`锛氭暟鎹鍙栦笌 occurrence 鏍囧噯鍖?- `R/qc.R`锛歰ccurrence 璐ㄦ帶
- `R/study_area.R`锛歴tudy area 鏋勫缓
- `R/predictors.R`锛歱redictor 鏍堣鍙栦笌鏁寸悊
- `R/biomod.R`锛氬彉閲忕瓫閫夈€乸seudo-absence銆乥iomod2 鍏ュ彛
- `R/plotting.R`锛氱粺涓€缁樺浘涓婚涓庣粯鍥捐緭鍑鸿緟鍔╁嚱鏁?- `R/pipeline_steps.R`锛氶樁娈电骇鍑芥暟灏佽

## 濡備綍鍒囨崲鐗╃

1. 澶嶅埗 `config/templates/run_config_template.R`
2. 淇濆瓨涓?`config/runs/<new_run_id>.R`
3. 淇敼 `species`銆乣input$workbooks`銆乣input$source_schemas`
4. 璁剧疆鏂扮殑 `outputs$run_dir`
5. 浣跨敤鏂扮殑 config 杩愯 pipeline

## 濡備綍鍒囨崲鐮旂┒鍖哄煙

1. 淇敼 run config 涓殑 `region` 閰嶇疆
2. 濡傞渶璋冩暣 analysis CRS 鎴栫紦鍐茶窛绂伙紝淇敼 `study_area`
3. 濡傞渶鏂版柟娉曪紝鍦?`R/study_area.R` 涓柊澧炲垎鏀紝骞跺湪 run config 涓垏鎹?
## 濡備綍杩愯鏁翠釜 pipeline

### 浣跨敤 targets

```r
Rscript scripts/runners/run_targets_pipeline.R config/runs/humpback_cosmonaut.R
```

涔熷彲浠ュ湪 R 浼氳瘽涓細

```r
Sys.setenv(SDM_CONFIG = "config/runs/humpback_cosmonaut.R")
targets::tar_make()
```

### 鍒嗛樁娈佃繍琛?
```r
Rscript scripts/runners/run_phase1_environment_check_config.R config/runs/humpback_cosmonaut.R
Rscript scripts/runners/run_phase2_standardize_occurrence_config.R config/runs/humpback_cosmonaut.R
Rscript scripts/runners/run_phase3_qc_studyarea_config.R config/runs/humpback_cosmonaut.R
```

## tests/ 鐨勭敤閫?
- `tests/testthat/test_config.R`锛氭鏌?run config 鏄惁鍙姞杞姐€佹寮忚緭鍑鸿矾寰勬槸鍚︽纭?- `tests/testthat/test_coords.R`锛氭鏌ュ潗鏍囪В鏋愭槸鍚﹁兘澶勭悊涓ょ鍏抽敭鏍煎紡
- `tests/testthat/test_qc.R`锛氭鏌?QC 鏄惁鑳借瘑鍒噸澶嶈褰曞拰缂哄け鍧愭爣

杩愯鏂瑰紡锛?
```r
Rscript tests/testthat.R
```

## renv.lock 鐨勭敤閫?
- `renv.lock` 鐢ㄤ簬閿佸畾椤圭洰渚濊禆鐗堟湰锛屼究浜庨暱鏈熷鐜般€?- 褰撳墠鏈満鏈畨瑁?`renv` 鍖咃紝鍥犳鏈」鐩敓鎴愮殑鏄?bootstrap 鐗?`renv.lock`锛屽熀浜庢湰鏈哄凡瀹夎鍖呮竻鍗曟瀯寤恒€?- 寤鸿鍚庣画鏈€灏忎慨澶嶆楠わ細瀹夎 `renv` 鍚庯紝鍦ㄩ」鐩牴鐩綍鎵ц `renv::snapshot()` 鐢熸垚姝ｅ紡閿佹枃浠躲€?
## 鍏煎绛栫暐

- 涓嶅垹闄ゆ棫鑴氭湰锛屽彧绉诲姩鍒?`scripts/legacy/`
- 涓嶅垹闄ゆ棫杈撳嚭锛屽彧淇濈暀涓?legacy compatibility
- 姝ｅ紡鐪熸簮缁熶竴涓?`outputs/<run_id>/`
- 鏂板鐗╃鎴栧尯鍩熸椂浼樺厛淇敼 `config/`锛屼笉瑕佺洿鎺ユ敼 `R/` 涓诲嚱鏁?
## 鏂囦欢鎵撳紑璇存槑

- 濡傛灉 CSV 鍦?Excel 涓贡鐮侊紝浼樺厛鎵撳紑 `.xlsx` 鏂囦欢銆?- 澶у瀷鍘熷鏁版嵁銆佺幆澧冨彉閲忓拰鏍呮牸缁撴灉榛樿涓嶅缓璁洿鎺ユ彁浜?GitHub锛岃瑙?`.gitignore`銆
## 当前稳定版状态

- 默认 run config 路径：`config/runs/humpback_cosmonaut.R`
- 默认正式输出目录：`outputs/humpback_cosmonaut/`
- 当前已知局限：
  - `outputs/` 根目录与 `data_clean/`、`env_processed/` 中仍保留 legacy compatibility 路径，正式真源应以 `outputs/<run_id>/` 为准
  - `scripts/legacy/` 中仍有旧版阶段脚本与旧版绘图脚本，保留用于追溯，不建议作为默认入口
  - `renv.lock` 当前为 bootstrap 版；如需完整环境锁定，后续应安装 `renv` 并执行 `renv::snapshot()`
  - 当前部分出版图逻辑仍位于 `scripts/legacy/`，后续若继续维护，建议逐步迁移到 `R/plotting.R`