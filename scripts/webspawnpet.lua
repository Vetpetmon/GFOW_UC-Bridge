function init() --when the object is created
	storage.spawnTimer = storage.spawnTimer and 0.5 or 0 --spawnpet timer
	storage.petParams = storage.petParams or {}

	self.monsterType = config.getParameter("shipPetType", "petskutzer") --this spawns a skutzer as a default setting. It spawns in as a ship pet.
	self.spawnOffset = config.getParameter("spawnOffset", {0, 2}) --spawnOffset is in co-ords, like (x,y), from the center of the object. It MUST be above 1 in the y value, or else the pet either 1. clips through the floor or 2. is stucc.
	message.setHandler("getPetInfo", function ()
		petInfo = {petId = self.petId, petType = self.monsterType}
		return petInfo
    end)
end

function hasPet() --check for pet
	return self.petId ~= nil
end

function setPet(entityId, params) --set pet
	if self.petId == nil or self.petId == entityId then
		self.petId = entityId
		storage.petParams = params
	else
		return false
	end
end

function update(dt) --check
	if self.petId and not world.entityExists(self.petId) then --check to see if the pet exists.
		self.petId = nil
	end

	if storage.spawnTimer < 0 and self.petId == nil then
		storage.petParams.level = 9 --level of pet
		storage.petParams.damageTeamType = "ghostly" --your pet is safe from ALL harm. Like the stupid ghost on those moons.
		storage.petParams.capturable = false --YA AIN'T GONNA CAPTURE THE PET. The heck?? why???
		storage.petParams.captureHealthFraction = 1 --health value.
		self.petId = world.spawnMonster(self.monsterType, object.toAbsolutePosition(self.spawnOffset), storage.petParams)
		world.callScriptedEntity(self.petId, "setAnchor", entity.id())
		storage.spawnTimer = 0.5
	else
		storage.spawnTimer = storage.spawnTimer - dt
	end
end
