
function init()
	self.name = ""
	self.petId = status.stat("petRenamingId")
end

function btnOk()
	if self.name ~= "" then
		world.sendEntityMessage(self.petId,"bookOfSpiritsPetShipRenamer",self.name)
	end
	btnClose()
end

function btnClose()
	pane.dismiss()
end

function txtboxName()
	self.name = widget.getText("txtboxName")
end
