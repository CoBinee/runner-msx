; Game.inc : ゲーム
;


; マクロの定義
;

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_REQUEST                    =   0x02
GAME_SOUND                      =   0x03
GAME_TIME_L                     =   0x04
GAME_TIME_H                     =   0x05
GAME_DISTANCE_L                 =   0x06
GAME_DISTANCE_H                 =   0x07
GAME_INFORMATION                =   0x08
GAME_MENU                       =   0x09
GAME_SPRITE                     =   0x0a
GAME_FRAME                      =   0x0b
GAME_LENGTH                     =   0x0c

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_OVER                 =   0x30
GAME_STATE_CLEAR                =   0x40
GAME_STATE_MENU                 =   0x50
GAME_STATE_END                  =   0x60

; フラグ
GAME_FLAG_NULL                  =   0x00

; リクエスト
GAME_REQUEST_NULL               =   0x00

; 時間
GAME_TIME_NULL                  =   0x0000

; 距離
GAME_DISTANCE_NULL              =   0x0000

; インフォメーション
GAME_INFORMATION_NULL           =   0x00
GAME_INFORMATION_READY          =   0x00
GAME_INFORMATION_GO             =   0x01
GAME_INFORMATION_MISS           =   0x02
GAME_INFORMATION_GOAL           =   0x03
GAME_INFORMATION_BESTTIME       =   0x04

; メニュー
GAME_MENU_NULL                  =   0x00
GAME_MENU_NEXT                  =   0x00
GAME_MENU_RETRY                 =   0x01
GAME_MENU_BACK                  =   0x02
GAME_MENU_LENGTH                =   0x03

; フレーム
GAME_FRAME_NULL                 =   0x00

; スプライト
GAME_SPRITE_TIME                =   0x00
GAME_SPRITE_DISTANCE            =   0x08
GAME_SPRITE_INFORMATION         =   0x10
GAME_SPRITE_PLAYER              =   0x30
GAME_SPRITE_ENEMY               =   0x40
GAME_SPRITE_STARTGOAL           =   0x7c
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_ENTRY               =   0x08
GAME_SPRITE_LENGTH              =   (GAME_SPRITE_ENTRY * 0x04)

; サウンド
GAME_SOUND_NULL                 =   0x00
GAME_SOUND_BGM_THEME            =   0x01
GAME_SOUND_BGM_OVER             =   0x02
GAME_SOUND_BGM_CLEAR            =   0x03
GAME_SOUND_SE_CLICK             =   0x01
GAME_SOUND_SE_JUMP              =   0x02

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameGetSpriteXec
    .globl  _GamePlayBgm
    .globl  _GamePlaySe

; 外部変数宣言
;

    .globl  _game
