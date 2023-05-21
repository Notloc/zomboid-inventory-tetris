if not INVENTORY_TETRIS_SETTINGS then
    INVENTORY_TETRIS_SETTINGS = {}
    
    INVENTORY_TETRIS_SETTINGS.OnApplyScale = NotUtil.createEvent()
    INVENTORY_TETRIS_SETTINGS.applyScale = function(self, scale)
        self.SCALE = scale
        self.TEXTURE_SIZE = 32 * self.SCALE;
        self.TEXTURE_PAD = 3 * self.SCALE;
        self.CELL_SIZE = self.TEXTURE_SIZE + self.TEXTURE_PAD * 2 + 1
        self.ICON_SCALE = self.TEXTURE_SIZE / 32

        self.OnApplyScale:trigger(scale)
    end

    INVENTORY_TETRIS_SETTINGS:applyScale(1)
end

return INVENTORY_TETRIS_SETTINGS
