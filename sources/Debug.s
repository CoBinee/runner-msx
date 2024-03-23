; Debug.s : デバッグ
;


; モジュール宣言
;
    .module Debug

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Debug.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; デバッグを初期化する
;
_DebugInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; パターンネームの転送
    ld      hl, #_patternName
    ld      de, #APP_PATTERN_NAME_TABLE
    ld      bc, #0x0300
    call    LDIRVM

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; サウンドの停止
    call    _SystemStopSound
    
    ; デバッグの設定
    ld      hl, #debugDefault
    ld      de, #_debug
    ld      bc, #DEBUG_LENGTH
    ldir

    ; 状態の更新
    ld      a, #APP_STATE_DEBUG_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; デバッグを更新する
;
_DebugUpdate::
    
    ; レジスタの保存

    ; 初期化処理
    ld      a, (_debug + DEBUG_STATE)
    cp      #(DEBUG_STATE_NULL + 0x00)
    jr      nz, 09$

    ; サウンドの初期化
    ld      hl, #debugSoundDefault
    ld      de, #debugSoundWork
    ld      bc, #DEBUG_CURSOR_LENGTH
    ldir

    ; 初期化の完了
    ld      hl, #(_debug + DEBUG_STATE)
    inc     (hl)
09$:

    ; カーソルの移動
    ld      hl, #(_debug + DEBUG_CURSOR)
    ld      a, (_input + INPUT_KEY_LEFT)
    dec     a
    jr      nz, 10$
    dec     (hl)
    ld      a, (hl)
    cp      #DEBUG_CURSOR_LENGTH
    jr      c, 19$
    ld      a, #(DEBUG_CURSOR_LENGTH - 0x01)
    ld      (hl), a
    jr      19$
10$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    dec     a
    jr      nz, 19$
    inc     (hl)
    ld      a, (hl)
    cp      #DEBUG_CURSOR_LENGTH
    jr      c, 19$
    xor     a
    ld      (hl), a
;   jr      19$
19$:

    ; サウンドの編集
20$:
    call    CHSNS
    jr      z, 29$
    call    CHGET
    cp      #0x20
    jr      c, 20$
    cp      #0x60
    jr      c, 21$
    cp      #'a
    jr      c, 20$
    cp      #('z + 0x01)
    jr      nc, 20$
    sub     #('a - 'A)
21$:
    ld      c, a
    ld      a, (_debug + DEBUG_CURSOR)
    ld      e, a
    ld      d, #0x00
    ld      hl, #debugSoundWork
    add     hl, de
    ld      (hl), c
    inc     a
    cp      #DEBUG_CURSOR_LENGTH
    jr      c, 22$
    xor     a
22$:
    ld      (_debug + DEBUG_CURSOR), a
29$:

    ; サウンドの再生
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    dec     a
    jr      nz, 39$
    ld      hl, #debugSoundWork
    ld      de, #debugSoundPlay
    ld      b, #DEBUG_CURSOR_LENGTH
30$:
    ld      a, (hl)
    cp      #0x20
    jr      z, 31$
    ld      (de), a
    inc     hl
    inc     de
    djnz    30$
31$:
    xor     a
    ld      (de), a
    ld      hl, #debugSoundPlay
    ld      (_soundRequest + 0x0006), hl
39$:    

    ; ESC キーの監視
40$:
    ld      a, (_input + INPUT_BUTTON_ESC)
    dec     a
    jr      nz, 49$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
49$:

    ; サウンドの描画
    ld      hl, #debugSoundWork
    ld      de, #(_patternName + 0x0164)
    ld      b, #DEBUG_CURSOR_LENGTH
80$:
    ld      a, (hl)
    sub     #0x20
    ld      (de), a
    inc     hl
    inc     de
    djnz    80$

    ; カーソルの描画
    ld      hl, #(_patternName + 0x0184)
    ld      bc, #((DEBUG_CURSOR_LENGTH << 8) | 0x0000)
81$:
    ld      a, (_debug + DEBUG_CURSOR)
    cp      c
    jr      z, 82$
    xor     a
    jr      83$
82$:
    ld      a, #0x3e
83$:
    ld      (hl), a
    inc     hl
    inc     c
    djnz    81$

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; デバッグの初期値
;
debugDefault:

    .db     DEBUG_STATE_NULL
    .db     DEBUG_FRAME_NULL
    .db     0x00

; サウンド
;
debugSoundDefault:

    .ascii  "T1V15O4C1               "


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; デバッグ
;
_debug::
    
    .ds     DEBUG_LENGTH

; サウンド
;
debugSoundPlay:

    .ds     0x20

debugSoundWork:

    .ds     0x20
