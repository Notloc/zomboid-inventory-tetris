if not INVENTORY_TETRIS_SETTINGS then
    INVENTORY_TETRIS_SETTINGS = {}
    
    INVENTORY_TETRIS_SETTINGS.OnApplyGridScale = NotUtil.createSimpleEvent()
    INVENTORY_TETRIS_SETTINGS.applyGridScale = function(self, scale)
        self.SCALE = scale
        self.TEXTURE_SIZE = 32 * self.SCALE;
        self.TEXTURE_PAD = 2 * self.SCALE;
        self.CELL_SIZE = self.TEXTURE_SIZE + self.TEXTURE_PAD * 2 + 1
        self.ICON_SCALE = self.TEXTURE_SIZE / 32

        self.DOUBLE_CLICK_ACTION = "interact"


        self.OnApplyGridScale:trigger(scale)
    end

    INVENTORY_TETRIS_SETTINGS.OnApplyContainerInfoScale = NotUtil.createSimpleEvent()
    INVENTORY_TETRIS_SETTINGS.applyContainerInfoScale = function(self, scale)
        self.CONTAINER_INFO_SCALE = scale
        self.OnApplyContainerInfoScale:trigger(scale)
    end
    INVENTORY_TETRIS_SETTINGS:applyContainerInfoScale(1)


    INVENTORY_TETRIS_SETTINGS.applyDoubleClickAction = function(self, action)
        self.DOUBLE_CLICK_ACTION = action
    end

    INVENTORY_TETRIS_SETTINGS.applyCtrlClickAction = function(self, action)
        self.CTRL_CLICK_ACTION = action
    end

    INVENTORY_TETRIS_SETTINGS.applyAltClickAction = function(self, action)
        self.ALT_CLICK_ACTION = action
    end

    INVENTORY_TETRIS_SETTINGS.applyShiftClickAction = function(self, action)
        self.SHIFT_CLICK_ACTION = action
    end



    -- Load Default Settings
    INVENTORY_TETRIS_SETTINGS:applyGridScale(1)
    INVENTORY_TETRIS_SETTINGS:applyDoubleClickAction("interact")
    INVENTORY_TETRIS_SETTINGS:applyCtrlClickAction("move")
    INVENTORY_TETRIS_SETTINGS:applyAltClickAction("equip")
    INVENTORY_TETRIS_SETTINGS:applyShiftClickAction("drop")

end

return INVENTORY_TETRIS_SETTINGS
