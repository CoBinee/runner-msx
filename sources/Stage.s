; Stage.s : ステージ
;


; モジュール宣言
;
    .module Stage

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Stage.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;
    .globl  _patternTable


; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ステージを初期化する
;
_StageInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #stageDefault
    ld      de, #_stage
    ld      bc, #STAGE_LENGTH
    ldir

    ; 乱数の設定
    ld      a, (_app + APP_COURSE)
    ld      (_stage + STAGE_RANDOM_L), a
    neg
    ld      (_stage + STAGE_RANDOM_H), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ステージを作成する
;
_StageCreate::

    ; レジスタの保存

    ; セルの作成
    call    StageCreateCell

    ; パターンネームの作成
    call    StageCreateName
    
    ; レジスタの復帰
    
    ; 終了
    ret

; セルを作成する
;
StageCreateCell:

    ; レジスタの保存

    ; セルのクリア
    ld      hl, #(stageCell + 0x0000)
    ld      de, #(stageCell + 0x0001)
    ld      bc, #(STAGE_CELL_SIZE_X * STAGE_CELL_SIZE_Y + 0x0001 - 0x0001)
    ld      (hl), #STAGE_CELL_NULL
    ldir

    ; スタートの作成
    ld      hl, #(stageCell + 0x06 * STAGE_CELL_SIZE_X + 0x00)
    ld      de, #(stageCell + 0x06 * STAGE_CELL_SIZE_X + 0x01)
    ld      bc, #(0x08 - 0x01)
    ld      (hl), #STAGE_CELL_BLOCK
    ldir

    ; ジェネレータの初期化
    ld      hl, #(stageCell + 0x00 * STAGE_CELL_SIZE_X + 0x08)
    ld      (stageGenerator + STAGE_GENERATOR_CELL_L), hl
    ld      a, #(0x04 + 0x04)
    ld      (stageGenerator + STAGE_GENERATOR_X), a
    ld      a, #0x06
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
    ld      a, #(0x32 - 0x04)
    ld      (stageGenerator + STAGE_GENERATOR_DISTANCE), a

    ; ゴール直前までコースをランダムに配置する
10$:
    ld      hl, #11$
    push    hl
    call    StageGetRandom
    and     #0x0f
;   ld      a, (_app + APP_COURSE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #stageCreateCellProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:
    jr      c, 19$
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    cp      #(0x32 + 0x04)
    jr      nc, 19$
    ld      a, #0x01
    call    StageCreateCellStright
    jr      10$
19$:

    ; 最後の直線の作成
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    sub     #(0x32 + 0x04)
    neg
    add     a, #0x04
    call    StageCreateCellStright

    ; ゴールの設定
    ld      a, #(0x32 + 0x04)
    call    StageGetBlockY
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    dec     a
    ld      (_stage + STAGE_GOAL_Y), a

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／00: 直線
;
StageCreateCell_00:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x03
    jr      c, 90$
    ld      c, a

    ; 長さの取得
    call    StageGetRandom
    and     #0x03
    add     a, #0x03
    cp      c
    jr      c, 10$
    ld      a, c
10$:
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a

    ; 高さの取得
    xor     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; セルの作成
    call    StageGetGeneratorCell
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      b, a
    ld      a, #STAGE_CELL_BLOCK
30$:
    ld      (hl), a
    inc     hl
    djnz    30$

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    srl     a
    add     a, e
    ld      e, a
    dec     d
    ld      c, #0x03
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／01: 階段
;
StageCreateCell_01:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 個数の取得
    call    StageGetRandom
    ld      c, a
    and     #0x03
    add     a, #0x02
    ld      b, a

    ; 長さの取得
    ld      a, c
    rlca
    and     #0x01
    inc     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a

    ; 高さの取得
    ld      a, c
    rrca
    rrca
    and     #0x02
    dec     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; 長さの判定
10$:
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      c, a
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      c
    jr      c, 90$

    ; 高さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    ld      c, a
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    add     a, c
    cp      #STAGE_CELL_SIZE_Y
    jr      nc, 80$

    ; セルの作成
    call    StageGetGeneratorCell
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    ld      e, #0x00
    sra     a
    rr      e
    sra     a
    rr      e
    ld      d, a
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
30$:
    ld      (hl), #STAGE_CELL_BLOCK
    inc     hl
    dec     a
    jr      nz, 30$

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    add     a, d
    dec     a
    ld      d, a
    ld      c, #0x03
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    djnz    10$

    ; 作成の完了
80$:
    or      a
;   jr      90$
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／02: 高跳び
;
StageCreateCell_02:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x03
    jr      c, 90$
    ld      c, a

    ; 長さの取得
    call    StageGetRandom
    and     #0x03
    add     a, #0x03
    cp      c
    jr      c, 10$
    ld      a, c
10$:
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a

    ; 高さの取得
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    cp      #(STAGE_CELL_SIZE_Y / 0x02)
    jr      nc, 20$
    ld      a, #0x04
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a
    ld      a, #0x01
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_2), a
    jr      21$
