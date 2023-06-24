local TestObjectFactory = {}

TestObjectFactory.baseballBat = function (container)
    local item = InventoryItemFactory.CreateItem("Base.BaseballBat")
    if container then
        container:AddItem(item)
    end
    return item
end

TestObjectFactory.duffelBag = function (container)
    local item = InventoryItemFactory.CreateItem("Base.Bag_DuffelBag")
    if container then
        container:AddItem(item)
    end
    return item
end

return TestObjectFactory
