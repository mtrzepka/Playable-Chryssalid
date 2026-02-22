//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_PlayableChryssalid.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_PlayableChryssalid extends X2DownloadableContentInfo config(Game);

exec function AddChryssalidSquaddie()
{
	local XComGameState_Unit NewSoldierState;
	local XComOnlineProfileSettings ProfileSettings;
	local X2CharacterTemplate CharTemplate;
	local X2CharacterTemplateManager    CharTemplateMgr;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Allies Unknown State Objects");

	XComHQ = XComGameState_HeadquartersXCom(class'XComGameStateHistory'.static.GetGameStateHistory().GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));


		//assert(NewGameState != none);
		ProfileSettings = `XPROFILESETTINGS;

		CharTemplateMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
		//Tuple = TupleMgr.GetRandomTuple();

		CharTemplate = CharTemplateMgr.FindCharacterTemplate('PC_Chryssalid');
		if(CharTemplate == none)
		{
			return; //if we don't get any valid templates, that means the user has yet to install any species mods
		}

		NewSoldierState = `CHARACTERPOOLMGR.CreateCharacter(NewGameState, ProfileSettings.Data.m_eCharPoolUsage, CharTemplate.DataName);
		if(!NewSoldierState.HasBackground())
			NewSoldierState.GenerateBackground();
		NewSoldierState.GiveRandomPersonality();
		NewSoldierState.ApplyInventoryLoadout(NewGameState);
		NewSoldierState.SetHQLocation(eSoldierLoc_Barracks);
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		XComHQ.AddToCrew(NewGameState, NewSoldierState);
		NewSoldierState.RankUpSoldier(NewGameState, 'PC_Chryssalid_Class');
		NewSoldierState.ApplySquaddieLoadout(NewGameState, XComHQ);
		NewSoldierState.ApplyBestGearLoadout(NewGameState);
		NewSoldierState.SetXPForRank(1);
		NewSoldierState.SetKillsForRank(0);

	if(NewGameState.GetNumGameStateObjects() > 0)
	{
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	else
	{
		`XCOMHistory.CleanupPendingGameState(NewGameState);
	}
}

static event OnLoadedSavedGame()
{
    AddTechGameStates();
}
static event OnLoadedSavedGameToStrategy()
{
    AddTechGameStates();
}

static function AddTechGameStates()
{
    local XComGameStateHistory History;
    local XComGameState NewGameState;
    local X2StrategyElementTemplateManager    StratMgr;

    //This adds the techs to games that installed the mod in the middle of a campaign.
    StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
    History = `XCOMHISTORY;    

    //Create a pending game state change
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding New Techs");

    //Find tech templates
    CheckForTech(StratMgr, NewGameState, 'PC_Chryssalid_Tech');
    
    if( NewGameState.GetNumGameStateObjects() > 0 )
    {
        //Commit the state change into the history.
        History.AddGameStateToHistory(NewGameState);
    }
    else
    {
        History.CleanupPendingGameState(NewGameState);
    }
}

static function CheckForTech(X2StrategyElementTemplateManager StratMgr, XComGameState NewGameState, name ResearchName)
{
    local X2TechTemplate TechTemplate;

    if ( !IsResearchInHistory(ResearchName) )
    {
        TechTemplate = X2TechTemplate(StratMgr.FindStrategyElementTemplate(ResearchName));
        if(TechTemplate != none)
        {
            NewGameState.CreateNewStateObject(class'XComGameState_Tech', TechTemplate);
        }
    }
}

static function bool IsResearchInHistory(name ResearchName)
{
    // Check if we've already injected the tech templates
    local XComGameState_Tech    TechState;
    
    foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
    {
        if ( TechState.GetMyTemplateName() == ResearchName )
        {
            return true;
        }
    }
    return false;
}

