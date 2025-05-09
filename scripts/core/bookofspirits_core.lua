function init() 
    self.bookOfSpiritsConfig = root.assetJson("/bookofspirits.config")
    self.previousEntity = {typeName = "", name = "", nameOverride = "",title = "", entityId = nil,capturable = false, capturableTreshold = 0}
	status.clearPersistentEffects("bookofspiritdisplay")
	self.petRenamerIdGroup = {}
	_, dmgHeartbeat = status.inflictedDamageSince()
	-- On Interact --
	message.setHandler("bookOfSpiritsNPCInteract", function(_,_, npcId,isObject)
		isObject = isObject or false
		if world.entityExists(npcId) then
			local type = "npc"
			if isObject then type = "object" end
			setEntity(npcId,type)
		end
	end)

	message.setHandler("bookOfSpiritsMonsterInteract", function(_,_, entityId)
		if world.entityExists(entityId) then
			setEntity(entityId,"monster")
		end
	end)

	message.setHandler("bookOfSpiritsPetShipRenamer", function(_,_, sourceId, petId)
		if player.uniqueId() == (player.ownShipWorldId()):gsub("ClientShipWorld:","") then
			status.setPersistentEffects("petRenamingActive",{{stat = "petRenamingId" , amount = petId}})
			player.interact("ScriptPane","/interface/scripted/shippetrenamer/shippetrenamer.config",sourceId)
		end
	end)
	-- On Interact --
	self.getTitle = nil

	-- Send me a radio message about the pet ship renamer if im the owner of the ship
	if not status.statPositive("bookOfSpiritsRenamerMessageRead") then
		if player.uniqueId() == (player.ownShipWorldId()):gsub("ClientShipWorld:","") then
			player.radioMessage("bookOfSpiritsShipPetRenamerAvailable")
		end
	end
end

function update(dt)
	local dmgNotifications = nil
	dmgNotifications, dmgHeartbeat = status.inflictedDamageSince(dmgHeartbeat)
	if #dmgNotifications > 0 then
		for index,notification in pairs(dmgNotifications) do
			local entityType = world.entityType(notification.targetEntityId)
			if notification.sourceEntityId ~= notification.targetEntityId and entityType ~= "object"
			and notification.healthLost > 0 and world.entityExists(notification.targetEntityId) then
				setEntity(notification.targetEntityId,entityType,index)
			end
		end
	end

	if self.getTitle then
		if self.getTitle:finished() then
			if self.getTitle:succeeded() then
				local tableResult = {}
				tableResult = self.getTitle:result()
				if tableResult.title ~= "" and tableResult.id == self.previousEntity.entityId then
					self.previousEntity.title = tableResult.title
					status.setStatusProperty("bookOfSpiritsParams",self.previousEntity)
				end
			end
			self.getTitle = nil
		end
	end
end

function setEntity(entityId, type, index)
	local name = world.entityName(entityId) -- Shortdescription, Identity Name, npcName, Player Name. IE: Big Ape
	local typeName = world.entityTypeName(entityId) -- type. IE: apeboss
	type = type or world.entityType(entityId) -- object, npc, player, monster, etc.
	index = index or 1

	if index == 1 then -- If in damage notification. Only take the first hitted entity
		if self.previousEntity.name ~= name then -- New entity hit
			self.previousEntity = {typeName = typeName, name = name, nameOverride = "",title = "" , entityId = entityId,capturable = false, capturableTreshold = 0}
			if type == "npc" then
				local title = root.npcConfig(typeName).displayTitle or ""
				if root.npcConfig(typeName).displayTitleAsName ~= nil and self.bookOfSpiritsConfig.displayTitleAsName then
					self.previousEntity.nameOverride = title
				else
					self.previousEntity.title = title
				end
			elseif type == "monster" then
				self.previousEntity.title = root.monsterParameters(typeName).statusSettings.statusProperties.displayTitle or world.getProperty("title_" .. name) or ""
				self.previousEntity.capturable = root.monsterParameters(typeName).capturable or false
				self.previousEntity.capturableTreshold = root.monsterParameters(typeName).captureHealthFraction or 0
				if self.previousEntity.title == "" then
					self.getTitle = world.sendEntityMessage(entityId, "bookOfSpiritsGetTitle")
				end
			elseif type == "object" then
				name = world.getObjectParameter(entityId,"npcName","")
				self.previousEntity.name = name
				title = world.getObjectParameter(entityId,"displayTitle","")
				if name == "" then
					self.previousEntity.name = title
				else
					self.previousEntity.title = title
				end
			end
		end
		if name ~= "" then
			if not status.statPositive("bookOfSpiritsOpen") then
				player.interact("ScriptPane","/interface/scripted/bookofspirits/bookofspirits.config")
			end
			status.setPersistentEffects("bookofspiritdisplay", {{stat = "bookOfSpiritsOpen", amount = 1},{stat = "bookOfSpiritsDuration", amount = self.bookOfSpiritsConfig.displayDuration}})
			status.setStatusProperty("bookOfSpiritsParams",self.previousEntity)
		else
			status.setStatusProperty("bookOfSpiritsParams",{})
		end
	end
end

function uninit()
	status.clearPersistentEffects("petRenamingActive")
	status.clearPersistentEffects("bookofspiritdisplay")
end
