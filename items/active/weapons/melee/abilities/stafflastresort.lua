--initiate weapon alt ability
lastresort = WeaponAbility:new()

function lastresort:init()
  self.damageConfig.baseDamage = self.baseDamage or self.baseDps * self.fireTime --Basic logic. Does less damage per hit if the swing is faster, but keeps DPS.
  --DPS / Seconds = actual damage per hit and so on.
  self.energyUsage = self.energyUsage or 0 --By default, do NOT use any energy or interrupt energy
  --If this was not set to 0 there would be no point in having staffs having this effect. If players get CAUGHT MID-BATTLE WITHOUT ENOUGH ENERGY TO USE THE STAFF,
  --BAD THINGS WILL HAPPEN IF THEY DON'T HAVE A BACKUP.
  self.cooldownTimer = self:cooldownTime() --cooldown
end
--Constantly update
function lastresort:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)

  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt) --cooldown

  if not self.weapon.currentAbility and self.fireMode == "alt" and self.cooldownTimer == 0 and self.energyUsage == 0 then --check to see if player is not using energy, not already in cool down, and is alt.
    self:setState(self.windup)
  end
end
-- Dear god I barely understand what the FUCK lua is and I've fucked up before in a big project
-- Hopefully that does NOT happen again.
-- BTW it was a typo that had CRASHED the game lololol always remember rubber ducky
-- Where is my rubber duck though, do I even have one?
function lastresort:windup()
  self.weapon:setStance(self.stances.windup)

  if self.stances.windup.hold then
    while self.fireMode == "alt" do
      coroutine.yield()
    end
  else
    util.wait(self.stances.windup.duration)
  end

  if self.energyUsage then
    status.overConsumeResource("energy", self.energyUsage)
  end

  if self.stances.preslash then
    self:setState(self.preslash)
  else
    self:setState(self.fire)
  end
end

function lastresort:preslash()
  self.weapon:setStance(self.stances.preslash)
  self.weapon:updateAim()

  util.wait(self.stances.preslash.duration)

  self:setState(self.fire) --set to the fire function
end

function lastresort:fire() --do attack, creates hitbox that deals damage
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()

  animator.setAnimationState("altswoosh", "fire")
  animator.playSound(self.fireSound or "altFire")
  animator.burstParticleEmitter("altswoosh")

  util.wait(self.stances.fire.duration, function()
    local damageArea = partDamageArea("altSwoosh")
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
  end)

  self.cooldownTimer = self:cooldownTime() --Cooldown time set
end

function lastresort:cooldownTime() --set cooldown time
  return self.fireTime - self.stances.windup.duration - self.stances.fire.duration
end

function lastresort:uninit() --uninitiate attack
  self.weapon:setDamage()
end
