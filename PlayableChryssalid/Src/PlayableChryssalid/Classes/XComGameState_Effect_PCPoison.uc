class XComGameState_Effect_PCPoison extends XComGameState_Effect;

function EventListenerReturn OnUnitDiedWithPCParthenogenicPoison(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local X2Effect_PCParthenogenicPoison EffectTemplate;
	local XComGameState_Unit TargetUnitState;
	local XComGameStateHistory History;
	local XComGameState NewGameState;

	`log("OnUnitDiedWithPCParthenogenicPoison triggered!",, 'XComGameState_Effect_PCPoison');
	
	History = `XCOMHISTORY;

	TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EffectTemplate = X2Effect_PCParthenogenicPoison(GetX2Effect());

	if( TargetUnitState == none )
	{
		`RedScreen("TargetUnitState in OnUnitDiedWithPCParthenogenicPoison does not exist.");
	}	
	else if( EffectTemplate == none )
	{
		`RedScreen("EffectTemplate in OnUnitDiedWithPCParthenogenicPoison does not exist.");
	}
	else
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("OnUnitDiedWithPCParthenogenicPoison");
		EffectTemplate.TriggerSpawnEvent(ApplyEffectParameters, TargetUnitState, NewGameState, self);
		SubmitNewGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}
