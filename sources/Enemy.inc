; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_POSITION_X_L              =   0x02
ENEMY_POSITION_X_H              =   0x03
ENEMY_POSITION_Y                =   0x04
ENEMY_SPEED_X                   =   0x05
ENEMY_SPEED_Y                   =   0x06
ENEMY_DIRECTION                 =   0x07
ENEMY_SPRITE                    =   0x08
ENEMY_COLOR                     =   0x09
ENEMY_FRAME                     =   0x0a
ENEMY_LENGTH                    =   0x0b
ENEMY_ENTRY                     =   0x08

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_LOOP_HORIZON         =   0x01
ENEMY_TYPE_LOOP_VERTICAL        =   0x02

; 状態
ENEMY_STATE_NULL                =   0x00

; 位置
ENEMY_POSITION_NULL             =   0x00

; 向き
ENEMY_DIRECTION_MINUS           =   0x00
ENEMY_DIRECTION_PLUS            =   0x01

; 速度
ENEMY_SPEED_NULL                =   0x00

; 大きさ
ENEMY_R                         =   0x08

; スプライト
ENEMY_SPRITE_NULL               =   0x00
ENEMY_SPRITE_R                  =   0x08
ENEMY_SPRITE_LENGTH             =   (ENEMY_ENTRY * 0x04)

; 色
ENEMY_COLOR_NULL                =   0x00

; フレーム
ENEMY_FRAME_NULL                =   0x00
ENEMY_FRAME_LOOP_HORIZON        =   0x30
ENEMY_FRAME_LOOP_VERTICAL       =   0x30

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyEntry
    .globl  _EnemyIsHit

; 外部変数宣言
;

    .globl  _enemy

