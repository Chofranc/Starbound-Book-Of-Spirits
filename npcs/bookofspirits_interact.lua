local bookOfSpirits_setInteracted = setInteracted or function() end

function setInteracted(args) bookOfSpirits_setInteracted(args)	
  local myId = entity.id()
  world.sendEntityMessage(args.sourceId,"bookOfSpiritsNPCInteract",myId)
end

