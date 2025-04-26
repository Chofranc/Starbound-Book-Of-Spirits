local bookOfSpirits_interact = interact or function() end
local bookOfSpirits_init = init or function() end
local bookOfSpirits_update = update or function() end

function init() bookOfSpirits_init()
  self.myId = entity.id()
  self.renamerWindow = 0.5
  self.renamerWindowTimer = 0
  self.petParamsSender = {} -- Use this to store data of the pet on the spawner object(Only used by non-techstation pets)

  message.setHandler("bookOfSpiritsPetShipRenamer", function(_,_, petNewName)
    monster.setName(petNewName)
    storage.newPetName = petNewName
    self.petParamsSender.petName = petNewName
    self.updateAnchorTimer = 0 -- Triggers updateAnchor to call setAnchor and update petParams in the spawner object
  end)
end

function update(dt) bookOfSpirits_update(dt)
  if not self.finishInit then
    storage.newPetName = storage.newPetName or nil -- For techstation pet and ship pets that don't despawn
    local newPetName = config.getParameter("petName", nil) -- For non-techstation pets
    if newPetName == nil and storage.newPetName ~= nil then
      newPetName = storage.newPetName
    end
    if newPetName ~= nil then
      monster.setName(newPetName) -- Doesn't work on init, that's why it goes here
      self.petParamsSender.petName = newPetName
    end
    self.finishInit = true
  end

  -- CODE FOR FU COMPATIBILITY --
    if self.interactionType ~= nil and self.renamerWindowTimer > 0 then
      monster.setInteractive(true)
    end
  -- CODE FOR FU COMPATIBILITY --

  self.renamerWindowTimer = math.max(0,self.renamerWindowTimer - dt)
end

function setAnchor(entityId) -- HAD TO BE REPLACED ENTIRELY
  if not self.anchorId or self.anchorId == entityId or not world.entityExists(self.anchorId) then
    storage.anchorPosition = world.entityPosition(entityId)
    self.anchorId = entityId
    self.petParamsSender.foodLikings = storage.foodLikings
    self.petParamsSender.knownPlayers = storage.knownPlayers
    self.petParamsSender.petResources = storage.foodLikings
    self.petParamsSender.petResources = petResources()
    self.petParamsSender.seed = monster.seed()
    world.callScriptedEntity(entityId, "setPet", entity.id(), self.petParamsSender)
    return true
  else
    return false
  end
end

function interact(args) bookOfSpirits_interact()
  if self.renamerWindowTimer > 0 then
    world.sendEntityMessage(args.sourceId,"bookOfSpiritsPetShipRenamer",args.sourceId,self.myId)
    self.renamerWindowTimer = 0
  end
  self.renamerWindowTimer = self.renamerWindow
  world.sendEntityMessage(args.sourceId,"bookOfSpiritsMonsterInteract",self.myId)
end

