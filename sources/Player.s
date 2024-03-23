; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Stage.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; ゴールの判定
    call    PlayerCheckGoal

    ; ミスの判定
    call    PlayerCheckMiss
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      z, 10$
    ld      hl, #(_sprite + GAME_SPRITE_PLAYER)
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, #(STAGE_OFFSET_Y - (PLAYER_SPRITE_SIZE_Y + 0x01))
    ld      (hl), a
    inc     hl
    push    hl
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      de, (_stage + STAGE_SCROLL_L)
    or      a
    sbc     hl, de
    ld      a, l
    add     #(STAGE_OFFSET_X - PLAYER_SPRITE_SIZE_X)
    pop     hl
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_SPRITE)
    ld      (hl), a
    inc     hl
    ld      a, (_player + PLAYER_COLOR)
    ld      (hl), a
;   inc     hl
10$:

    ; レジスタの復帰

    ; 終了
    ret
    
; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 位置の設定
    ld      hl, (_stage + STAGE_START_X_L)
    ld      (_player + PLAYER_POSITION_X_L), hl
    ld      a, (_stage + STAGE_START_Y)
    ld      (_player + PLAYER_POSITION_Y), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 左右の加速
100$:
    ld      hl, #(_player + PLAYER_SPEED_X)
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 101$
    ld      a, #PLAYER_DIRECTION_MINUS
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (hl)
    sub     #PLAYER_SPEED_X_ACCEL
    jp      p, 108$
    cp      #-PLAYER_SPEED_X_MAXIMUM
    jr      nc, 108$
    ld      a, #-PLAYER_SPEED_X_MAXIMUM
    jr      108$
101$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 102$
    ld      a, #PLAYER_DIRECTION_PLUS
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (hl)
    add     a, #PLAYER_SPEED_X_ACCEL
    jp      m, 108$
    cp      #(PLAYER_SPEED_X_MAXIMUM + 0x01)
    jr      c, 108$
    ld      a, #PLAYER_SPEED_X_MAXIMUM
    jr      108$
102$:
    ld      a, (hl)
    or      a
    jr      z, 109$
    jp      p, 103$
    add     a, #PLAYER_SPEED_X_BRAKE
    jr      nc, 108$
    xor     a
    jr      108$
103$:
    sub     #PLAYER_SPEED_X_BRAKE
    jr      nc, 108$
    xor     a
;   jr      108$
108$:
    ld      (hl), a
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_PLAY_BIT, (hl)
;   jr      109$
109$:

    ; 上下の加速
110$:
    ld      hl, #(_player + PLAYER_SPEED_Y)
    ld      a, (_player + PLAYER_LAND)
    or      a
    jr      z, 111$
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 113$
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_PLAY_BIT, (hl)
    xor     a
    ld      (_player + PLAYER_LAND), a
    ld      a, #PLAYER_JUMP_LENGTH
    ld      (_player + PLAYER_JUMP), a
    ld      a, #PLAYER_SPEED_Y_JUMP
    ld      (_player + PLAYER_SPEED_Y), a
    ld      a, #GAME_SOUND_SE_JUMP
    call    _GamePlaySe
    jr      119$
111$:
    ld      a, (hl)
    or      a
    jp      p, 113$
    ld      a, (_player + PLAYER_JUMP)
    or      a
    jr      z, 113$
    ld      c, a
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 112$
    dec     c
    ld      a, c
    ld      (_player + PLAYER_JUMP), a
    ld      a, #PLAYER_SPEED_Y_FLOAT
    jr      114$
112$:
;   xor     a
    ld      (_player + PLAYER_JUMP), a
113$:
    ld      a, #PLAYER_SPEED_Y_GRAVITY
114$:
    add     a, (hl)
    jp      m, 115$
    cp      #(PLAYER_SPEED_Y_MAXIMUM + 0x01)
    jr      c, 115$
    ld      a, #PLAYER_SPEED_Y_MAXIMUM
