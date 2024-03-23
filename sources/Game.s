; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

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

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; サウンドの停止
    call    _SystemStopSound

    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir
    
    ; ステージの初期化
    call    _StageInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; ステージの作成
    call    _StageCreate

    ; 距離の更新
    call    GameUpdateDistance

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
    
    ; 状態の設定
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_game + GAME_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
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

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #_game + GAME_STATE
    inc     (hl)
09$:

    ; 1 フレームの更新
;   call    GameUpdateFrame

    ; 1 フレームの描画
    call    GameRenderFrame

    ; キー入力の監視
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      nz, 10$
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      nz, 10$
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      nz, 10$

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (_game + GAME_STATE), a
10$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x10
    ld      (_game + GAME_FRAME), a

    ; BGM の再生
    ld      a, #GAME_SOUND_BGM_THEME
    call    _GamePlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 1 フレームの更新
    call    GameUpdateFrame

    ; 時間の更新
    call    _PlayerIsPlay
    call    c, GameUpdateTime

    ; 距離の更新
    call    GameUpdateDistance

    ; 1 フレームの描画
    call    GameRenderFrame

    ; READY → GO の描画
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_PLAY_BIT, a
    jr      nz, 10$
    ld      a, #GAME_INFORMATION_READY
    ld      (_game + GAME_INFORMATION), a
    call    GamePrintInformation
    jr      11$
10$:
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 11$
    dec     (hl)
    ld      a, #GAME_INFORMATION_GO
    ld      (_game + GAME_INFORMATION), a
    call    GamePrintInformation
11$:

    ; ゴールの判定
    call    _PlayerIsGoal
    jr      nc, 20$
    ld      a, #GAME_STATE_CLEAR
    ld      (_game + GAME_STATE), a
    jr      29$
20$:

    ; ゲームオーバーの判定
    call    _PlayerIsAlive
    jr      c, 21$
    ld      a, #GAME_STATE_OVER
    ld      (_game + GAME_STATE), a
;   jr      29$
21$:

    ; 判定の完了
29$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; インフォメーションの設定
    ld      a, #GAME_INFORMATION_MISS
    ld      (_game + GAME_INFORMATION), a

    ; フレームの初期化
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a

    ; サウンドの停止
    call    _SystemStopSound

    ; BGM の再生
    ld      a, #GAME_SOUND_BGM_OVER
    call    _GamePlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 1 フレームの更新
    call    GameUpdateFrame

    ; 1 フレームの描画
    call    GameRenderFrame

    ; インフォメーションの描画
    call    GamePrintInformation

    ; キー入力待ち
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      z, 10$

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
10$:
    ld      a, #GAME_MENU_RETRY
    ld      (_game + GAME_MENU), a
    ld      a, #GAME_STATE_MENU
    ld      (_game + GAME_STATE), a
;   jr      19$
19$: 

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 記録の更新
    ld      de, (_game + GAME_TIME_L)
    call    _AppUpdateRecord

    ; インフォメーションの設定
    ld      a, #GAME_INFORMATION_GOAL
    adc     a, #0x00
    ld      (_game + GAME_INFORMATION), a

    ; フレームの初期化
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a

    ; サウンドの停止
    call    _SystemStopSound

    ; BGM の再生
    ld      a, #GAME_SOUND_BGM_CLEAR
    call    _GamePlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 1 フレームの更新
    call    GameUpdateFrame

    ; 1 フレームの描画
    call    GameRenderFrame

    ; インフォメーションの描画
    call    GamePrintInformation

    ; キー入力待ち
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      z, 10$

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
10$:
    ld      a, #GAME_MENU_NEXT
    ld      (_game + GAME_MENU), a
    ld      a, #GAME_STATE_MENU
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; メニューを開く
;
GameMenu:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; フレームの設定
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; キー入力待ち
    ld      a, (_game + GAME_STATE)
    cp      #(GAME_STATE_MENU + 0x01)
    jr      nz, 19$

    ; SPACE キーの監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 10$
    ld      a, #GAME_SOUND_SE_CLICK
    call    _GamePlaySe
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
    jr      19$
