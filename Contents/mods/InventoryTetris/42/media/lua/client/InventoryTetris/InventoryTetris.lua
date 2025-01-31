local Version = require("Notloc/Versioning/Version")

-- Intentional global
InventoryTetris = {
    version = Version:new(6, 9, 1, "beta"),
}

print("InventoryTetris version: " .. Version.format(InventoryTetris.version))

return InventoryTetris
