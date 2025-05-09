require "/scripts/util.lua"

function init()
	self.autoDismissTimer = status.stat("bookOfSpiritsDuration", 2.0)
	wNamePos = widget.getPosition("namePlateLayout.entityName")
end

function update(dt)
	local bookOfSpiritsParams = status.statusProperty("bookOfSpiritsParams",{})
	if bookOfSpiritsParams.name == nil then
		widget.setVisible("namePlateLayout",false)
		pane.dismiss()
	else
		widget.setVisible("namePlateLayout",true)
		if bookOfSpiritsParams.capturable then
			if bookOfSpiritsParams.entityId ~= nil then
				if world.entityExists(bookOfSpiritsParams.entityId) and bookOfSpiritsParams.capturableTreshold > 0 then
					local health = world.entityHealth(bookOfSpiritsParams.entityId)
					if health[1]/health[2] <= bookOfSpiritsParams.capturableTreshold then
						widget.setVisible("namePlateLayout.capturable_glow",true)
					end
				else
					widget.setVisible("namePlateLayout.capturable_glow",false)
				end
			end
			widget.setVisible("namePlateLayout.capturable",true)
		else
			widget.setVisible("namePlateLayout.capturable",false)
			widget.setVisible("namePlateLayout.capturable_glow",false)
		end
		local name = bookOfSpiritsParams.name
		if bookOfSpiritsParams.nameOverride ~= "" then name = bookOfSpiritsParams.nameOverride end
		widget.setText("namePlateLayout.entityName",name)
		widget.setText("namePlateLayout.entityType",bookOfSpiritsParams.title)

		if bookOfSpiritsParams.title == "" then
			widget.setVisible("namePlateLayout.bgType",false)
			widget.setPosition("namePlateLayout.entityName",wNamePos)
		else
			widget.setVisible("namePlateLayout.bgType",true)
			widget.setPosition("namePlateLayout.entityName",{wNamePos[1],wNamePos[2]+2})
		end
	end

	self.autoDismissTimer =  math.max(0, self.autoDismissTimer - dt)

	if status.statPositive("bookOfSpiritsDuration") then
		self.autoDismissTimer = status.stat("bookOfSpiritsDuration", 2.0)
		status.setPersistentEffects("bookofspiritdisplay", {{stat = "bookOfSpiritsOpen", amount = 1}})
	end

	if self.autoDismissTimer == 0 then
		pane.dismiss()
	end
end

function uninit()
	status.clearPersistentEffects("bookofspiritdisplay")
end