20$:
    ld      a, #-0x03
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a
    ld      a, #-0x03
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_2), a
;   jr      21$
21$:

    ; セルの作成
    call    StageGetGeneratorCell
    ld      (hl), #STAGE_CELL_BLOCK
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    ld      d, a
    ld      e, #0x00
    sra     d
    rr      e
    sra     d
    rr      e
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    dec     a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      (hl), #STAGE_CELL_BLOCK

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    add     a, e
    sub     #0x03
    ld      e, a
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_2)
    add     a, d
    ld      d, a
    ld      c, #0x02
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／03: 幅跳び 
;
StageCreateCell_03:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 上下の判定
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    cp      #(STAGE_CELL_SIZE_Y / 0x02)
    jr      nc, 110$

    ; 上部の取得
100$:
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x09
    jr      c, 90$
    jr      z, 101$
    call    StageGetRandom
    and     #0x01
    jr      nz, 101$
    ld      de, #((0x0003 << 8) | 0x000a)
    jr      102$
101$:
    ld      de, #((0x0001 << 8) | 0x0009)
;   jr      102$
102$:
    ld      bc, #((0x0001 << 8) | 0x0007)
    jr      190$

    ; 下部の取得
110$:
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x08
    jr      c, 90$
    jr      z, 111$
    call    StageGetRandom
    and     #0x01
    jr      nz, 111$
    ld      de, #((0x0000 << 8) | 0x0009)
    jr      112$
111$:
    ld      de, #((-0x0002 << 8) | 0x0008)
;   jr      112$
112$:
    ld      bc, #((-0x0002 << 8) | 0x0006)
;   jr      190$

    ; 上下の完了
190$:
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), de
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_2), bc

    ; セルの作成
    call    StageGetGeneratorCell
    ld      (hl), #STAGE_CELL_BLOCK
    ld      a, e
    ld      e, #0x00
    sra     d
    rr      e
    sra     d
    rr      e
    add     hl, de
    dec     a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      (hl), #STAGE_CELL_BLOCK

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, c
    add     a, e
    ld      e, a
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    ld      a, b
    add     a, d
    ld      d, a
    ld      c, #0x02
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／04: 足場
;
StageCreateCell_04:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 個数の取得
    call    StageGetRandom
    and     #0x01
    add     a, #0x02
    ld      b, a

    ; 長さの取得
10$:
    call    StageGetRandom
    ld      c, a
    and     #0x01
    add     a, #0x02
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a
    ld      e, a
    ld      a, c
    rrca
    and     #0x01
    inc     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a
    add     a, e
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_2), a

    ; 長さの判定
;   ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_2)
    ld      c, a
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      c
    jr      c, 90$

    ; 高さの取得
    ld      a, c
    rlca
    rlca
    and     #0x03
    cp      #0x02
    jr      nc, 21$
    sub     #0x03
21$:
    ld      d, a
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    add     a, d
    cp      #STAGE_CELL_SIZE_Y
    ld      a, d
    jr      c, 22$
    neg
22$:
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_3), a

    ; セルの作成
    call    StageGetGeneratorCell
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_3)
    ld      d, a
    ld      e, #0x00
    sra     d
    rr      e
    sra     d
    rr      e
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    ld      c, a
    ld      a, #STAGE_CELL_BLOCK
30$:
    ld      (hl), a
    inc     hl
    dec     c
    jr      nz, 30$

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    srl     a
    add     a, e
    ld      e, a
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_3)
    add     a, d
    ld      d, a
    ld      c, #0x02
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_2)
    call    StageUpdateGeneratorCell
    dec     b
    jp      nz, 10$
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／05: 炎の道
;
StageCreateCell_05:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 個数の取得
    call    StageGetRandom
    and     #0x01
    add     a, #0x02
    ld      b, a

    ; 長さの取得
