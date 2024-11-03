runner.Behaviors.BaseBehavior = class({}, "BaseBehavior")
local BaseBehavior = runner.Behaviors.BaseBehavior
runner.Behaviors.BaseBehavior = BaseBehavior

function BaseBehavior:init()
    self.Name = "BaseBehavior"
    self.Type = "Base"
end

function BaseBehavior:Run()
end

registerBehavior("Base",BaseBehavior)