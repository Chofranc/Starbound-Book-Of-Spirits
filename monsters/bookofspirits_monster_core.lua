local bookOfSpiritOldInit = init or function() end
local bookOfSpiritOldUpdate = update or function() end

function init() bookOfSpiritOldInit()
  message.setHandler("bookOfSpiritsGetTitle", function(_,_)
    local tableResponse = {}
    tableResponse.title = status.statusProperty("displayTitle","")
    return tableResponse
  end)
end

function update(dt) bookOfSpiritOldUpdate(dt)
 if not testString then
    local myId = entity.id()
    if world.entityName(myId) == "" then
      local monsterType = monster.type()
		local portrait = world.entityPortrait(myId,"full")
      local monsterParts = {}
      local monsterHead = ""
      for i, value in pairs(portrait) do
        local partPath = portrait[i].image
        local endIndex = partPath:match'^.*()/'-1
        partPath = partPath:sub(0,endIndex)
        local partFolderName = partPath:match'%w+$'
        if monsterParts[1] ~= partFolderName then
          monsterParts[i] = partFolderName
        end
        if monsterHead == "" then
          if string.find(partPath,"head") then
            monsterHead = partFolderName
          end
        end
    	end

      local bosgeneratedConfig = root.assetJson("/monsters/bookofspirits_generated.config")
      local monsterName, prefix, skillPrefix, title = "", "", "", ""
      local exactPrefixMatch = false
      local addSkillPrefix = true
      local monsterPartMax = #monsterParts
      -- Monster Name and Title Search --
      for typeName, typeList in pairs(bosgeneratedConfig.monsterTypes) do
        if monsterType == typeName then -- Monster Type Found, search for the name in the variants
          for _, variantList in pairs(typeList.variants) do
            local partMatchCount = 0
            local partListMax = #variantList.parts
            if partListMax == 1 then -- Variant haves only 1 part(head)
              if variantList.parts[1] == monsterHead then
                  partMatchCount = partMatchCount + 1
              end
            else
              -- Variant haves a part pattern(more than 1 part)
              for i=1,partListMax do
                for k=1,monsterPartMax do
                  if variantList.parts[i] == monsterParts[k] then
                    partMatchCount = partMatchCount + 1
                    break
                  end
                end
              end
            end
			
            if partMatchCount == partListMax then -- Match found
              monsterName = variantList.name
              prefix = variantList.prefix or ""
              title = variantList.title
              if variantList.addSkillPrefix ~= nil then
                addSkillPrefix = variantList.addSkillPrefix
              else
                addSkillPrefix = true
              end
              if partListMax > 1 then break end -- If it was a pattern, exit
            end
          end
          break
        end
      end
     -- Monster Name and Title Search --
     -- Prefix Search --
     local asSuffix = false
     if addSkillPrefix then
        local skills = config.getParameter("skills", {})
        for _,skillName in pairs(skills) do
          local skillHostileActions = root.monsterSkillParameter(skillName, "hostileActions")
          if skillHostileActions then
            skillName = skillName:lower()
            for _, variantList in pairs(bosgeneratedConfig.skillPrefixes) do
              if string.find(skillName, variantList.skillName) then
                skillPrefix = variantList.name
                if variantList.asSuffix then
                  asSuffix = true
                else
                  asSuffix = false
                end
                if variantList.skillName == skillName then break end
              end
            end
          end
        end
      end
      -- Prefix Search --

      if monsterName ~= "" then
        if asSuffix then
          monsterName = prefix.." "..monsterName.." "..skillPrefix
        else
          monsterName = prefix.." "..skillPrefix.." "..monsterName
        end
        monster.setName(monsterName)
      end

      if config.getParameter("elite", false) then
        if title ~= "" then
          title = bosgeneratedConfig.eliteString.." "..title
        else
          title = bosgeneratedConfig.eliteMonsterString
        end
        title = "^red;"..title
      end

      if title ~= "" then
        status.setStatusProperty("displayTitle",title)
      end
    end
	testString = true
 end
end