10$:
    call    StageGetRandom
    and     #0x03
    add     a, #0x03
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a
    ld      c, a

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      c
    jr      c, 90$

    ; 高さの取得
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    or      a
    jr      nz, 20$
    call    StageGetRandom
    and     #0x03
    inc     a
    add     a, #0x01
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
20$:
    xor     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; セルの作成
    call    StageGetGeneratorCell
    push    bc
    ld      e, l
    ld      d, h
    ld      bc, #(-STAGE_CELL_SIZE_X + 0x0001)
    add     hl, bc
    pop     bc
    dec     c
    dec     c
    ld      a, #STAGE_CELL_BLOCK
    ld      (de), a
    inc     de
30$:
    ld      (de), a
    ld      (hl), #STAGE_CELL_FIRE
    inc     de
    inc     hl
    dec     c
    jr      nz, 30$
    ld      (de), a
;   inc     de

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    add     a, e
    ld      e, a
    dec     d
    dec     d
    ld      c, #0x03
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    dec     b
    jp      nz, 10$
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／06: 炎の輪
;
StageCreateCell_06:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 個数の取得
    call    StageGetRandom
    and     #0x03
    inc     a
    ld      b, a

    ; 長さの判定
10$:
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x03
    jr      c, 90$

    ; 高さの取得
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    cp      #0x05
    jr      nc, 20$
    ld      a, #0x06
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
20$:

    ; セルの作成
    call    StageGetGeneratorCell
    ld      a, #STAGE_CELL_BLOCK
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    ld      de, #-(STAGE_CELL_SIZE_X + 0x01)
    add     hl, de
    inc     de
    push    hl
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
30$:
    ld      (hl), #STAGE_CELL_FIRE
    add     hl, de
    dec     a
    jr      nz, 30$
    pop     hl
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    ld      c, a
    call    StageGetRandom
    and     #0x03
    inc     a
31$:
    add     hl, de
    dec     c
    dec     a
    jr      nz, 31$
    ld      (hl), #STAGE_CELL_NULL
    add     hl, de
    dec     c
    jr      z, 32$
    ld      (hl), #STAGE_CELL_NULL
32$:

    ; ジェネレータの更新
    ld      de, #((0x0000 << 8) | 0x0003)
    call    StageUpdateGeneratorCell
    dec     b
    jp      nz, 10$
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／07: 炎の壁
;
StageCreateCell_07:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 個数の取得
    call    StageGetRandom
    and     #0x03
    inc     a
    ld      b, a

    ; 長さの判定
10$:
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x03
    jr      c, 90$

    ; 高さの取得
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    cp      #0x04
    jr      nc, 20$
    add     a, #0x04
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
20$:

    ; セルの作成
    call    StageGetGeneratorCell
    ld      a, #STAGE_CELL_BLOCK
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), a
    ld      de, #-(STAGE_CELL_SIZE_X + 0x01)
    add     hl, de
    inc     de
    call    StageGetRandom
    and     #0x03
    inc     a
30$:
    ld      (hl), #STAGE_CELL_FIRE
    add     hl, de
    dec     a
    jr      nz, 30$

    ; ジェネレータの更新
    ld      de, #((0x0000 << 8) | 0x0003)
    call    StageUpdateGeneratorCell
    dec     b
    jp      nz, 10$
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／08: 炎の穴
;
StageCreateCell_08:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x07
    jp      c, 90$
    ld      c, a

    ; 長さの取得
    call    StageGetRandom
    ld      b, a
    and     #0x02
    add     a, #0x08
    cp      c
    jr      c, 10$
    ld      a, c
10$:
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a

    ; 高さの取得
    xor     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; 幅の取得
    ld      a, b
    rlca
    rlca
    and     #0x01
    add     a, #0x02
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_2), a

    ; セルの作成
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    cp      #0x04
    jr      c, 30$
    ld      a, #0x04
30$:
    ld      d, a
    ld      e, #0x00
    sra     d
    rr      e
    sra     d
    rr      e
    ld      hl, (stageGenerator + STAGE_GENERATOR_CELL_L)
    add     hl, de
    ld      a, #STAGE_CELL_BLOCK
    ld      (hl), a
    inc     hl
    ld      (hl), a
;   inc     hl
    ld      hl, (stageGenerator + STAGE_GENERATOR_CELL_L)
    ld      de, #(0x02 * STAGE_CELL_SIZE_X + 0x00)
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    sub     #0x02
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      e, l
    ld      d, h
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_2)
    ld      c, a
    ld      b, #0x00
    or      a
    sbc     hl, bc
    ex      de, hl
    ld      a, #STAGE_CELL_FIRE
    ld      b, #0x03
