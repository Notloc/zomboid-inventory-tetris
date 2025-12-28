local Version = require("Notloc/Versioning/Version")

-- Intentional global
InventoryTetris = {
    version = Version:new(6, 11, 4, "beta"),
}

print("InventoryTetris version: " .. Version.format(InventoryTetris.version))

return InventoryTetris