10$:

    ; ↑キーの監視
    ld      a, (_input + INPUT_KEY_UP)
    dec     a
    jr      nz, 12$
    ld      hl, #(_game + GAME_MENU)
    ld      a, (hl)
    or      a
    jr      nz, 11$
    ld      a, #GAME_MENU_LENGTH
11$:
    dec     a
    ld      (hl), a
    jr      19$
12$:

    ; ↓キーの監視
    ld      a, (_input + INPUT_KEY_DOWN)
    dec     a
    jr      nz, 19$
    ld      hl, #(_game + GAME_MENU)
    ld      a, (hl)
    inc     a
    cp      #GAME_MENU_LENGTH
    jr      c, 13$
    xor     a
13$:
    ld      (hl), a
;   jr      19$
19$:

    ; フレームの更新
    ld      a, (_game + GAME_STATE)
    cp      #(GAME_STATE_MENU + 0x02)
    jr      nz, 29$
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 29$

    ; 状態の更新
    ld      a, #GAME_STATE_END
    ld      (_game + GAME_STATE), a
29$:

    ; ステータスの描画
    call    GamePrintStatus

    ; インフォメーションの描画
    call    GamePrintInformation

    ; メニューの描画
    call    GamePrintMenu

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを終了する
;
GameEnd:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; メニューの取得
    ld      a, (_game + GAME_MENU)

    ; 次のステージへ
    cp      #GAME_MENU_NEXT
    jr      nz, 10$
    ld      hl, #(_app + APP_COURSE)
    inc     (hl)
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
    jr      19$
10$:

    ; リトライ
    cp      #GAME_MENU_RETRY
    jr      nz, 11$
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
    jr      19$
11$:

    ; タイトルへ戻る
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
    jr      19$
19$:

    ; 状態の更新

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを 1 フレーム更新する
;
GameUpdateFrame:

    ; レジスタの保存

    ; ステージの更新
    call    _StageUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを 1 フレーム描画する
;
GameRenderFrame:

    ; ステージの描画
    call    _StageRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; ステータスの描画
    call    GamePrintStatus

    ; レジスタの復帰

    ; 終了
    ret

; 時間を更新する
;
GameUpdateTime:

    ; レジスタの保存

    ; 時間の更新
    ld      hl, #(_game + GAME_TIME_L)
    inc     (hl)
    ld      a, (hl)
    cp      #0x1e
    jr      c, 10$
    xor     a
    ld      (hl), a
    inc     hl
    inc     (hl)
    ld      a, (hl)
    cp      #0x64
    jr      c, 10$
    ld      a, #0x63
    ld      (hl), a
    dec     hl
    ld      a, #0x1e
    ld      (hl), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 距離を更新する
;
GameUpdateDistance:

    ; レジスタの保存

    ; 距離の更新
    ld      hl, (_stage + STAGE_GOAL_X_L)
    ld      de, (_player + PLAYER_POSITION_X_L)
    or      a
    sbc     hl, de
    jr      nc, 10$
    xor     a
    ld      l, a
    ld      h, a
10$:
    ld      a, l
    and     #0x0f
    ld      (_game + GAME_DISTANCE_L), a
    ld      a, l
    srl     h
    rra
    srl     h
    rra
    srl     h
    rra
    srl     h
    rra
    ld      (_game + GAME_DISTANCE_H), a

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを描画する
;
GamePrintStatus:

    ; レジスタの保存

    ; 時間の描画
    ld      a, (_game + GAME_TIME_L)
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appBcdMillisecond
    add     hl, de
    ld      c, (hl)
    ld      hl, #(_patternName + 0x0031)
    ld      (hl), #0x02
    inc     hl
    ld      a, c
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, c
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    ld      a, (_game + GAME_TIME_H)
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appBcdNumber
    add     hl, de
    ld      c, (hl)
    ld      hl, #(_sprite + GAME_SPRITE_TIME)
    ld      (hl), #0xff
    inc     hl
    ld      (hl), #0x68
    inc     hl
    ld      a, c
    rrca
    rrca
    and     #0x3c
    add     a, #0x80
    ld      (hl), a
    inc     hl
    ld      (hl), #0x0f
    inc     hl
    ld      (hl), #0xff
    inc     hl
    ld      (hl), #0x78
    inc     hl
    ld      a, c
    add     a, a
    add     a, a
    and     #0x3c
    add     a, #0x80
    ld      (hl), a
    inc     hl
    ld      (hl), #0x0f