31$:
    push    bc
    ld      (hl), a
    ld      (de), a
    ld      bc, #(0x01 * STAGE_CELL_SIZE_X + 0x00)
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    31$
    ld      de, #(0x02 * STAGE_CELL_SIZE_X - 0x02)
    add     hl, de
    ld      a, #STAGE_CELL_BLOCK
    ld      b, #0x04
32$:
    ld      (hl), a
    inc     hl
    djnz    32$

    ; エネミーの配置
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    ld      e, a
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    sub     #0x04
    add     a, e
    ld      e, a
    ld      d, #0x05
    ld      c, #0x01
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    ld      a, #0x07
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／09: 炎のはしご
;
StageCreateCell_09:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x08
    jr      c, 90$

    ; セルの作成
    ld      hl, #stageCellLayout_09
    ld      de, (stageGenerator + STAGE_GENERATOR_CELL_L)
    ld      b, #STAGE_CELL_SIZE_Y
30$:
    push    bc
    ld      bc, #0x0008
    ldir
    ex      de, hl
    ld      bc, #(STAGE_CELL_SIZE_X - 0x0008)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    30$

    ; ジェネレータの更新
    ld      de, #((0x0000 << 8) | 0x0008)
    call    StageUpdateGeneratorCell
    xor     a
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／10: 上下の入れ替え
;
StageCreateCell_10:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x04
    jr      c, 90$

    ; セルの作成
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    cp      #(STAGE_CELL_SIZE_Y / 0x02)
    jr      nc, 30$
    ld      hl, #stageCellLayout_10Upper
    ld      a, #(STAGE_CELL_SIZE_Y - 0x01)
    jr      31$
30$:
    ld      hl, #stageCellLayout_10Lower
    ld      a, #0x01
;   jr      31$
31$:
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a
    ld      de, (stageGenerator + STAGE_GENERATOR_CELL_L)
    ld      b, #STAGE_CELL_SIZE_Y
32$:
    push    bc
    ld      bc, #0x0004
    ldir
    ex      de, hl
    ld      bc, #(STAGE_CELL_SIZE_X - 0x0004)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    32$

    ;  エネミーの配置
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    inc     a
    ld      e, a
    ld      d, #0x03
    ld      c, #0x01
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, #((0x0000 << 8) | 0x0004)
    call    StageUpdateGeneratorCell
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／11: 走り抜けられる穴
;
StageCreateCell_11:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 最初の足場の作成
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x03
    jr      c, 90$
    call    StageGetGeneratorCell
    ld      (hl), #STAGE_CELL_BLOCK
    ld      de, #((0x0000 << 8) | 0x0001)
    call    StageUpdateGeneratorCell

    ; 個数の取得
    call    StageGetRandom
    and     #0x03
    add     a, #0x02
    ld      b, a

    ; 長さの判定
10$:
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x02
    jr      c, 90$

    ; セルの作成
    call    StageGetGeneratorCell
    inc     hl
    ld      (hl), #STAGE_CELL_BLOCK

    ; エネミーの配置
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    ld      e, a
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    dec     a
    ld      d, a
    ld      c, #0x02
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, #((0x0000 << 8) | 0x0002)
    call    StageUpdateGeneratorCell
    dec     b
    jp      nz, 10$
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／12: 走り抜けられない穴
;
StageCreateCell_12:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 最初の足場の作成
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      #0x03
    jr      c, 90$
    call    StageGetGeneratorCell
    ld      (hl), #STAGE_CELL_BLOCK
    ld      de, #((0x0000 << 8) | 0x0001)
    call    StageUpdateGeneratorCell

    ; 個数の取得
    call    StageGetRandom
    and     #0x03
    add     a, #0x02
    ld      b, a

    ; 長さの取得
10$:
    call    StageGetRandom
    and     #0x01
    add     a, #0x02
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a
    ld      e, a

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      e
    jr      c, 90$

    ; 高さの取得
    xor     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; セルの作成
    call    StageGetGeneratorCell
    dec     e
    ld      d, #0x00
    add     hl, de
    ld      (hl), #STAGE_CELL_BLOCK

    ; エネミーの配置
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    ld      e, a
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    dec     a
    ld      d, a
    ld      c, #0x02
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    dec     b
    jp      nz, 10$
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／13: 降りられない道
;
StageCreateCell_13:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 長さの取得
    call    StageGetRandom
    and     #0x03
    add     a, #0x08
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a
    ld      c, a

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      c
    jr      c, 90$

    ; 高さの取得
    xor     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; セルの作成
    ld      hl, (stageGenerator + STAGE_GENERATOR_CELL_L)
    ld      de, #STAGE_CELL_SIZE_X
    add     hl, de
    ld      a, #0x03
