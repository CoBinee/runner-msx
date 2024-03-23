; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Stage.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      de, #_enemy
    ld      a, #ENEMY_ENTRY
10$:
    ld      hl, #enemyDefaultNull
    ld      bc, #ENEMY_LENGTH
    ldir
    dec     a
    jr      nz, 10$

    ; スプライトの初期化
    xor     a
    ld      (enemySprite), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; 種類別の処理
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    ld      hl, #19$
    push    hl
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
19$:

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_enemy
    ld      a, (enemySprite)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    push    de
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      de, #-ENEMY_SPRITE_R
    add     hl, de
    ex      de, hl
    call    _GameGetSpriteXec
    ex      de, hl
    pop     de
    jr      nc, 19$
    ld      c, l
    ld      b, h
    ld      hl,  #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, #(STAGE_OFFSET_Y - (ENEMY_SPRITE_R + 0x01))
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      a, ENEMY_SPRITE(ix)
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_COLOR(ix)
    or      c
    ld      (hl), a
;   inc     hl
    ld      a, e
    add     a, #0x04
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 12$
    xor     a
12$:
    ld      e, a
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      hl, #enemySprite
    ld      a, (hl)
    add     a, #0x04
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを登録する
;
_EnemyEntry::

    ; レジスタの保存

    ; de < X 位置
    ; c  < Y 位置
    ; a  < エネミーの種類

    ; 引数の保存
    ld      l, a

    ; 空いているエネミーの取得
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    push    de
    ld      de, #ENEMY_LENGTH
    add     ix, de
    pop     de
    djnz    10$
    jr      19$

    ; エネミーの登録
11$:
    push    hl
    push    bc
    push    de
    ld      a, l
    add     a, a
    ld      l, a
    ld      h, #0x00
    ld      de, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ex      de, hl
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc
    pop     hl
    ld      ENEMY_POSITION_X_L(ix), e
    ld      ENEMY_POSITION_X_H(ix), d
    ld      ENEMY_POSITION_Y(ix), c
;   jr      19$

    ; 登録の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが左右に移動する
;
EnemyLoopHorizon:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 接近の判定
    call    EnemyIsNear
    jr      nc, 90$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    ld      d, #0x00
    ld      a, ENEMY_SPEED_X(ix)
    or      a
    jp      p, 10$
    dec     d
10$:
    ld      e, a
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    add     hl, de
    ld      ENEMY_POSITION_X_L(ix), l
    ld      ENEMY_POSITION_X_H(ix), h

    ; フレームの更新
    dec     ENEMY_FRAME(ix)
    jr      nz, 11$
    ld      a, #ENEMY_FRAME_LOOP_HORIZON
    ld      ENEMY_FRAME(ix), a

    ; 反転
    ld      a, ENEMY_SPEED_X(ix)
    neg
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_DIRECTION(ix)
    xor     #0x01
    ld      ENEMY_DIRECTION(ix), a
11$:

    ; スプライトの更新
    ld      a, ENEMY_FRAME(ix)
    and     #0x04
    add     a, #0x10
    ld      ENEMY_SPRITE(ix), a

    ; 行動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが上下に移動する
;
EnemyLoopVertical:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 接近の判定
    call    EnemyIsNear
    jr      nc, 90$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    ld      a, ENEMY_SPEED_Y(ix)
    add     a, ENEMY_POSITION_Y(ix)
    ld      ENEMY_POSITION_Y(ix), a

    ; フレームの更新
    dec     ENEMY_FRAME(ix)
    jr      nz, 11$
    ld      a, #ENEMY_FRAME_LOOP_VERTICAL
    ld      ENEMY_FRAME(ix), a

    ; 反転
    ld      a, ENEMY_SPEED_Y(ix)
    neg
    ld      ENEMY_SPEED_Y(ix), a
    ld      a, ENEMY_DIRECTION(ix)
    xor     #0x01
    ld      ENEMY_DIRECTION(ix), a
11$:

    ; スプライトの更新
    ld      a, ENEMY_FRAME(ix)
    and     #0x04
    add     a, #0x10
    ld      ENEMY_SPRITE(ix), a

    ; 行動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが近づいたかどうかを判定する
;
EnemyIsNear:

    ; レジスタの保存
    push    hl
    push    de

    ; cf > 近づいた

    ; 接近の判定
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      de, (_stage + STAGE_SCROLL_L)
    or      a
    sbc     hl, de
    jr      c, 10$
    ld      de, #(0x0100 + ENEMY_R)
    or      a
    sbc     hl, de
    jr      c, 10$
    or      a
    jr      19$
10$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エネミーとのコリジョンを判定する
;
_EnemyIsHit::

    ; レジスタの保存
    push    hl
    push    bc
    push    ix

    ; de < X 位置
    ; c  < Y 位置
    ; cf > ヒットした

    ; エネミーとの判定
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      bc, #-ENEMY_R
    add     hl, bc
    pop     bc
    or      a
    sbc     hl, de
    jr      nc, 11$
    push    bc
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      bc, #(ENEMY_R - 0x01)
    add     hl, bc
    pop     bc
    or      a
    sbc     hl, de
    jr      c, 11$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     #ENEMY_R
    cp      c
    jr      nc, 11$
    add     a, #(ENEMY_R * 0x02 - 0x01)
    cp      c
    jr      nc, 12$
11$:
    push    de
    ld      de, #ENEMY_LENGTH
    add     ix, de
    pop     de
    djnz    10$
    or      a
    jr      19$
12$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     bc
    pop     hl

    ; 終了
    ret


; 定数の定義
;

; 種類別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     EnemyLoopHorizon
    .dw     EnemyLoopVertical

; エネミーの初期値
;
enemyDefault:

    .dw     enemyDefaultNull
    .dw     enemyDefaultLoopHorizon
    .dw     enemyDefaultLoopVertical
    
enemyDefaultNull:

    .db     ENEMY_TYPE_NULL
    .db     ENEMY_STATE_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_DIRECTION_MINUS
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_COLOR_NULL
    .db     ENEMY_FRAME_NULL

enemyDefaultLoopHorizon:

    .db     ENEMY_TYPE_LOOP_HORIZON
    .db     ENEMY_STATE_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     -0x02 ; ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_DIRECTION_MINUS
    .db     0x10 ; ENEMY_SPRITE_NULL
    .db     0x05 ; ENEMY_COLOR_NULL
    .db     ENEMY_FRAME_LOOP_HORIZON / 0x02

enemyDefaultLoopVertical:

    .db     ENEMY_TYPE_LOOP_VERTICAL
    .db     ENEMY_STATE_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_SPEED_NULL
    .db     -0x02 ; ENEMY_SPEED_NULL
    .db     ENEMY_DIRECTION_MINUS
    .db     0x10 ; ENEMY_SPRITE_NULL
    .db     0x05 ; ENEMY_COLOR_NULL
    .db     ENEMY_FRAME_LOOP_VERTICAL / 0x02

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; スプライト
;
enemySprite:

    .ds     0x01
