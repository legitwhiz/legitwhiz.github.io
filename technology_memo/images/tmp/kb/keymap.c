#include QMK_KEYBOARD_H
#include "keymap_jp.h"

// 1. マクロ用のキーコード名の宣言
enum custom_keycodes {
    M_HNZN = SAFE_RANGE    // IMEトグル用
};

// 2. マクロの実装
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (record->event.pressed) {
        switch(keycode) {
            case M_HNZN:
                    SEND_STRING(SS_LALT("`"));
                return false;
        }
    }
    return true;
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
	[0] = LAYOUT_4key_2u_inner(KC_ESC, KC_1, KC_2, KC_3, KC_4, KC_5, KC_MINS, KC_EQL, KC_6, KC_7, KC_8, KC_9, KC_0, KC_JYEN, KC_TAB, KC_Q, KC_W, KC_E, KC_R, KC_T, KC_LBRC, KC_RBRC, KC_Y, KC_U, KC_I, KC_O, KC_P, KC_NUHS, KC_LCTL, KC_A, KC_S, KC_D, KC_F, KC_G, KC_SLSH, KC_QUOT, KC_H, KC_J, KC_K, KC_L, KC_SCLN, KC_RCTL, KC_LSFT, KC_Z, KC_X, KC_C, KC_V, KC_B, KC_HOME, KC_END, KC_N, KC_M, KC_COMM, KC_DOT, KC_UP, KC_RSFT, M_HNZN, KC_LGUI, KC_LALT, KC_RO, MO(1), KC_ENT, KC_SPC, KC_BSPC, KC_ENT, MO(1), TO(1), KC_LEFT, KC_DOWN, KC_RGHT),
	[1] = LAYOUT_4key_2u_inner(KC_TRNS, KC_F1, KC_F2, KC_F3, KC_F4, KC_F5, KC_F11, KC_ACL0, KC_F6, KC_F7, KC_F8, KC_F9, KC_F10, KC_PSCR, KC_CAPS, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_ACL1, KC_WH_L, KC_WH_D, KC_WH_U, KC_WH_R, KC_NO, KC_NO, KC_TRNS, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_ACL2, KC_LEFT, KC_DOWN, KC_UP, KC_RGHT, KC_NO, KC_TRNS, KC_TRNS, KC_MS_U, KC_NO, KC_NO, KC_NO, KC_NO, KC_TRNS, KC_TRNS, KC_BTN1, KC_BTN2, KC_BTN3, KC_BTN4, KC_TRNS, KC_TRNS, KC_MS_L, KC_MS_D, KC_MS_R, KC_NO, KC_TRNS, KC_TRNS, KC_TRNS, KC_DEL, KC_TRNS, KC_TRNS, TO(2), KC_TRNS, KC_TRNS, KC_TRNS),
	[2] = LAYOUT_4key_2u_inner(KC_NO, RESET, RGB_TOG, RGB_MOD, RGB_RMOD, RGB_HUI, RGB_HUD, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, RGB_SAI, RGB_SAD, RGB_VAI, RGB_VAD, RGB_SPI, RGB_SPD, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, RGB_M_P, RGB_M_B, RGB_M_R, RGB_M_SW, RGB_M_SN, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, RGB_M_K, RGB_M_X, RGB_M_G, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_NO, KC_TRNS, TO(0), KC_NO, KC_NO, KC_NO)
};
