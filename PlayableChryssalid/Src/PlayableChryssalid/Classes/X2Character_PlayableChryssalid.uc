class X2Character_PlayableChryssalid extends X2Character config(GameData_CharacterStats);

static function array<X2DataTemplate> CreateTemplates() {
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTemplate_PlayableChryssalid());

	return Templates;
}

// **************************************************************************
// *** XCom Templates ***
// **************************************************************************

static function X2CharacterTemplate CreateTemplate_PlayableChryssalid()
{
	local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, 'PC_Chryssalid');
	CharTemplate.CharacterGroupName = 'Chryssalid';
	CharTemplate.DefaultLoadout='PC_Chryssalid_Loadout';
	CharTemplate.RequiredLoadout='PC_Chryssalid_Loadout';
	CharTemplate.DefaultSoldierClass = 'PC_Chryssalid_Class';
	CharTemplate.BehaviorClass=class'XGAIBehavior';
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_Chryssalid.ARC_GameUnit_Chryssalid");
	CharTemplate.strMatineePackages.AddItem("CIN_Chryssalid");
	CharTemplate.bUsePoolSoldiers = true;

	CharTemplate.UnitSize = 1;
	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = false;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = true;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = false;    
	CharTemplate.bCanTakeCover = false;

	// used for targetting
	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsSoldier = true;

	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsMeleeOnly = true;

	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = true;

	CharTemplate.strScamperBT = "ChryssalidScamperRoot";

	CharTemplate.Abilities.AddItem('ChryssalidImmunities');
	//CharTemplate.Abilities.AddItem('ChyssalidPoison');
	//CharTemplate.Abilities.AddItem('ChryssalidSlash');
	CharTemplate.Abilities.AddItem('ChryssalidBurrow');
	CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('HunkerDown');

	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_Alien;

	return CharTemplate;
}
