local Version = require("Notloc/Versioning/Version")

InventoryTetris = {
    version = Version:new(6, 8, 0, "beta"),
}

print("InventoryTetris version: " .. Version.format(InventoryTetris.version))