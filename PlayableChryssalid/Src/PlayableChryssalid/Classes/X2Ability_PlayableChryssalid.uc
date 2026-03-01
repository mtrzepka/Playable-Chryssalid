class X2Ability_PlayableChryssalid extends X2Ability
	config(GameData_SoldierSkills);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreateSlashAbilityPC());

	return Templates;
}

static function X2AbilityTemplate CreateSlashAbilityPC(optional Name AbilityName = 'PC_ChryssalidSlash')
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee MeleeHitCalc;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2Effect_ApplyWeaponDamage PhysicalDamageEffect;
	local X2Effect_PCParthenogenicPoison ParthenogenicPoisonEffect;
	local X2AbilityTarget_MovingMelee MeleeTarget;
	local array<name> SkipExclusions;

	local X2Ability_Chryssalid ChryssalidAbilities;
	ChryssalidAbilities = new class'X2Ability_Chryssalid';

	`CREATE_X2ABILITY_TEMPLATE(Template, AbilityName);
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_chryssalid_slash";
	Template.Hostility = eHostility_Offensive;
	Template.AbilitySourceName = 'eAbilitySource_Standard';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	MeleeHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = MeleeHitCalc;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	
	// May slash if the unit is burning or disoriented
	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false; // Disable this to allow civilians to be attacked.
	UnitPropertyCondition.ExcludeSquadmates = true;		   // Don't attack other AI units.
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);
	
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	ParthenogenicPoisonEffect = new class'X2Effect_PCParthenogenicPoison';
	ParthenogenicPoisonEffect.UnitToSpawnName = 'PC_ChryssalidCocoon';
	ParthenogenicPoisonEffect.AltUnitToSpawnName = 'PC_ChryssalidCocoonHuman';
	ParthenogenicPoisonEffect.BuildPersistentEffect(ChryssalidAbilities.POISON_DURATION, true, false, false, eGameRule_PlayerTurnEnd);
	ParthenogenicPoisonEffect.SetDisplayInfo(ePerkBuff_Penalty, ChryssalidAbilities.ParthenogenicPoisonFriendlyName, ChryssalidAbilities.ParthenogenicPoisonFriendlyDesc, Template.IconImage, true);
	ParthenogenicPoisonEffect.DuplicateResponse = eDupe_Ignore;
	ParthenogenicPoisonEffect.SetPoisonDamageDamage();

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeRobotic = true;
	UnitPropertyCondition.ExcludeAlive = false;
	UnitPropertyCondition.ExcludeDead = false;
	UnitPropertyCondition.FailOnNonUnits = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	ParthenogenicPoisonEffect.TargetConditions.AddItem(UnitPropertyCondition);
	Template.AddTargetEffect(ParthenogenicPoisonEffect);

	PhysicalDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	PhysicalDamageEffect.EffectDamageValue = class'X2Item_DefaultWeapons'.default.CHRYSSALID_MELEEATTACK_BASEDAMAGE;
	PhysicalDamageEffect.EffectDamageValue.DamageType = 'Melee';
	Template.AddTargetEffect(PhysicalDamageEffect);

	MeleeTarget = new class'X2AbilityTarget_MovingMelee';
	MeleeTarget.MovementRangeAdjustment = 0;
	Template.AbilityTargetStyle = MeleeTarget;
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_PlayerInput');
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	Template.CustomFireAnim = 'FF_Melee';
	Template.bSkipMoveStop = true;
	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.CinescriptCameraType = "Chryssalid_PoisonousClaws";

	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}