30$:
    ld      b, c
31$:
    ld      (hl), #STAGE_CELL_BLOCK
    inc     hl
    djnz    31$
    or      a
    sbc     hl, bc
    ld      de, #(0x03 * STAGE_CELL_SIZE_X + 0x00)
    add     hl, de
    dec     a
    jr      nz, 30$

    ; エネミーの配置
    ld      a, c
    sub     #0x08
    srl     a
    ld      h, a
    ld      d, #0x00
    ld      bc, #((0x0003 << 8) | 0x0001)
40$:
    call    StageGetRandom
    and     #0x07
    add     a, h
    ld      e, a
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    add     a, e
    ld      e, a
    call    StageEntryEnemy
    ld      a, d
    add     a, #0x03
    ld      d, a
    djnz    40$

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    ld      a, #0x01
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／14: ジャンプしづらい道
;
StageCreateCell_14:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 長さの取得
    call    StageGetRandom
    and     #0x03
    add     a, #0x05
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a
    ld      c, a

    ; 長さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      c
    jr      c, 90$

    ; 高さの取得
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    cp      #0x04
    jr      nc, 20$
    ld      a, #0x04
20$:
    ld      (stageGenerator + STAGE_GENERATOR_Y), a
    xor     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; セルの作成
    call    StageGetGeneratorCell
    push    hl
    ld      b, c
    ld      a, #STAGE_CELL_BLOCK
30$:
    ld      (hl), a
    inc     hl
    djnz    30$
    pop     hl
    ld      de, #(-0x04 * STAGE_CELL_SIZE_X + 0x01)
    add     hl, de
    ld      a, c
    sub     #0x02
    ld      b, a
    ld      a, #STAGE_CELL_FIRE
31$:
    ld      (hl), a
    inc     hl
    djnz    31$

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    srl     a
    add     a, e
    ld      e, a
    dec     d
    ld      c, #0x01
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    or      a
;   jr      90$

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; セルを作成する／15: 炎の階段
;
StageCreateCell_15:

    ; レジスタの保存

    ; cf > 作成できなかった

    ; 個数の取得
    call    StageGetRandom
    ld      c, a
    and     #0x03
    add     a, #0x02
    ld      b, a

    ; 長さの取得
    ld      a, c
    rrca
    rrca
    and     #0x01
    add     a, #0x02
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a

    ; 高さの取得
    ld      a, c
    rlca
    rlca
    and     #0x02
    dec     a
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_1), a

    ; 長さの判定
10$:
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      c, a
    ld      a, (stageGenerator + STAGE_GENERATOR_DISTANCE)
    cp      c
    jr      c, 90$

    ; 高さの判定
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    ld      c, a
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    add     a, c
    cp      #STAGE_CELL_SIZE_Y
    jr      nc, 80$

    ; セルの作成
    call    StageGetGeneratorCell
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    or      a
    jp      p, 31$
    ld      de, #(-0x01 * STAGE_CELL_SIZE_X + 0x00)
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
30$:
    ld      (hl), #STAGE_CELL_BLOCK
    inc     hl
    dec     a
    jr      nz, 30$
    ld      de, #(-0x01 * STAGE_CELL_SIZE_X + 0x00)
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      e, a
    ld      d, #0x00
    or      a
    sbc     hl, de
    ld      (hl), #STAGE_CELL_FIRE
    jr      39$
31$:
    ld      (hl), #STAGE_CELL_BLOCK
    ld      de, #(-0x01 * STAGE_CELL_SIZE_X + 0x00)
    add     hl, de
    ld      (hl), #STAGE_CELL_FIRE
    ld      de, #(0x02 * STAGE_CELL_SIZE_X + 0x01)
    add     hl, de
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    dec     a
32$:
    ld      (hl), #STAGE_CELL_BLOCK
    inc     hl
    dec     a
    jr      nz, 32$
