--Credit goes to C0bra5 on the Starbound discord for fixing this!
--Go check out his awesome mod @ https://steamcommunity.com/sharedfiles/filedetails/?id=1348805475
--Prevented that nasty equip exploit
--Further credit goes to ZimberZimber on the FU discord for further fixing!
--Fixed the problem where stuff like Woggles weren't being damaged by the pack.
--Even further credit goes to Kherae of the FU discord for fixing the timers that caused silk to be produced at godspeed AND the whole timer and detection messes.


function init()
	if not self.postpone then
		self.item = config.getParameter("item")
		self.maxAmount = config.getParameter("maxAmount")
		self.configAmount = config.getParameter("amount")
		self.foodDelta = config.getParameter("foodDelta") --does pack change food delta from "1"? change this in json
		self.tickDamagePercentage = config.getParameter("tickDamagePercentage",0.030)
	end
	self.species=world.entitySpecies(entity.id())
	--sb.logInfo("race: %s",self.species)--if called while the player is logging in, will return nil
	if not self.species then
		self.postpone=5
		return
	end

    self.isWebber = world.entitySpecies(entity.id()) == "webber"
    self.processRate = config.getParameter(self.isWebber and "refreshWebber" or "refreshWrongSpecies",2.0)
	--sb.logInfo("process rate loaded as: %s",self.processRate)
	--self.processRate=10

    if self.isWebber then --Player is a webber?
        if self.foodDelta then--if food delta config parameter exists, set. if not, don't.
            self.effectHandler=effect.addStatModifierGroup({{stat = "foodDelta", baseMultiplier = self.foodDelta}}) --sets hunger drain via a variable. Normal value is "1"
        end
    end

    world.sendEntityMessage(entity.id(), "queueRadioMessage", self.isWebber and "silkcollectionstart" or "wrongspeciesusingsilkcollector", 1.0)--if webber, message 1. if not, message2.
	script.setUpdateDelta(5)
    self.init=true
end

function update(dt)
	if not self.init then
		if self.postpone then
			if self.postpone <= 0.0 then
				self.postpone=nil
				init()
			else
				self.postpone = self.postpone - dt
			end
		end
		return
	end

    if self.isWebber then
		if not self.silkTimer then
			self.silkTimer=0.0
		elseif self.silkTimer > self.processRate then
            local count = world.entityHasCountOfItem(entity.id(), self.item)
            local maxDrop = math.min(self.configAmount, 1000)
            for _, entityID in pairs (world.itemDropQuery(entity.position(), 5)) do
                if world.entityName(entityID) == self.item then
                    self.silkTimer=0.0
                    return
                end
            end

            if count and count < self.maxAmount then
                world.spawnItem(self.item, entity.position(), math.min(self.configAmount, self.maxAmount - count), {price = 50})
            end

            self.silkTimer=0.0
        else
            self.silkTimer=self.silkTimer+dt
        end
    else
        if not self.ouchTimer or self.ouchTimer > self.processRate then
			if not world.getProperty("ship.fuel") then--damage requests dont work on ships anyway
				status.applySelfDamageRequest({
					damageType = "IgnoresDef",
					damage = math.floor(status.resourceMax("health") * self.tickDamagePercentage) * 3, --deal a lot of damage.
					damageSourceKind = "poison",
					sourceEntityId = entity.id()
				})
			end
            self.ouchTimer=0.0
        else
            self.ouchTimer=self.ouchTimer+dt
        end
        if not self.timerRadioMessage or self.timerRadioMessage > 60.0 then
			if not world.getProperty("ship.fuel") then
				world.sendEntityMessage(entity.id(), "queueRadioMessage", self.isWebber and "silkcollectionstart" or "wrongspeciesusingsilkcollector", 1.0)--if webber, message 1. if not, message2.
			end
            self.timerRadioMessage=0.0
        else
            self.timerRadioMessage=self.timerRadioMessage+(dt * (world.getProperty("ship.fuel") and 10 or 1)) --throttle down the message spam on ships
        end
    end
end

function uninit()
	if self.effectHandler then
		effect.removeStatModifierGroup(self.effectHandler)--this prevents orphaned stat modifier groups, which translates to doubled effects. only happens on reload, usually.
		self.effectHandler=nil
	end
	self.init=false
end
