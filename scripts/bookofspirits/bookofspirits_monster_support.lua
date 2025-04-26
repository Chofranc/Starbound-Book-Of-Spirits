local bookOfSpiritInitCheck = init or function() end

function init() bookOfSpiritInitCheck()
  message.setHandler("bookOfSpiritsGetTitle", function(_,_)
    local tableResponse = {}
    tableResponse.title = status.statusProperty("displayTitle","")
    return tableResponse
  end)

  local bookOfSpiritsCheck = root.itemConfig("protectorateinfobooth").config
  if bookOfSpiritsCheck.npcName and bookOfSpiritsCheck.displayTitle then
		require("/monsters/bookofspirits_monster_core.lua")
  end
end