;   jr      39$
39$:

    ; エネミーの配置
    ld      de, (stageGenerator + STAGE_GENERATOR_X)
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_1)
    add     a, d
    dec     a
    ld      d, a
    ld      c, #0x03
    call    StageEntryEnemy

    ; ジェネレータの更新
    ld      de, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    call    StageUpdateGeneratorCell
    djnz    10$

    ; 作成の完了
80$:
    or      a
;   jr      90$
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 指定した長さの直線セルを作成する
;
StageCreateCellStright:

    ; レジスタの保存

    ; a < 長さ　

    ; 長さの取得
    ld      (stageGenerator + STAGE_GENERATOR_PARAM_0), a

    ; セルの作成
    call    StageGetGeneratorCell
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      b, a
    ld      a, #STAGE_CELL_BLOCK
10$:
    ld      (hl), a
    inc     hl
    djnz    10$

    ; ジェネレータの更新
    ld      a, (stageGenerator + STAGE_GENERATOR_PARAM_0)
    ld      e, a
    ld      d, #0x00
    call    StageUpdateGeneratorCell

    ; 作成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ジェネレータのセル位置を取得する
;
StageGetGeneratorCell:

    ; レジスタの保存
    push    de

    ; hl > セル位置

    ; セル位置の取得
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, (stageGenerator + STAGE_GENERATOR_CELL_L)
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; ジェネレータのセル位置を更新する
;
StageUpdateGeneratorCell:

    ; レジスタの保存
    push    hl
    push    de

    ; de < 移動させる Y/X の量

    ; セル位置の更新
    push    de
    ld      d, #0x00
    ld      hl, (stageGenerator + STAGE_GENERATOR_CELL_L)
    add     hl, de
    ld      (stageGenerator + STAGE_GENERATOR_CELL_L), hl
    pop     de

    ; X 位置の更新
    ld      a, (stageGenerator + STAGE_GENERATOR_X)
    add     a, e
    ld      (stageGenerator + STAGE_GENERATOR_X), a

    ; 残りの距離の更新
    ld      e, a
    ld      a, #(0x32 + 0x04)
    sub     e
    ld      (stageGenerator + STAGE_GENERATOR_DISTANCE), a

    ; Y 位置の更新
    ld      a, (stageGenerator + STAGE_GENERATOR_Y)
    add     a, d
    ld      (stageGenerator + STAGE_GENERATOR_Y), a

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 指定された X 位置にあるブロックの Y 位置を取得する
;
StageGetBlockY:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < X 位置
    ; a > Y 位置

    ; Y 位置の取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #stageCell
    add     hl, de
    ld      de, #STAGE_CELL_SIZE_X
    ld      bc, #((STAGE_CELL_SIZE_Y << 8) | 0x0000)
10$:
    ld      a, (hl)
    cp      #STAGE_CELL_BLOCK
    jr      z, 11$
    add     hl, de
    inc     c
    djnz    10$
11$:
    ld      a, c

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; エネミーを配置する
;
StageEntryEnemy:

    ; レジスタの保存
    push    bc
    push    de

    ; de < エネミーを配置する Y/X 位置（セル単位）
    ; c  < 01 : 水平, 10 : 垂直

    ; エネミーの配置
    call    StageGetRandom
    ld      b, a
    ld      a, c
    cp      #0x03
    jr      nz, 10$
    ld      a, #0x01
    bit     #0x06, b
    jr      z, 10$
    add     a, a
10$:
    and     b
    cp      #0x01
    jr      z, 11$
    cp      #0x02
    jr      z, 12$
    jr      19$
11$:
    call    20$
    ld      a, #ENEMY_TYPE_LOOP_HORIZON
    call    _EnemyEntry
    jr      19$
12$:
    call    20$
    ld      a, #ENEMY_TYPE_LOOP_VERTICAL
    call    _EnemyEntry
;   jr      19$
19$:
    jr      90$

    ; 配置する位置の取得
20$:
    ld      a, d
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x08
    ld      c, a
    ld      a, e
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, #0x08
    ld      e, a
    ld      a, d
    adc     a, #0x00
    ld      d, a
    ret

    ; 配置の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; パターンネームを作成する
;
StageCreateName:

    ; レジスタの保存

    ; パターンネームの作成
    ld      hl, #stageCell
    ld      de, #stageName
    ld      b, #STAGE_CELL_SIZE_Y
10$:
    push    bc
    ld      b, #STAGE_CELL_SIZE_X
