local bookOfSpiritInitCheck = init or function() end

function init() bookOfSpiritInitCheck()
  local bookOfSpiritsCheck = root.itemConfig("protectorateinfobooth").config
  if bookOfSpiritsCheck.npcName and bookOfSpiritsCheck.displayTitle then
		local bookOfSpiritsType = entity.entityType()
		if bookOfSpiritsType == "npc" then
			require("/npcs/bookofspirits_interact.lua")
		else
			require("/objects/bookofspirits_chattyobj.lua")
		end
  end
end
