class X2Effect_PCParthenogenicPoison extends X2Effect_SpawnUnit;

var localized string ParthenogenicPoisonText;

var name ParthenogenicPoisonType;
var name ParthenogenicPoisonCocoonSpawnedName;
var name AltUnitToSpawnName;

var private name DiedWithParthenogenicPoisonTriggerName;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameStateHistory History;
	local XComHumanPawn HumanPawn;

	History = `XCOMHISTORY;

	TargetUnit = XComGameState_Unit(kNewTargetState);
	`assert(TargetUnit != none);

	HumanPawn = XComHumanPawn(XGUnit(History.GetVisualizer(TargetUnit.ObjectID)).GetPawn());
	if( HumanPawn != None )
	{
		UnitToSpawnName = AltUnitToSpawnName;
	}

	if (TargetUnit != none && !TargetUnit.IsAlive())
	{
		// The target died from the ability attaching this effect
		// The cocoon spawn should happen now
		super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
	}
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;

	`log("AddX2ActionsForVisualization triggered!",, 'X2Effect_PCParthenogenicPoison');
	
	if (EffectApplyResult == 'AA_Success' && ActionMetadata.StateObject_NewState.IsA('XComGameState_Unit'))
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, ParthenogenicPoisonText, '', eColor_Bad);
	}
}

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication, XComGameState_Player Player)
{
	local XComGameState_Unit PoisonedUnit;
	local bool bContinueTicking;
	local X2Effect_PCParthenogenicPoison PoisonTemplate;

	bContinueTicking = super.OnEffectTicked(ApplyEffectParameters, kNewEffectState, NewGameState, FirstApplication, Player);

	PoisonTemplate = X2Effect_PCParthenogenicPoison(kNewEffectState.GetX2Effect());
	if( (PoisonTemplate != none) && !PoisonTemplate.bInfiniteDuration && (kNewEffectState.iTurnsRemaining <= 0) )
	{
		// If the effect is not infinite and there are no more turns remaining, check to see if the poisoned unit has died
		PoisonedUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
		if( PoisonedUnit == none )
		{
			PoisonedUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
		}

		if( (PoisonedUnit != none) && PoisonedUnit.IsDead() )
		{
			// If the unit dies on a tick, trigger the spawn
			super.OnEffectAdded(ApplyEffectParameters, PoisonedUnit, NewGameState, kNewEffectState);
		}
	}

	return bContinueTicking;
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
}

simulated function SetPoisonDamageDamage()
{
	local X2Effect_ApplyWeaponDamage PoisonDamage;

	PoisonDamage = GetPoisonDamage();
	PoisonDamage.EffectDamageValue = class'X2Item_DefaultWeapons'.default.Chryssalid_ParthenogenicPoison_BaseDamage;
}

simulated function X2Effect_ApplyWeaponDamage GetPoisonDamage()
{
	return X2Effect_ApplyWeaponDamage(ApplyOnTick[0]);
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit EffectTargetUnit;
	local XComGameStateHistory History;
	local Object EffectObj;
	local XComGameState_Effect_PCPoison EffectState;

	super.RegisterForEvents(EffectGameState);

	EffectState = XComGameState_Effect_PCPoison(EffectGameState);

	`log("EffectGameState class name: " @ EffectGameState.Class.Name,, 'X2Effect_PCParthenogenicPoison');

	History = `XCOMHISTORY;
	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	EffectTargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	// Register for the required events
	EventMgr.RegisterForEvent(EffectObj, DiedWithParthenogenicPoisonTriggerName, EffectState.OnUnitDiedWithPCParthenogenicPoison, ELD_OnStateSubmitted,, EffectTargetUnit);
}


function ETeam GetTeam(const out EffectAppliedData ApplyEffectParameters)
{
	// This doesn't work for units that come from the strategy layer
	// Setting this directly to XCom as PC_Chryssalid is meant for having a playable Chryssalid...
	// If for some reason you want to make this more robust for... reasons... you do you
	// "you can probably use the index from `XCOMHISTORY.HistoryStartIndex since that should be updated to the latest tactical game start state"
	// Details: https://www.reddit.com/r/xcom2mods/comments/4c7a79/changing_a_units_team_through_effect/
	//return GetSourceUnitsTeam(ApplyEffectParameters, true);
	return eTeam_XCom;
}