11$:
    push    bc
    ld      a, (hl)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    inc     hl
    ld      a, (hl)
    add     a, a
    add     a, a
    add     a, c
    ld      c, a
    ld      b, #0x00
    push    hl
    ld      hl, #stageCellName
    add     hl, bc
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
;   inc     de
    ex      de, hl
    ld      bc, #(STAGE_NAME_SIZE_X - 0x0001)
    add     hl, bc
    ex      de, hl
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de
    ex      de, hl
    ld      bc, #-(STAGE_NAME_SIZE_X - 0x0001)
    add     hl, bc
    ex      de, hl
    pop     hl
    pop     bc
    djnz    11$
    ex      de, hl
    ld      bc, #STAGE_NAME_SIZE_X
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; ステージを更新する
;
_StageUpdate::
    
    ; レジスタの保存

    ; フレームの更新
    ld      hl, #(_stage + STAGE_FRAME)
    inc     (hl)

    ; アニメーションの更新
    ld      a, (hl)
    and     #0x03
    jr      nz, 10$
    ld      hl, #(_videoRegister + VDP_R4)
    ld      a, (hl)
    xor     #0x01
    ld      (hl), a
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ステージを描画する
;
_StageRender::

    ; レジスタの保存

    ; パターンネームの設定
    ld      de, (_stage + STAGE_SCROLL_L)
    srl     d
    rr      e
    srl     d
    rr      e
    srl     d
    rr      e
    ld      hl, #stageName
    add     hl, de
    ld      de, #(_patternName + 0x0080)
    ld      a, (_stage + STAGE_SCROLL_L)
    and     #0x07
    ld      c, a
    ld      b, #STAGE_NAME_SIZE_Y
10$:
    push    bc
    ld      b, #0x20
11$:
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    11$
    ld      bc, #(STAGE_NAME_SIZE_X - 0x0020)
    add     hl, bc
    pop     bc
    djnz    10$

    ; スタートあるいはゴールの描画
    ld      a, (_stage + STAGE_FRAME)
    rrca
    rrca
    and     #0x03
    ld      c, a
    ld      hl, (_stage + STAGE_START_X_L)
    ld      de, #-0x0008
    add     hl, de
    ex      de, hl
    call    _GameGetSpriteXec
    jr      nc, 20$
    ld      hl, #(_sprite + GAME_SPRITE_STARTGOAL)
    ld      a, (_stage + STAGE_START_Y)
    add     a, c
    add     a, #(STAGE_OFFSET_Y - 0x28)
    ld      (hl), a
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), #0x04
    inc     hl
    ld      a, #0x0b
    or      e
    ld      (hl), a
;   inc     hl
    jr      29$
20$:
    ld      hl, (_stage + STAGE_GOAL_X_L)
    ld      de, #-0x0008
    add     hl, de
    ex      de, hl
    call    _GameGetSpriteXec
    jr      nc, 29$
    ld      hl, #(_sprite + GAME_SPRITE_STARTGOAL)
    ld      a, (_stage + STAGE_GOAL_Y)
    add     a, c
    add     a, #(STAGE_OFFSET_Y - 0x28)
    ld      (hl), a
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), #0x08
    inc     hl
    ld      a, #0x0b
    or      e
    ld      (hl), a
;   inc     hl
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; 乱数を取得する
;
StageGetRandom:

    ; レジスタの保存
    push    hl
    push    de
    
    ; 乱数の生成
    ld      hl, (_stage + STAGE_RANDOM_L)
    ld      e, l
    ld      d, h
    add     hl, hl
    add     hl, hl
    add     hl, de
    ld      de, #0x2018
    add     hl, de
    ld      (_stage + STAGE_RANDOM_L), hl
    ld      a, h
    
    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

; スクロールする
;
_StageScroll::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < X 位置

    ; スクロールの設定
    ld      l, e
    ld      h, d
    ld      bc, #STAGE_SCROLL_DISTANCE
    or      a
    sbc     hl, bc
    jr      c, 19$
    ld      c, l
    ld      b, h
    ld      hl, (_stage + STAGE_SCROLL_L)
    or      a
    sbc     hl, bc
    jr      nc, 19$
    ld      hl, #STAGE_SCROLL_RIGHT
    or      a
    sbc     hl, bc
    jr      nc, 10$
    ld      bc, #STAGE_SCROLL_RIGHT
10$:
    ld      (_stage + STAGE_SCROLL_L), bc
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; ステージ上のセルとのコリジョンを判定する
;
_StageIsCell::

    ; レジスタの保存
    push    hl

    ; de < X 位置
    ; c  < Y 位置
    ; b  < 判定するセルの種類
    ; cf > 指定されたセルがある

    ; ブロックの判定
    call    StageGetCell
    jr      c, 10$
    ld      a, (hl)
    cp      b
    jr      nz, 10$
    scf
    jr      11$
