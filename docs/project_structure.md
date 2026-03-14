# 椤圭洰缁撴瀯鏁寸悊璇存槑

## 鏈疆澧炲己鐩爣

鏈疆鍙仛鍙淮鎶ゆ€у寮猴紝涓嶉噸璺戜换浣曟暟鎹垎鏋愩€佺幆澧冨彉閲忓鐞嗘垨 biomod2 寤烘ā銆?
## outputs/<run_id>/ 鏄寮忚緭鍑虹湡婧?
褰撳墠椤圭洰宸叉槑纭細

- 姝ｅ紡鐪熸簮锛歚outputs/<run_id>/...`
- legacy compatibility锛歚outputs/` 鏍圭洰褰曘€乣data_clean/` 鍘嗗彶 CSV銆乣env_processed/` 鍘嗗彶鍥哄畾璺緞

榛樿 run 涓猴細`humpback_cosmonaut`

鎺ㄨ崘姝ｅ紡璇诲彇璺緞锛?
- `outputs/humpback_cosmonaut/figures/`
- `outputs/humpback_cosmonaut/tables/`
- `outputs/humpback_cosmonaut/rasters/`
- `outputs/humpback_cosmonaut/reports/`

## 閰嶇疆鎷嗗垎鍏崇郴

### species

- 淇濆瓨鐗╃灞備俊鎭?- 绀轰緥锛歚config/species/humpback.R`

### regions

- 淇濆瓨鍖哄煙灞曠ず鑼冨洿銆佺粡绾綉璁剧疆鍜?study area 鐩稿叧鍖哄煙鍙傛暟
- 绀轰緥锛歚config/regions/cosmonaut.R`

### defaults

- 淇濆瓨閫氱敤榛樿鍙傛暟
- 鐩墠鍖呮嫭锛?  - `config/defaults/biomod_defaults.R`
  - `config/defaults/predictor_defaults.R`

### runs

- run 绾у叆鍙ｅ彧璐熻矗鎷艰
- 褰撳墠绀轰緥锛歚config/runs/humpback_cosmonaut.R`

## 杈撳嚭璺緞杈呭姪鍑芥暟

`R/config.R` 涓凡鎻愪緵缁熶竴杈呭姪鍑芥暟锛?
- `sdm_default_config_path()`
- `sdm_load_config()`
- `sdm_build_run_paths()`
- `sdm_output_path()`
- `sdm_legacy_output_path()`
- `sdm_write_legacy_copy()`

寤鸿鍚庣画鎵€鏈?runner銆乸ipeline step 鍜?plotting 閫昏緫閮戒紭鍏堥€氳繃杩欎簺鍑芥暟鍙栬矾寰勶紝涓嶅啀鎵嬪啓 `outputs/...`銆?
## 浠嶄繚鐣?legacy 杈撳嚭璺緞鐨勫師鍥?
涓轰簡涓嶇牬鍧忓凡鏈夋垚鏋滃紩鐢紝褰撳墠浠嶄繚鐣欙細

- `outputs/` 鏍圭洰褰曠殑鍘嗗彶鏂囦欢
- `data_clean/` 涓殑鍘嗗彶 occurrence 杈撳嚭
- `env_processed/` 涓殑鍘嗗彶鏍呮牸涓?study area 璺緞

杩欎簺璺緞鐨勫畾浣嶆槸锛氬吋瀹瑰眰锛岃€屼笉鏄寮忕湡婧愩€?
## tests/ 鐨勪綔鐢?
褰撳墠宸插缓绔嬫渶灏忔祴璇曢鏋讹細

- `tests/testthat/test_config.R`
- `tests/testthat/test_coords.R`
- `tests/testthat/test_qc.R`
- `tests/testthat.R`

鐢ㄩ€旀槸璁╁悗缁敼鍔ㄨ嚦灏戣兘蹇€熸鏌ワ細

- config 鏄惁杩樿兘姝ｅ父鍔犺浇
- 鍧愭爣瑙ｆ瀽鏄惁浠嶈兘澶勭悊鍏抽敭鏍煎紡
- QC 鏄惁杩樿兘璇嗗埆閲嶅鍜岀己澶卞潗鏍?
## renv.lock 鐨勪綔鐢?
褰撳墠 `renv.lock` 宸茬敓鎴愶紝浣嗙敱浜庢湰鏈烘病鏈?`renv` 鍖咃紝鎵€浠ヨ繖鏄?bootstrap manifest 鐗堬紝鑰屼笉鏄€氳繃 `renv::snapshot()` 浜х敓鐨勫畬鏁撮攣鏂囦欢銆?
鍚庣画鏈€灏忎慨澶嶅缓璁細

1. 瀹夎 `renv`
2. 鍦ㄩ」鐩牴鐩綍鎵ц `renv::snapshot()`
3. 鐢ㄦ寮忛攣鏂囦欢鏇挎崲褰撳墠 bootstrap 鐗?`renv.lock`

## AGENTS.md 鐨勪綔鐢?
鏍圭洰褰曟柊澧?`AGENTS.md`锛岀敤浜庤褰曢」鐩骇鍗忎綔瑙勫垯锛屽寘鎷細

- 涓庣敤鎴蜂氦娴侀粯璁や娇鐢ㄤ腑鏂?- 缁撴灉姹囨姤蹇呴』甯︽槑纭矾寰?- 榛樿涓嶈閲嶈窇 biomod2
- 鏂板鐗╃鎴栧尯鍩熶紭鍏堜慨鏀?config
- 姝ｅ紡杈撳嚭缁熶竴鍐欏叆 `outputs/<run_id>/`
- 鍥句欢榛樿鐧藉簳
- 璋冭瘯鑴氭湰涓嶈鏀惧洖椤圭洰鏍圭洰褰
## scripts 目录使用约定

- `scripts/runners/`：唯一推荐入口
- `scripts/legacy/`：历史保留脚本，仅用于追溯和兼容
- `scripts/dev/`：调试、检查、测试和临时脚本，不作为正式运行入口