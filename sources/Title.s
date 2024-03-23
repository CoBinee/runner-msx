; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
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
    
    ; タイトルの設定
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存

    ; 初期化処理
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x00)
    jr      nz, 09$

    ; ロゴの描画
    ld      hl, #titlePatternNameLogo
    ld      de, #(_patternName + 0x0080)
    ld      bc, #0x0040
    ldir

    ; ブロックの描画
    ld      hl, #(_patternName + 0x0200)
    ld      de, #(_patternName + 0x0201)
    ld      bc, #(0x0020 - 0x0001)
    ld      (hl), #0x88
    ldir

    ; コースの描画
    ld      hl, #titlePatternNameCourse
    ld      de, #(_patternName + 0x0264)
    ld      bc, #0x0012
    ldir
    ld      a, #0x3e
    ld      (_patternName + 0x024c), a
    ld      a, #0x3f
    ld      (_patternName + 0x028c), a

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; スプライトのクリア
    call    _SystemClearSprite

    ; キー入力待ち
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x01)
    jr      nz, 190$

    ; 点滅の更新
;   ld      hl, #(_title + TITLE_BLINK)
;   inc     (hl)

    ; SPACE キーの監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 109$

    ; サウンドの停止
    call    _SystemStopSound

    ; SE の再生
    ld      hl, #titleSoundStart
    ld      (_soundRequest + 0x0000), hl

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
    jr      190$
109$:

    ; ↑キーの監視
    ld      a, (_input + INPUT_KEY_UP)
    cp      #0x01
    jr      c, 119$
    jr      z, 110$
    sub     #0x08
    jr      c, 119$
    and     #0x01
    jr      nz, 111$
110$:
    ld      hl, #(_app + APP_COURSE)
    dec     (hl)
111$:
    ld      a, (_input + INPUT_KEY_UP)
    cp      #0x40
    jr      c, 112$
    sub     #0x02
    ld      (_input + INPUT_KEY_UP), a
112$:
    jr      190$
119$:

    ; ↓キーの監視
    ld      a, (_input + INPUT_KEY_DOWN)
    cp      #0x01
    jr      c, 129$
    jr      z, 120$
    sub     #0x08
    jr      c, 129$
    and     #0x01
    jr      nz, 121$
120$:
    ld      hl, #(_app + APP_COURSE)
    inc     (hl)
121$:
    ld      a, (_input + INPUT_KEY_DOWN)
    cp      #0x40
    jr      c, 122$
    sub     #0x02
    ld      (_input + INPUT_KEY_DOWN), a
122$:
    jr      190$
129$:

    ; ESC キーの監視
;   ld      a, (_input + INPUT_BUTTON_ESC)
;   dec     a
;   jr      nz, 139$

    ; 状態の更新
;   ld      a, #APP_STATE_DEBUG_INITIALIZE
;   ld      (_app + APP_STATE), a
;   jr      190$
139$:

    ; キー入力待ちの完了
190$:

    ; ゲームの開始
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x02)
    jr      nz, 29$

    ; 点滅の更新
    ld      hl, #(_title + TITLE_BLINK)
    ld      a, (hl)
    add     a, #0x04
    ld      (hl), a

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      a, h
    or      l
    jr      nz, 29$
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      nz, 29$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a

    ; ゲームの開始の完了
29$:    

    ; ロゴの描画
    ld      hl, #titleSpriteLogo
    ld      de, #(_sprite + TITLE_SPRITE_LOGO)
    ld      bc, #0x0008
    ldir

    ; コースの描画
    call    _AppGetCourseNumber
    ld      hl, #(_patternName + 0x26b)
    ld      a, d
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, e
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, e
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
;   inc     hl

    ; 記録の描画
    ld      a, (_app + APP_COURSE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appRecord
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      c, d
    ld      b, #0x00
    ld      hl, #_appBcdNumber
    add     hl, bc
    ld      d, (hl)
    ld      c, e
    ld      hl, #_appBcdMillisecond
    add     hl, bc
    ld      e, (hl)
    ld      hl, #(_patternName + 0x0271)
    ld      a, d
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, d
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    inc     hl
    inc     hl
    ld      a, e
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, e
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
;   inc     hl

    ; START の描画
    ld      a, (_title + TITLE_BLINK)
    and     #0x08
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #titlePatternNameStart
    add     hl, de
    ld      de, #(_patternName + 0x02a4)
    ld      bc, #0x0020
    ldir

    ; プレイヤの更新
    ld      hl, #(_title + TITLE_PLAYER)
    inc     (hl)

    ; プレイヤの描画
    ld      hl, #(_sprite + TITLE_SPRITE_PLAYER)
    ld      (hl), #0x6f
    inc     hl
    ld      a, (_title + TITLE_PLAYER)
    ld      (hl), a
    inc     hl
    and     #0x04
    add     a, #0x30
    ld      (hl), a
    inc     hl
    ld      (hl), #0x07
    inc     hl
    ld      (hl), #0x6f
    inc     hl
    ld      a, (_title + TITLE_PLAYER)
    add     a, #0x20
    ld      (hl), a
    inc     hl
    sub     #0x20
    and     #0x04
    add     a, #0x30
    ld      (hl), a
    inc     hl
    ld      (hl), #0x87
;   inc     hl

    ; 更新の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; タイトルの初期値
;
titleDefault:

    .db     TITLE_STATE_NULL
    .db     TITLE_BLINK_NULL
    .db     TITLE_PLAYER_NULL

; スプライト
;
titleSpriteLogo:

    .db     0x1f, 0x60, 0x94, 0x08
    .db     0x1f, 0x70, 0x80, 0x08

; パターンネーム
;
titlePatternNameLogo:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x46, 0x47, 0x4c, 0x4d, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x56, 0x57, 0x5c, 0x5d, 0x00, 0x00, 0x00, 0x00

titlePatternNameCourse:

    .db     0x23, 0x2f, 0x35, 0x32, 0x33, 0x25, 0x00, 0x10, 0x10, 0x11, 0x00, 0x0d, 0x00, 0x19, 0x19, 0x02, 0x19, 0x19

titlePatternNameStart:

    .db     0x28, 0x29, 0x34, 0x00, 0x33, 0x30, 0x21, 0x23, 0x25, 0x00, 0x22, 0x21, 0x32, 0x00, 0x34, 0x2f, 0x00, 0x33, 0x34, 0x21, 0x32, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; サウンド
;

; ゲームスタート
titleSoundStart:

    .ascii  "T1V15L3O6BO5BR9"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::
    
    .ds     TITLE_LENGTH