10$:
    or      a
;   jr      11$
11$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; セルの位置を取得する
;
StageGetCell:

    ; レジスタの保存
    push    bc
    push    de

    ; de < X 位置
    ; c  < Y 位置
    ; hl > セルの位置
    ; cf > ステージ外

    ; 位置の取得
    ld      a, d
    and     #0xfc
    jr      nz, 10$
    ld      a, c
    and     #0x80
    jr      nz, 10$
    srl     d
    rr      e
    srl     d
    rr      e
    srl     d
    rr      e
    srl     d
    rr      e
    ld      a, c
    and     #0x70
    ld      b, #0x00
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, a
    ld      hl, #stageCell
    add     hl, de
    add     hl, bc
    or      a
    jr      11$
10$:
    scf
;   jr      11$
11$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; 定数の定義
;

; ステージの初期値
;
stageDefault:

    .db     STAGE_ID_NULL
    .db     STAGE_STATE_NULL
    .dw     STAGE_POSITION_START_X
    .db     STAGE_POSITION_START_Y
    .dw     STAGE_POSITION_GOAL_X
    .db     STAGE_POSITION_GOAL_Y
    .dw     STAGE_SCROLL_NULL
    .dw     STAGE_RANDOM_NULL
    .db     STAGE_FRAME_NULL

; セルの作成処理
;
stageCreateCellProc:

    .dw     StageCreateCell_00
    .dw     StageCreateCell_01
    .dw     StageCreateCell_02
    .dw     StageCreateCell_03
    .dw     StageCreateCell_04
    .dw     StageCreateCell_05
    .dw     StageCreateCell_06
    .dw     StageCreateCell_07
    .dw     StageCreateCell_08
    .dw     StageCreateCell_09
    .dw     StageCreateCell_10
    .dw     StageCreateCell_11
    .dw     StageCreateCell_12
    .dw     StageCreateCell_13
    .dw     StageCreateCell_14
    .dw     StageCreateCell_15

; セルレイアウト
;
stageCellLayout_09:

    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_BLOCK, STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_FIRE,  STAGE_CELL_BLOCK
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_FIRE,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_FIRE
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_FIRE,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_FIRE
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_FIRE,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_BLOCK, STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_BLOCK, STAGE_CELL_BLOCK, STAGE_CELL_BLOCK, STAGE_CELL_BLOCK, STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL

stageCellLayout_10Upper:

    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_FIRE,  STAGE_CELL_FIRE,  STAGE_CELL_FIRE
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_BLOCK, STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_BLOCK

stageCellLayout_10Lower:

    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_FIRE,  STAGE_CELL_FIRE,  STAGE_CELL_BLOCK
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_BLOCK, STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL
    .db     STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL,  STAGE_CELL_NULL

; セル→パターンネーム変換テーブル
;
stageCellName:

    .db     0x80, 0x80, 0x80, 0x80  ; NULL  -> NULL
    .db     0x80, 0x90, 0x80, 0x80  ; NULL  -> BLOCK
    .db     0x80, 0xa0, 0x80, 0xb0  ; NULL  -> FIRE
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x98, 0x88, 0x80, 0x80  ; BLOCK -> NULL
    .db     0x98, 0x98, 0x80, 0x80  ; BLOCK -> BLOCK
    .db     0x98, 0xa8, 0x80, 0xb8  ; BLOCK -> FIRE
    .db     0x00, 0x00, 0x00, 0x00
    .db     0xc0, 0xc8, 0xd0, 0xd8  ; FIRE  -> NULL
    .db     0xc0, 0xe0, 0xd0, 0xf0  ; FIRE  -> BLOCK
    .db     0xc0, 0xe8, 0xd0, 0xf8  ; FIRE  -> FIRE
    .db     0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ステージ
;
_stage::

    .ds     STAGE_LENGTH

; セル
;
stageCell:

    .ds     STAGE_CELL_SIZE_X * STAGE_CELL_SIZE_Y + 0x0001

; パターンネーム
;
stageName:

    .ds     STAGE_NAME_SIZE_X * STAGE_NAME_SIZE_Y

; ジェネレータ
;
stageGenerator:

    .ds     STAGE_GENERATOR_LENGTH
