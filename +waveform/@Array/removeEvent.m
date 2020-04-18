function removeEvent(obj,eventName)

if ~any(strcmp(eventName,W.eventNames))
    me.identifier = 'Waves:getEpochData:UnrecognizedEventName';
    me.message    = sprintf('Unrecognized event name "%s"',eventName);
    me.stack      = dbstck('-completenames');
    error(me);
end

obj.event = rmfield(obj.event,eventName);
