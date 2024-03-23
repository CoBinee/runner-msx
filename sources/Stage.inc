; Stage.inc : ステージ
;


; マクロの定義
;

; ステージ
STAGE_ID                        =   0x00
STAGE_STATE                     =   0x01
STAGE_START_X_L                 =   0x02
STAGE_START_X_H                 =   0x03
STAGE_START_Y                   =   0x04
STAGE_GOAL_X_L                  =   0x05
STAGE_GOAL_X_H                  =   0x06
STAGE_GOAL_Y                    =   0x07
STAGE_SCROLL_L                  =   0x08
STAGE_SCROLL_H                  =   0x09
STAGE_RANDOM_L                  =   0x0a
STAGE_RANDOM_H                  =   0x0b
STAGE_FRAME                     =   0x0c
STAGE_LENGTH                    =   0x0d

; ID
STAGE_ID_NULL                   =   0x00

; 状態
STAGE_STATE_NULL                =   0x00

; 範囲
STAGE_REGION_TOP                =   0x00
STAGE_REGION_BOTTOM             =   0x7f
STAGE_REGION_LEFT               =   0x0000
STAGE_REGION_RIGHT              =   0x03af

; 位置
STAGE_POSITION_START_X          =   0x0048
STAGE_POSITION_START_Y          =   0x5f
STAGE_POSITION_GOAL_X           =   0x0368
STAGE_POSITION_GOAL_Y           =   0x5f

; オフセット
STAGE_OFFSET_X                  =   0x00
STAGE_OFFSET_Y                  =   0x20

; スクロール
STAGE_SCROLL_NULL               =   0x0000
STAGE_SCROLL_DISTANCE           =   0x0060
STAGE_SCROLL_LEFT               =   0x0000
STAGE_SCROLL_RIGHT              =   0x0300

; 乱数
STAGE_RANDOM_NULL               =   0x0000

; フレーム
STAGE_FRAME_NULL                =   0x00

; セル
STAGE_CELL_SIZE_X               =   0x40
STAGE_CELL_SIZE_Y               =   0x08
STAGE_CELL_NULL                 =   0x00
STAGE_CELL_BLOCK                =   0x01
STAGE_CELL_FIRE                 =   0x02

; パターンネーム
STAGE_NAME_SIZE_X               =   (STAGE_CELL_SIZE_X * 0x02)
STAGE_NAME_SIZE_Y               =   (STAGE_CELL_SIZE_Y * 0x02)

; ジェネレータ
STAGE_GENERATOR_CELL_L          =   0x00
STAGE_GENERATOR_CELL_H          =   0x01
STAGE_GENERATOR_X               =   0x02
STAGE_GENERATOR_Y               =   0x03
STAGE_GENERATOR_DISTANCE        =   0x04
STAGE_GENERATOR_PARAM_0         =   0x05
STAGE_GENERATOR_PARAM_1         =   0x06
STAGE_GENERATOR_PARAM_2         =   0x07
STAGE_GENERATOR_PARAM_3         =   0x08
STAGE_GENERATOR_LENGTH          =   0x09

; 外部関数宣言
;

    .globl  _StageInitialize
    .globl  _StageCreate
    .globl  _StageUpdate
    .globl  _StageRender
    .globl  _StageScroll
    .globl  _StageIsCell

; 外部変数宣言
;

    .globl  _stage