115$:
    ld      (hl), a
;   jr      119$
119$:

    ; 左右の移動
120$:
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      a, (_player + PLAYER_SPEED_X)
    sra     a
    sra     a
    sra     a
    ld      e, a
    ld      d, #0x00
    jp      p, 121$
    dec     d
121$:
    add     hl, de
    ex      de, hl
    ld      hl, (_stage + STAGE_SCROLL_L)
    ld      bc, #0x0008
    add     hl, bc
    or      a
    sbc     hl, de
    jr      c, 122$
    add     hl, de
    ex      de, hl
122$:
    ld      l, e
    ld      h, d
    ld      bc, #PLAYER_REGION_RIGHT
    or      a
    sbc     hl, bc
    jr      c, 123$
    ld      e, c
    ld      d, b
123$:
    ld      (_player + PLAYER_POSITION_X_L), de

    ; 上下の移動
130$:
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      de, #(_player + PLAYER_SPEED_Y)
    ld      a, (hl)
    ld      (_player + PLAYER_POSITION_Y_LAST), a
    ld      b, a
    ld      a, (de)
    sra     a
    sra     a
    sra     a
    add     a, (hl)
    ld      (hl), a
    ld      c, a
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jp      m, 132$
    jr      z, 132$
    ld      a, b
    and     #0xf0
    ld      b, a
    ld      a, c
    and     #0xf0
    cp      b
    jr      z, 132$
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      de, #-PLAYER_SIZE_X
    add     hl, de
    ex      de, hl
    ld      b, #STAGE_CELL_BLOCK
    call    _StageIsCell
    jr      c, 131$
    ld      hl, #(PLAYER_SIZE_X * 0x02 - 0x01)
    add     hl, de
    ex      de, hl
    call    _StageIsCell
    jr      nc, 132$
131$:
    ld      a, c
    and     #0xf0
    dec     a
    ld      (_player + PLAYER_POSITION_Y), a
    xor     a
    ld      (_player + PLAYER_SPEED_Y), a
    ld      hl, #(_player + PLAYER_LAND)
    ld      (hl), #PLAYER_LAND_DELAY
    jr      139$
132$:
    ld      hl, #(_player + PLAYER_LAND)
    ld      a, (hl)
    or      a
    jr      z, 139$
    dec     (hl)
    jr      z, 139$
    ld      a, (_player + PLAYER_SPEED_X)
    cp      #PLAYER_SPEED_X_MAXIMUM
    jr      z, 133$
    cp      #-PLAYER_SPEED_X_MAXIMUM
    jr      nz, 139$
133$:
    ld      a, (_player + PLAYER_POSITION_Y_LAST)
    ld      (_player + PLAYER_POSITION_Y), a
;   jr      139$
139$:


    ; スクロール
    ld      de, (_player + PLAYER_POSITION_X_L)
    call    _StageScroll

    ; アニメーションの設定
20$:
    ld      a, (_player + PLAYER_LAND)
    or      a
    jr      z, 22$
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, (_player + PLAYER_SPEED_X)
    or      a
    jr      z, 29$
    jp      p, 21$
    neg
21$:
    add     a, (hl)
    ld      (hl), a
    rrca
    rrca
    rrca
    rrca
    and     #0x04
    jr      29$
22$:
    ld      a, #0x08
