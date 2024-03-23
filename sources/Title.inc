; Title.inc : タイトル
;


; マクロの定義
;

; タイトル
TITLE_STATE                     =   0x00
TITLE_BLINK                     =   0x01
TITLE_PLAYER                    =   0x02
TITLE_LENGTH                    =   0x03

; 状態
TITLE_STATE_NULL                =   0x00

; 点滅
TITLE_BLINK_NULL                =   0x00

; プレイヤ
TITLE_PLAYER_NULL               =   0x00

; スプライト
TITLE_SPRITE_LOGO               =   0x00
TITLE_SPRITE_PLAYER             =   0x10

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

    .globl  _title
