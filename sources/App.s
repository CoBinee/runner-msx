; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Title.inc"
    .include    "Game.inc"
    .include    "Debug.inc"

; 外部変数宣言
;
    .globl  _patternTable


; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; アプリケーションの初期化
    
    ; 画面表示の停止
    call    DISSCR
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; 割り込みの禁止
    di
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternTable + 0x0000)
    ld      d, #0x08
10$:
    ld      e, #0x10
11$:
    push    de
    ld      b, #0x08
    otir
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
    otir
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 11$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 10$
    
    ; パターンジェネレータの転送
    ld      hl, #(_patternTable + 0x0800)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE + 0x0000)
    ld      bc, #0x1000
    call    LDIRVM
    
    ; カラーテーブルの転送
    ld      hl, #appColorTable
    ld      de, #APP_COLOR_TABLE
    ld      bc, #0x0020
    call    LDIRVM

    ; パターンネームの初期化
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      a, #0x00
    ld      bc, #0x0300
    call    FILVRM

    ; 割り込み禁止の解除
    ei
    
    ; アプリケーションの初期化
    ld      hl, #appDefault
    ld      de, #_app
    ld      bc, #APP_LENGTH
    ldir

    ; 記録の初期化
    ld      hl, #(_appRecord + 0x0000)
    ld      de, #(_appRecord + 0x0002)
    ld      bc, #((APP_COURSE_ENTRY - 0x01) * APP_RECORD_LENGTH)
    ld      a, #0x1e
    ld      (_appRecord + APP_RECORD_TIME_L), a
    ld      a, #0x63
    ld      (_appRecord + APP_RECORD_TIME_H), a
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_app + APP_STATE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 更新の終了
99$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 処理なし
;
AppNull:

    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; コース番号を取得する
;
_AppGetCourseNumber::

    ; レジスタの保存
    push    hl
    push    bc

    ; de > コース番号

    ; コース番号の取得
    ld      a, (_app + APP_COURSE)
    inc     a
    jr      nz, 10$
    ld      de, #0x0256
    jr      19$
10$:
    ld      d, #0x00
    cp      #0x64
    jr      c, 11$
    sub     #0x64
    inc     d
11$:
    cp      #0x64
    jr      c, 12$
    sub     #0x64
    inc     d
12$:
    ld      c, a
    ld      b, #0x00
    ld      hl, #_appBcdNumber
    add     hl, bc
    ld      e, (hl)
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 記録を更新する
;
_AppUpdateRecord::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < 時間
    ; a  < コース
    ; cf > 更新した

    ; 記録の更新
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #_appRecord
    add     hl, bc
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    push    hl
    push    bc
    pop     hl
    pop     bc
    or      a
    sbc     hl, de
    jr      c, 10$
    jr      z, 10$
    ld      l, c
    ld      h, b
    ld      (hl), d
    dec     hl
    ld      (hl), e
    scf
    jr      11$
10$:
    or      a
;   jr      11$
11$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000111

; カラーテーブル
;
appColorTable:

    .db     0xf1, 0xf1
    .db     0xf1, 0xf1
    .db     0xf1, 0xf1
    .db     0xf1, 0xf1
    .db     0xb1, 0xb1
    .db     0xb1, 0xb1
    .db     0xf1, 0xf1
    .db     0xf1, 0xf1
    .db     0xc1, 0xc1
    .db     0xc1, 0xc1
    .db     0x81, 0x81
    .db     0x81, 0x81
    .db     0x81, 0x81
    .db     0x81, 0x81
    .db     0x81, 0x81
    .db     0x81, 0x81

; アプリケーションの初期値
;
appDefault:

    .db     APP_STATE_TITLE_INITIALIZE
;   .db     APP_STATE_GAME_INITIALIZE
;   .db     APP_STATE_DEBUG_INITIALIZE
    .db     APP_COURSE_NULL

; 状態別の処理
;
appProc:
    
    .dw     AppNull
    .dw     _TitleInitialize
    .dw     _TitleUpdate
    .dw     _GameInitialize
    .dw     _GameUpdate
    .dw     _DebugInitialize
    .dw     _DebugUpdate

; BCD 値
;
_appBcdNumber::

    .db     0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09
    .db     0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19
    .db     0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29
    .db     0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39
    .db     0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49
    .db     0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59
    .db     0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69
    .db     0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79
    .db     0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89
    .db     0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99

_appBcdMillisecond::

    .db     0x00, 0x03, 0x06
    .db     0x10, 0x13, 0x16    
    .db     0x20, 0x23, 0x26    
    .db     0x30, 0x33, 0x36    
    .db     0x40, 0x43, 0x46    
    .db     0x50, 0x53, 0x56    
    .db     0x60, 0x63, 0x66    
    .db     0x70, 0x73, 0x76    
    .db     0x80, 0x83, 0x86    
    .db     0x90, 0x93, 0x96    
    .db     0x99

_appBcdCentimeter::

    .db     0x00, 0x06, 0x12, 0x18, 0x25, 0x31, 0x37, 0x43, 0x50, 0x56, 0x62, 0x68, 0x75, 0x81, 0x87, 0x93


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; アプリケーション
;
_app::

    .ds     APP_LENGTH

; 記録
;
_appRecord::

    .ds     APP_COURSE_ENTRY * APP_RECORD_LENGTH
