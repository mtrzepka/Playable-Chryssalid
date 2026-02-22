class X2Tech_PlayableChryssalid extends X2StrategyElement config(XcomStrategyTuning);

var config int PCTech_PointToComplete;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	Techs.AddItem(CreatePC_Chryssalid_TechTemplate());
	
	return Techs;
}

static function X2DataTemplate CreatePC_Chryssalid_TechTemplate()
{

	local X2TechTemplate Template;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'PC_Chryssalid_Tech');
	Template.bProvingGround = true;
	Template.bRepeatable = true;
	Template.strImage = "img:///UILibrary_StrategyImages.ScienceIcons.IC_AutopsyChryssalid"; 
	Template.SortingTier = 1;
	Template.ResearchCompletedFn = ResearchCompleted;
	Template.PointsToComplete = default.PCTech_PointToComplete;
	Template.Requirements.RequiredTechs.AddItem('AutopsyChryssalid');
	return Template;
}

function ResearchCompleted(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);
	UnitState = CreateUnit(NewGameState);
	NewGameState.AddStateObject(UnitState);
	XComHQ.AddToCrew(NewGameState, UnitState);
	UnitState.SetHQLocation(eSoldierLoc_Barracks);
	XcomHQ.HandlePowerOrStaffingChange(NewGameState);
}


static function XComGameState_Unit CreateUnit(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit UnitState;
	local X2CharacterTemplateManager CharTemplateManager;
	local X2CharacterTemplate CharTemplate;
	//local XGCharacterGenerator CharGen;
	//local string strFirst, strLast;

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	CharTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	CharTemplate = CharTemplateManager.FindCharacterTemplate('PC_Chryssalid');
	UnitState = CharTemplate.CreateInstanceFromTemplate(NewGameState);
	

	//CharGen.GenerateName(0, 'Country_Spark', strFirst, strLast);
	UnitState.SetCharacterName("Chryssalid", "Spawn", "Skitter");
	UnitState.SetCountry('Country_Spark');
	NewGameState.AddStateObject(UnitState);
	UnitState.kAppearance.iGender = 1;
	UnitState.StoreAppearance();
	return UnitState;
}