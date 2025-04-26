require "/scripts/util.lua"

function init()
	autoDismissTimer = status.stat("bookOfSpiritsDuration", 2.0)
	wNamePos = widget.getPosition("namePlateLayout.entityName")
	widget.setPosition("namePlateLayout.entityName",{wNamePos[1],wNamePos[2]+2})
end

function update(dt)
	local entityName = status.statusProperty("bookOfSpiritsName","")
	local entityTitle = status.statusProperty("bookOfSpiritsType","")

	if entityName == "" then
		widget.setVisible("namePlateLayout",false)
		pane.dismiss()
	else
		widget.setVisible("namePlateLayout",true)
	end

	if entityTitle == "" then
		widget.setVisible("namePlateLayout.bgType",false)
		widget.setPosition("namePlateLayout.entityName",wNamePos)
	else
		widget.setVisible("namePlateLayout.bgType",true)
		widget.setPosition("namePlateLayout.entityName",{wNamePos[1],wNamePos[2]+2})
	end

	widget.setText("namePlateLayout.entityName",entityName)
	widget.setText("namePlateLayout.entityType",entityTitle)

	autoDismissTimer =  math.max(0, autoDismissTimer - dt)

	if status.statPositive("bookOfSpiritsDuration") then
		autoDismissTimer = status.stat("bookOfSpiritsDuration", 2.0)
		status.setPersistentEffects("bookofspiritdisplay", {{stat = "bookOfSpiritsOpen", amount = 1}})
	end

	if autoDismissTimer == 0 then
		pane.dismiss()
	end
end

function uninit()
	status.clearPersistentEffects("bookofspiritdisplay")
end