;   inc     hl

    ; 距離の描画
    ld      a, (_game + GAME_DISTANCE_L)
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appBcdCentimeter
    add     hl, de
    ld      c, (hl)
    ld      hl, #(_patternName + 0x02f1)
    ld      (hl), #0x2d
    inc     hl
    ld      a, c
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    inc     hl
    ld      a, c
    and     #0x0f
    add     a, #0x10
    ld      (hl), a
    ld      a, (_game + GAME_DISTANCE_H)
    ld      e, a
    ld      d, #0x00
    ld      hl, #_appBcdNumber
    add     hl, de
    ld      c, (hl)
    ld      hl, #(_sprite + GAME_SPRITE_DISTANCE)
    ld      (hl), #0xaf
    inc     hl
    ld      (hl), #0x68
    inc     hl
    ld      a, c
    rrca
    rrca
    and     #0x3c
    add     a, #0x80
    ld      (hl), a
    inc     hl
    ld      (hl), #0x0f
    inc     hl
    ld      (hl), #0xaf
    inc     hl
    ld      (hl), #0x78
    inc     hl
    ld      a, c
    add     a, a
    add     a, a
    and     #0x3c
    add     a, #0x80
    ld      (hl), a
    inc     hl
    ld      (hl), #0x0f
;   inc     hl

    ; レジスタの復帰

    ; 終了
    ret

; インフォメーションを描画する
;
GamePrintInformation:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; スプライトの取得
    ld      a, (_game + GAME_INFORMATION)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameSpriteInformation
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)

    ; スプライトの描画
    ld      a, (_game + GAME_SPRITE)
    ld      c, a
    ld      b, #GAME_SPRITE_ENTRY
10$:
    push    bc
    ld      hl, #(_sprite + GAME_SPRITE_INFORMATION)
    ld      b, #0x00
    add     hl, bc
    ex      de, hl
    ld      bc, #0x0004
    ldir
    ex      de, hl
    pop     bc
    ld      a, c
    add     a, #0x04
    cp      #GAME_SPRITE_LENGTH
    jr      c, 11$
    xor     a
11$:
    ld      c, a
    djnz    10$

    ; スプライトの更新
    ld      hl, #(_game + GAME_SPRITE)
    ld      a, (hl)
    sub     #0x04
    jr      nc, 20$
    ld      a, #(GAME_SPRITE_LENGTH - 0x04)
20$:
    ld      (hl), a

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; メニューを描画する
;
GamePrintMenu:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; メニューの描画
    ld      hl, #gamePatternNameMenuNext
    ld      de, #(_patternName + 0x0168)
    ld      bc, #0x0010
    ldir
    ld      hl, #gamePatternNameMenuRetry
    ld      de, #(_patternName + 0x01a8)
    ld      bc, #0x0010
    ldir
    ld      hl, #gamePatternNameMenuBack
    ld      de, #(_patternName + 0x01e8)
    ld      bc, #0x0010
    ldir

    ; カーソルの描画
    ld      a, (_game + GAME_FRAME)
    and     #0x02
    jr      nz, 20$
    ld      a, (_game + GAME_MENU)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_patternName + 0x0168)
    add     hl, de
    ld      (hl), #0x1e
20$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; スクロール位置に合わせたスプライト描画情報を取得する
;
_GameGetSpriteXec::

    ; レジスタの保存
    push    hl

    ; de < X 位置
    ; d  > X 位置
    ; e  > EC フラグ
    ; cf > 描画する

    ; 左端での描画
    ld      hl, (_stage + STAGE_SCROLL_L)
    ex      de, hl
    or      a
    sbc     hl, de
    jr      nc, 10$
    ld      a, h
    inc     a
    jr      nz, 91$
    ld      a, l
    cp      #(0xf0 + 0x01)
    jr      c, 91$
    add     a, #0x20
    ld      d, a
    ld      e, #0x80
    jr      90$
