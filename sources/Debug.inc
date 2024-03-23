; Debug.inc : デバッグ
;


; マクロの定義
;

; デバッグ
DEBUG_STATE                     =   0x00
DEBUG_FRAME                     =   0x01
DEBUG_CURSOR                    =   0x02
DEBUG_LENGTH                    =   0x03

; 状態
DEBUG_STATE_NULL                =   0x00

; フレーム
DEBUG_FRAME_NULL                =   0x00

; カーソル
DEBUG_CURSOR_LENGTH             =   0x18

; 外部関数宣言
;

    .globl  _DebugInitialize
    .globl  _DebugUpdate

; 外部変数宣言
;

    .globl  _debug
