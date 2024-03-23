; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_PATTERN_NAME_TABLE          =   0x3000
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_COLOR_TABLE                 =   0x1800
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; アプリケーション
APP_STATE                       =   0x00
APP_COURSE                      =   0x01
APP_LENGTH                      =   0x02

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_TITLE_INITIALIZE      =   0x01
APP_STATE_TITLE_UPDATE          =   0x02
APP_STATE_GAME_INITIALIZE       =   0x03
APP_STATE_GAME_UPDATE           =   0x04
APP_STATE_DEBUG_INITIALIZE      =   0x05
APP_STATE_DEBUG_UPDATE          =   0x06

; コース
APP_COURSE_NULL                 =   0x00
APP_COURSE_ENTRY                =   0x0100

; 記録
APP_RECORD_TIME_L               =   0x00
APP_RECORD_TIME_H               =   0x01
APP_RECORD_LENGTH               =   0x02

; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppGetCourseNumber
    .globl  _AppUpdateRecord

; 外部変数宣言
;

    .globl  _appBcdNumber
    .globl  _appBcdMillisecond
    .globl  _appBcdCentimeter
    .globl  _app
    .globl  _appRecord
    