10$:

    ; 右側での描画
    ld      a, h
    or      a
    jr      nz, 91$
    ld      d, l
    ld      e, #0x00
;   jr      90$

    ; 描画の完了
90$:
    scf
    jr      99$
91$:
    or      a
;   jr      99$
99$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; BGM を再生する
;
_GamePlayBgm::

    ; レジスタの保存
    push    hl
    push    de

    ; a = 再生する音

    ; サウンドの再生
    ld      hl, #(_game + GAME_SOUND)
    cp      (hl)
    jr      z, 19$
    ld      (hl), a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameSoundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundRequest + 0x0000), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundRequest + 0x0002), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundRequest + 0x0004), de
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_GamePlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a = 再生する音
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameSoundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ld      (_soundRequest + 0x0006), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameClear
    .dw     GameMenu
    .dw     GameEnd

; ゲームの初期値
;
gameDefault:

    .db     GAME_STATE_START
    .db     GAME_FLAG_NULL
    .db     GAME_REQUEST_NULL
    .db     GAME_SOUND_NULL
    .dw     GAME_TIME_NULL
    .dw     GAME_DISTANCE_NULL
    .db     GAME_INFORMATION_NULL
    .db     GAME_MENU_NULL
    .db     GAME_SPRITE_NULL
    .db     GAME_FRAME_NULL

; スプライト
;
gameSpriteInformation:

    .dw     gameSpriteInformationReady
    .dw     gameSpriteInformationGo
    .dw     gameSpriteInformationMiss
    .dw     gameSpriteInformationGoal
    .dw     gameSpriteInformationBesttime

gameSpriteInformationReady:

    .db     0x30, 0x58, 0xa8, 0x0b
    .db     0x30, 0x68, 0xac, 0x0b
    .db     0x30, 0x78, 0xb0, 0x0b
    .db     0x30, 0x88, 0xb4, 0x0b
    .db     0x30, 0x98, 0xb8, 0x0b
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00

gameSpriteInformationGo:

    .db     0x30, 0x70, 0xbc, 0x0b
    .db     0x30, 0x80, 0xc0, 0x0b
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00

gameSpriteInformationMiss:

    .db     0x30, 0x60, 0xc8, 0x0b
    .db     0x30, 0x70, 0xcc, 0x0b
    .db     0x30, 0x80, 0xd0, 0x0b
    .db     0x30, 0x90, 0xd0, 0x0b
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00

gameSpriteInformationGoal:

    .db     0x30, 0x60, 0xbc, 0x0b
    .db     0x30, 0x70, 0xc0, 0x0b
    .db     0x30, 0x80, 0xb0, 0x0b
    .db     0x30, 0x90, 0xc4, 0x0b
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00
    .db     0xcc, 0xcc, 0x00, 0x00

gameSpriteInformationBesttime:

    .db     0x30, 0x38, 0xd4, 0x0b
    .db     0x30, 0x48, 0xac, 0x0b
    .db     0x30, 0x58, 0xd0, 0x0b
    .db     0x30, 0x68, 0xd8, 0x0b
    .db     0x30, 0x88, 0xd8, 0x0b
    .db     0x30, 0x98, 0xcc, 0x0b
    .db     0x30, 0xa8, 0xc8, 0x0b
    .db     0x30, 0xb8, 0xac, 0x0b

; パターンネーム
;
gamePatternNameMenuNext:

    .db     0x00, 0x00, 0x2e, 0x25, 0x38, 0x34, 0x00, 0x23, 0x2f, 0x35, 0x32, 0x33, 0x25, 0x00, 0x00, 0x00

gamePatternNameMenuRetry:

    .db     0x00, 0x00, 0x32, 0x25, 0x34, 0x32, 0x39, 0x00, 0x23, 0x2f, 0x35, 0x32, 0x33, 0x25, 0x00, 0x00

gamePatternNameMenuBack:

    .db     0x00, 0x00, 0x22, 0x21, 0x23, 0x2b, 0x00, 0x34, 0x2f, 0x00, 0x34, 0x29, 0x34, 0x2c, 0x25, 0x00

