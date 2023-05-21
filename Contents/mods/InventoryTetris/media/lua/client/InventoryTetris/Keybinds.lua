local bind = {};
bind.value = "[InventoryTetris]";
table.insert(keyBinding, bind);

bind = {};
bind.value = "tetris_rotate_item";
bind.key = Keyboard.KEY_R;
table.insert(keyBinding, bind);

bind = {};
bind.value = "tetris_quick_move";
bind.key = Keyboard.KEY_LCONTROL;
table.insert(keyBinding, bind);

bind = {};
bind.value = "tetris_quick_equip";
bind.key = Keyboard.KEY_LMENU;
table.insert(keyBinding, bind);

bind = {};
bind.value = "tetris_stack_split";
bind.key = Keyboard.KEY_LCONTROL;
table.insert(keyBinding, bind);
