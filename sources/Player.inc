; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X_L             =   0x02
PLAYER_POSITION_X_H             =   0x03
PLAYER_POSITION_Y               =   0x04
PLAYER_POSITION_Y_LAST          =   0x05
PLAYER_SPEED_X                  =   0x06
PLAYER_SPEED_Y                  =   0x07
PLAYER_DIRECTION                =   0x08
PLAYER_JUMP                     =   0x09
PLAYER_LAND                     =   0x0a
PLAYER_SPRITE                   =   0x0b
PLAYER_COLOR                    =   0x0c
PLAYER_ANIMATION                =   0x0d
PLAYER_LENGTH                   =   0x0e

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_PLAY               =   0x10
PLAYER_STATE_MISS               =   0x20
PLAYER_STATE_GOAL               =   0x30

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_PLAY_BIT            =   0x00
PLAYER_FLAG_PLAY                =   (1 << PLAYER_FLAG_PLAY_BIT)
PLAYER_FLAG_GOAL_BIT            =   0x01
PLAYER_FLAG_GOAL                =   (1 << PLAYER_FLAG_GOAL_BIT)
PLAYER_FLAG_MISS_FALL_BIT       =   0x02
PLAYER_FLAG_MISS_FALL           =   (1 << PLAYER_FLAG_MISS_FALL_BIT)
PLAYER_FLAG_MISS_TOUCH_BIT      =   0x03
PLAYER_FLAG_MISS_TOUCH          =   (1 << PLAYER_FLAG_MISS_TOUCH_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 範囲
PLAYER_REGION_TOP               =   0xc0
PLAYER_REGION_BOTTOM            =   0xaf
PLAYER_REGION_LEFT              =   0x0008
PLAYER_REGION_RIGHT             =   0x03f8

; 大きさ
PLAYER_SIZE_X                   =   0x07
PLAYER_SIZE_Y                   =   0x0e

; 速度 > 5:3 bits
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_X_MAXIMUM          =   0x20
PLAYER_SPEED_X_ACCEL            =   0x04
PLAYER_SPEED_X_BRAKE            =   0x02
PLAYER_SPEED_Y_MAXIMUM          =   0x40
PLAYER_SPEED_Y_JUMP             =   -0x30
PLAYER_SPEED_Y_GRAVITY          =   0x08
PLAYER_SPEED_Y_FLOAT            =   0x01
PLAYER_SPEED_Y_MISS             =   0x06

; 向き
PLAYER_DIRECTION_MINUS          =   0x00
PLAYER_DIRECTION_PLUS           =   0x01

; ジャンプ
PLAYER_JUMP_NULL                =   0x00
PLAYER_JUMP_LENGTH              =   0x08

; 着地
PLAYER_LAND_NULL                =   0x00
PLAYER_LAND_DELAY               =   0x02

; スプライト
PLAYER_SPRITE_NULL              =   0x00
PLAYER_SPRITE_SIZE_X            =   0x08
PLAYER_SPRITE_SIZE_Y            =   0x0f

; 色
PLAYER_COLOR_NULL               =   0x0f

; アニメーション   
PLAYER_ANIMATION_NULL           =   0x00

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerIsAlive
    .globl  _PlayerIsPlay
    .globl  _PlayerIsGoal

; 外部変数宣言
;

    .globl  _player