function OnSpawnComplete(const out EffectAppliedData ApplyEffectParameters, StateObjectReference NewUnitRef, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit DeadUnitGameState, NewUnitGameState;
	local X2EventManager EventManager;
	//local XComUnitPawn PawnVisualizer;

	EventManager = `XEVENTMGR;

	DeadUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	if( DeadUnitGameState == none)
	{
		DeadUnitGameState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	}
	`assert(DeadUnitGameState != none);

	`LOG("NewUnitRef.ObjectID: " @ NewUnitRef.ObjectID,, 'X2Effect_PCParthenogenicPoison');
	`LOG("NewGameState: " @ NewGameState,, 'X2Effect_PCParthenogenicPoison');
	`LOG("NewGameState.GetGameStateForObjectID: " @ NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID),, 'X2Effect_PCParthenogenicPoison');

	NewUnitGameState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(NewUnitRef.ObjectID));
	`assert(NewUnitGameState != none);

	// The Dead unit's Loot is lost
	DeadUnitGameState.bBodyRecovered = false;

	DeadUnitGameState.RemoveUnitFromPlay();

	// Record the DeadUnitGameState's ID so the cocoon knows who spawned it
	NewUnitGameState.m_SpawnedCocoonRef = DeadUnitGameState.GetReference();

	// This prevents the new cocoon from ragdolling in the future? Do I need this here?
	//PawnVisualizer = XGUnit(NewUnitGameState.GetVisualizer()).GetPawn();
	//PawnVisualizer.RagdollFlag = eRagdoll_Never;

	// Remove the dead unit from play
	EventManager.TriggerEvent('UnitRemovedFromPlay', DeadUnitGameState, DeadUnitGameState, NewGameState);

	EventManager.TriggerEvent(default.ParthenogenicPoisonCocoonSpawnedName, NewUnitGameState, NewUnitGameState);
}

simulated function X2Action AddX2ActionsForVisualization_Death(out VisualizationActionMetadata ActionMetadata, XComGameStateContext Context)
{
	local X2Action AddAction;

	`log("AddX2ActionsForVisualization_Death triggered!",, 'X2Effect_PCParthenogenicPoison');

	AddAction = class'X2Action'.static.CreateVisualizationActionClass( class'X2Action_DeathWithParthenogenicPoison', Context, ActionMetadata.VisualizeActor );
	class'X2Action'.static.AddActionToVisualizationTree(AddAction, ActionMetadata, Context, false, ActionMetadata.LastActionAdded);

	return AddAction;
}

function TriggerSpawnEvent(const out EffectAppliedData ApplyEffectParameters, XComGameState_Unit EffectTargetUnit, XComGameState NewGameState, XComGameState_Effect EffectGameState)
{
	`log("TriggerSpawnEvent outer triggered!",, 'X2Effect_PCParthenogenicPoison');

	if( !EffectTargetUnit.IsChosen() )
	{
		`log("TriggerSpawnEvent inner chosen triggered!",, 'X2Effect_PCParthenogenicPoison');
		super.TriggerSpawnEvent(ApplyEffectParameters, EffectTargetUnit, NewGameState, EffectGameState);
	}
}

function bool DoesEffectAllowUnitToBleedOut(XComGameState_Unit UnitState) {return false; }
function bool DoesEffectAllowUnitToBeLooted(XComGameState NewGameState, XComGameState_Unit UnitState) {return false; }

defaultproperties
{
	EffectName="ParthenogenicPoisonEffect"
	UnitToSpawnName="PC_ChryssalidCocoon"
	AltUnitToSpawnName="PC_ChryssalidCocoonHuman"
	bClearTileBlockedByTargetUnitFlag=true
	bCopyTargetAppearance=true

	GameStateEffectClass = class'XComGameState_Effect_PCPoison'
	ParthenogenicPoisonType="ParthenogenicPoison"
	ParthenogenicPoisonCocoonSpawnedName="ParthenogenicPoisonCocoonSpawned"

	DiedWithParthenogenicPoisonTriggerName="UnitDied"

	Begin Object Class=X2Effect_ApplyWeaponDamage Name=PoisonDamage
		bAllowFreeKill=false
		bIgnoreArmor=true
		DamageTypes.Add("ParthenogenicPoison")
	End Object

	ApplyOnTick.Add(PoisonDamage)

	DamageTypes.Add("ParthenogenicPoison");
}