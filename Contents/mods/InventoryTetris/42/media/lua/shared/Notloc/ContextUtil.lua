local ContextUtil = {}

---@param context ISContextMenu
---@param subMenuName string
---@return ISContextMenu|nil
function ContextUtil.getSubMenu(context, subMenuName)
    local subMenuOption = nil;
    for _, option in ipairs(context.options) do
        if option.name == subMenuName then
            subMenuOption = option
            break
        end
    end
    if not subMenuOption then return nil end
    return context:getSubMenu(subMenuOption.subOption)
end

---@param context ISContextMenu
---@param subMenuName string
---@return ISContextMenu
function ContextUtil.getOrCreateSubMenu(context, subMenuName, targets)
    local subMenu = ContextUtil.getSubMenu(context, subMenuName)
    if not subMenu then
        local subMenuOption = context:addOption(subMenuName, targets, nil);
        subMenu = context:getNew(context);
        context:addSubMenu(subMenuOption, subMenu);
    end
    return subMenu
end

---@param context ISContextMenu
---@param optionName string
---@return table|nil
function ContextUtil.getOptionByName(context, optionName)
    for _, option in ipairs(context.options) do
        if option.name == optionName then
            return option
        end
    end
    return nil
end

return ContextUtil