runner.Behaviors.IfBehavior = runner.Behaviors.BaseBehavior:extend()
local IfBehavior = runner.Behaviors.IfBehavior
runner.Behaviors.IfBehavior = IfBehavior

function IfBehavior:init()
    self.Name = "IfBehavior"
    self.Type = "If"
    self.Step = {
        condition = "",
        children = {},
    }
    self.IsComplete = false
    self.CanHaveChildren = true
end

function IfBehavior:Run()
    if self.Step.condition == "" then
        self.IsComplete = true
        return
    else
        local cond = self.Step.condition
        local result = loadstring("return " .. cond)()
        if result then
            for k,v in pairs(self.Step.children) do
                v:Run()
                if v.IsComplete then
                    self.IsComplete = true
                    return
                end
            end
        else
            self.IsComplete = true
            return
        end
    end
end

function IfBehavior:Debug()

end

function IfBehavior:Save()
    return {
        Name = self.Name,
        Type = self.Type,
        condition = self.Step.condition,
        children = self:SaveChildren(),
    }
end

function IfBehavior:Load(data)
    self.Step.condition = data.condition
    self.Step.children = self:LoadChildren(data.children)
end

function IfBehavior:SaveChildren()
    local children = {}
    for k,v in pairs(self.Step.children) do
        table.insert(children, v:Save())
    end
    return children
end

function IfBehavior:LoadChildren(data)
    local children = {}
    for k,v in pairs(data) do
        print(v.Name:lower())
        local behavior = runner.behaviors[v.Name:lower()]:new()
        behavior:Load(v)
        table.insert(children, behavior)
    end
    return children
end

function IfBehavior:BuildStepGUI(container)
    container:ReleaseChildren()

    local conditionEditBox = runner.AceGUI:Create("EditBox")
    conditionEditBox:SetLabel("Condition")
    conditionEditBox:SetWidth(300)
    conditionEditBox:SetText(self.Step.condition)
    conditionEditBox:SetCallback("OnTextChanged", function(widget, event, value)
        self.Step.condition = value
    end)
    container:AddChild(conditionEditBox)
end

registerBehavior("IfBehavior", IfBehavior)