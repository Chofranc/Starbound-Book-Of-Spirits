local bookOfSpiritsOnInteraction = onInteraction or function() end

function onInteraction(args) bookOfSpiritsOnInteraction(args)
  local myId = entity.id()
  world.sendEntityMessage(args.sourceId,"bookOfSpiritsNPCInteract",myId,true)
end

