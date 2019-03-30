function init()
    self.species=world.entitySpecies(entity.id())

  if self.species ~= "webber" then
    self.effectHandler=effect.addStatModifierGroup({{stat = "foodDelta", baseMultiplier = 20.0}})
    world.sendEntityMessage(entity.id(), "queueRadioMessage", "webbermeatillness",1)
    status.removeEphemeralEffect("wellfed",math.huge)
  else
    status.removeEphemeralEffect("webbermeat",math.huge)
  end
end

function update(dt)
end

function uninit()

end