; サウンド
;
gameSoundBgm:

    .dw     gameSoundNull
    .dw     gameSoundNull
    .dw     gameSoundNull
    .dw     gameSoundNull
    .dw     gameSoundBgmTheme_0
    .dw     gameSoundBgmTheme_1
    .dw     gameSoundBgmTheme_2
    .dw     gameSoundNull
    .dw     gameSoundBgmOver_0
    .dw     gameSoundBgmOver_1
    .dw     gameSoundNull
    .dw     gameSoundNull
    .dw     gameSoundBgmClear_0
    .dw     gameSoundBgmClear_1
    .dw     gameSoundBgmClear_2
    .dw     gameSoundNull
    
gameSoundSe:

    .dw     gameSoundNull
    .dw     gameSoundSeClick
    .dw     gameSoundSeJump

gameSoundNull:

    .ascii  "T1L0R"
    .db     0x00

gameSoundBgmTheme_0:

    .ascii  "T1V15-3L3"
    .ascii  "O5C4C1RO4GB-AGFE4F1RGREC5"
    .ascii  "O5C4C1RO4GB-AGFE4F1RGREC5"
    .ascii  "O5C4C1RDE-DC5E-1D1CE-DC5R5"
    .ascii  "O5C4C1RO4GB-AGFE4F1RGREC5"
    .ascii  "O4A-8O5CE-D4C1RO4B-7R"
    .ascii  "O5C7EDCO4GB-AGAG5R5"
    .db     0xff

gameSoundBgmTheme_1:

    .ascii  "T1V16L3S0N2"
    .ascii  "M3XXM5XM3XXXM5XM3XM3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3XM3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3XM3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3XM3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3XM3XXM5XM3XXXM5XM3X"
    .ascii  "M3XXM5XM3XXXM5XM3XM3XXM5XM3XXXM5XM3X"
    .db     0xff

gameSoundBgmTheme_2:

    .ascii  "T1V15-3L3"
    .ascii  "O3C4C1O4CO3GB-AGFC4C1O4CO3GRAB-5"
    .ascii  "O3C4C1O4CO3GB-AGFC4C1O4CO3GRAB-5"
    .ascii  "O3F4F1O4CO3FA+GG+BF4F1O4CO3FB-AGA"
    .ascii  "O3C4C1O4CO3GB-AGFC4C1O4CO3GRAB-5"
    .ascii  "O2A-4O3E-1RA-5CEA-O2B-4O3FRB-5EFB-"
    .ascii  "O3C4G1RO4C5O3EGO4CO3B-AGAG5R5"
    .db     0xff

gameSoundBgmOver_0:

    .ascii  "T1V15-3L3"
    .ascii  "O4B-4G1A4F1G4E-1F4D1C5E-5C5R5"
    .db     0x00

gameSoundBgmOver_1:

    .ascii  "T1V15-3L3"
    .ascii  "O3G5F5E-5D5C5C5C5R5"
    .db     0x00

gameSoundBgmClear_0:

    .ascii  "T2V15-3L3"
    .ascii  "O5E4C1RE5CE1C4"
    .ascii  "O5E4C1RE5CE1C4"
    .ascii  "O5D4O4B-1RO5D5O4B-O5D1O4B-4"
    .ascii  "O5D4O4B-1RO5D5O4B-O5D1O4B-4"
    .db     0xff

gameSoundBgmClear_1:

    .ascii  "T2V15-3L3"
    .ascii  "O4G5RG6G5"
    .ascii  "O4G5RG6G5"
    .ascii  "O4F5RF6F5"
    .ascii  "O4F5RF6F5"
    .db     0xff

gameSoundBgmClear_2:

    .ascii  "T2V15-3L3"
    .ascii  "O4C5RCR5C5"
    .ascii  "O4C5RCR5C5"
    .ascii  "O3B-5RB-R5B-5"
    .ascii  "O3B-5RB-R5B-5"
    .db     0xff

gameSoundSeClick:

    .ascii  "T1V15L3O6BO5BR9"
    .db     0x00

gameSoundSeJump:

    .ascii  "T1V15L0O4A1O3AO4C+FAO5C+FA"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::
    
    .ds     GAME_LENGTH