29$:
    ld      c, a
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, c
    add     a, #0x20
    ld      (_player + PLAYER_SPRITE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがミスする
;
PlayerMiss:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 接触でのミス
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MISS_TOUCH_BIT, a
    jr      z, 00$
    ld      a, #PLAYER_SPEED_Y_JUMP
    ld      (_player + PLAYER_SPEED_Y), a
    ld      a, #0x2c
    ld      (_player + PLAYER_SPRITE), a
00$:

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 落下
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      de, #(_player + PLAYER_SPEED_Y)
    ld      a, (de)
    sra     a
    sra     a
    sra     a
    add     a, (hl)
    ld      (hl), a
    ld      a, (de)
    add     a, #PLAYER_SPEED_Y_MISS
    jp      m, 10$
    cp      #PLAYER_SPEED_Y_MAXIMUM
    jr      c, 10$
    ld      a, #PLAYER_SPEED_Y_MAXIMUM
10$:
    ld      (de), a
    ld      a, (hl)
    cp      #PLAYER_REGION_TOP
    jr      nc, 19$
    cp      #PLAYER_REGION_BOTTOM
    jr      c, 19$

    ; ミスの完了
    xor     a
    ld      (_player + PLAYER_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゴールする
;
PlayerGoal:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; スプライトの設定
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x20
    ld      (_player + PLAYER_SPRITE), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが存在するかどうかを取得する
;
_PlayerIsAlive::

    ; レジスタの保存

    ; cf > 存在する

    ; 存在の判定
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが行動を始めたかどうかを取得する
;
_PlayerIsPlay::

    ; レジスタの保存

    ; cf > 行動を開始した

    ; 行動の判定
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_PLAY_BIT, a
    jr      z, 10$
    scf
    jr      11$
10$:
    or      a
;   jr      11$
11$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゴールしたかどうかを取得する
;
_PlayerIsGoal::

    ; レジスタの保存

    ; cf > ゴールした

    ; ゴールの判定
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_GOAL_BIT, a
    jr      z, 10$
    scf
    jr      11$
10$:
    or      a
;   jr      11$
11$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゴールしたかどうかを判定する
;
PlayerCheckGoal:

    ; レジスタの保存
    push    hl
    push    de

    ; プレイ中の判定
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    cp      #PLAYER_STATE_PLAY
    jr      nz, 19$

    ; 接地の判定
    ld      a, (_player + PLAYER_LAND)
    or      a
    jr      z, 19$

    ; 位置の判定
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      de, (_stage + STAGE_GOAL_X_L)
    or      a
    sbc     hl, de
    jr      c, 19$

    ; ゴールした
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_GOAL_BIT, (hl)
;   ld      a, #PLAYER_STATE_GOAL
;   ld      (_player + PLAYER_STATE), a

    ; 判定の完了
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤがミスしたかどうかを判定する
;
PlayerCheckMiss:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; プレイ中の判定
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    cp      #PLAYER_STATE_PLAY
    jr      nz, 19$

    ; フラグの取得
    ld      hl, #(_player + PLAYER_FLAG)

    ; 落下の判定
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      #PLAYER_REGION_TOP
    jr      nc, 10$
    cp      #(PLAYER_REGION_BOTTOM + 0x01)
    jr      c, 10$
    set     #PLAYER_FLAG_MISS_FALL_BIT, (hl)
    ld      a, #PLAYER_STATE_MISS
    ld      (_player + PLAYER_STATE), a
    jr      19$
10$:

    ; 炎との判定
    ld      de, (_player + PLAYER_POSITION_X_L)
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #(PLAYER_SIZE_Y / 0x02)
    ld      c, a
    ld      b, #STAGE_CELL_FIRE
    call    _StageIsCell
    jr      c, 11$

    ; エネミーとの判定
    call    _EnemyIsHit
    jr      nc, 19$
11$:
    set     #PLAYER_FLAG_MISS_TOUCH_BIT, (hl)
    ld      a, #PLAYER_STATE_MISS
    ld      (_player + PLAYER_STATE), a
;   jr      19$

    ; 判定の完了
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerPlay
    .dw     PlayerMiss
    .dw     PlayerGoal

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_PLAY
    .db     PLAYER_FLAG_NULL
    .dw     PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_DIRECTION_PLUS
    .db     PLAYER_JUMP_NULL
    .db     PLAYER_LAND_NULL
    .db     PLAYER_SPRITE_NULL
    .db     0x07 ; PLAYER_COLOR_NULL
    .db     PLAYER_ANIMATION_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH
