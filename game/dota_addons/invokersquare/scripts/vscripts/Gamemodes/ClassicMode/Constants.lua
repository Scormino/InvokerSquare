require('AddonScripts/ModifierSync')



if ClassicConst == nil then
	local C = {}

	C.Const = {}

	C.Const.modifiers = {}
	C.Const.modifiers.speedlim = {
		nMovespeedMax	= 3000,
		nMovespeedMin	= 5,
		nIntervalThink	= 0.1,
	}  
  
	C.Const.HeroStats = {
		nDamage = {
			--factor 		= 	1,
			first	= 15, 
			gain	= 2,
		},
		nAttackTime = {
			first	= 1.50000, 
			gain	= -0.02,
		},
		nAttackAnimationTime = 	0.30000,
		nAttackRange = 600,
		nProjectileSpeed = 860,
		nHealth = {	-- перманентный + к базовому здоровью
			first	= 100, 
			gain	= 15,
		},
			nHealthRegen = {	--хп/сек.
				first	= 0.0,--0.1, 
				gain	= 0.0,--0.025,
			},
		nMana = {
			first	= 100, 
			gain	= 15,
		},
			nManaRegen = {
				first	= 0.1, 
				gain	= 0.025,
			},
		nMoveSpeed = {
			first	= 300, 
			gain	= 2,
		},
	}

	--Exp System
	C.Const.tower_knowledge_concentrator = {
		dt = FrameTime(),	--период срабатывания функции Exp-System'ы
		nGainExp = {
			[0] = 0,
			[1] = 4.0,
			[2] = 6.5,
		},
	}






	require('Gamemodes/ClassicMode/QWERSystem')

	local Q, W, E, R = sQ, sW, sE, sR

	--QUANTUM
	C.Const.quantum = {
		nSphereDuration = math.huge,
		nHealth = {
			factor 		= Q,
				first	= 15, 
				gain	= 15,
		},
		nAttackTime = {
			factor 		= Q,
				first	= 0.1, 
				gain	= 0.1,
		},
		nHealthRegen = {
			factor 		= Q,
				first 	= 2.25, 
				gain	= 2.5,
		},
		--[[
		nForseSwap = {
			--bArithmetictype = 	true,
			--nSphere 		= 	1,
			factor 		= Q,
				first 	=	0.025, 
				gain		=	0.0065,
		},
		]]
	}

	C.Const.warp = {
		nSphereDuration = math.huge,
		nManaRegen = {
			factor 		= W,
				first 	= 1.25, 
				gain	= 1.5,
		},
		nMana = {
			factor 		= W,
				first 	= 50, 
				gain	= 50,
		},
	}

	C.Const.expanse = {
		nSphereDuration = math.huge,
		nMoveSpeed = {
			factor 		= E,
				first 	= 10, 
				gain	= 15,
		},
		nVision = {
			factor 		= E,
				first 	= 30, 
				gain	= 40,
		},
		nAttackAnimationTime = {
			factor 		= E,
				first 	= 0.025, 
				gain	= 0.025, -- -0.03
		},
		nDamagePerSphere = {
			factor 		= E,
				first 	= 3, 
				gain	= 4,
		},
	}

	C.Const.reconstruction = {
		nAllowSpellsCount = {
			factor	= R,
			[1]		= 2,
			[2] 	= 3,
			[3] 	= 4,
			[4] 	= 5
		},
		nCooldown = 5,
		nCooldownBackpackSwapFactor = 0.25,
		nAltCooldown = 0
	}

	C.Const.invoker_fireBalls_hephaestus = {
		sFlameTextureName = 'jakiro_macropyre',
		sFireTextureName = 'huskar_burning_spear',

		nManaCost = 40,
		nCooldown = 0,
		nCastRange = math.huge,
		nCastPoint = {
			factor 		= E,
				first 	= 0.45, 
				gain	= -0.05,
		},

		nDamage = {
			factor 		= E,
				first 	= 20, 
				gain	= 15,
		},
		nStackDamageFactor = 0.01,
		nRadius = 200,
		nFireRange = 125,

		nMaxSpeed = 1400,
		nAcceleration = 0.2,
		nRocketVisionRange = 400,

		nBuffDuration = 4,
		nFireVisionRange = 450,
		bMiniMapHideVision = false,
		bMiniMapHideVisionEnemy = false,

		nAuraIntervalThink = {
			factor 		= W,
				first 	= 0.75, 
				gain	= -0.0725,
		},
		nAddStackPerThink = 1,
		nTimeLife = {
			factor 		= W,
				first 	= 2.5, 
				gain	= 0.5,
		},
		nHitStackCount = {	--Добавочное кол-во стаков при попадании
			factor 		= E,
				first 	= 5, 
				gain	= 1,
		},
		nMaxStacks = 999,
		nDamagePerStack = 1,
	}

	C.Const.invoker_forge_spirits = {
		nManaCost = 90,
		nCooldown = 28,
		nCastPoint = 0,
		nDuration = 50,

		nCountCreatures = {
			factor	= Q,
			[1]		= 1,
			[2]		= 1,
			[3] 	= 2,
			[4] 	= 2,
			[5] 	= 2,
			[6] 	= 2,
			[7] 	= 2,
			[8] 	= 2,
			[9] 	= 3,
			[10] 	= 3,
		},
		nHPMax = {
			factor		= Q,
				first	= 35, 
				gain	= 15,
		},
		nMPMax = 100,
		nArmorPhysical = {
			factor 		= E,
				first 	= 0, 
				gain	= 2,
		},
		nMagicResist = 0,
		nBaseDamage = {
			factor 		= E,
				first 	= 10, 
				gain	= 5,
		},
		nBaseAttackSpeedTime = {
			factor 		= Q,
				first 	= 1.2, 
				gain	= -0.1,
		},
		nAttackRange = 450,
	}
	C.Const.forge_spirits_life_giving_fire = {
		nRadius = 350,
		nHealthRegen = {
			factor 		= Q,
				first 	= 5, 
				gain	= 4,
		},
		nMagicResist = {
			factor 		= Q,
				first 	= 8, 
				gain	= 1.5,
		},
	}



    C.Const.invoker_alacrity_of_zecora = {
		sBuffTextureName = 'chaos_knight_chaos_strike',
		nManaCost = 55,
		nCooldown = {
			factor 		= W,
				first 	= 14, 
				gain	= -0.75,
		},
		nCastRange = {
			factor 		= E,
				first 	= 300, 
				gain	= 70,
		},
		nCastPoint = 0.075,
		nDuration = 8,
		nDamage = {
			factor 		= E,
				first 	= 35, 
				gain	= 20,
		},
		nInDamagePercent = {
			factor 		= W,
				first 	= 12, 
				gain	= 4,
		},
		nOutDamagePercent = {
			factor 		= W,
				first 	= 12, 
				gain	= 4,
		},
	}

    C.Const.invoker_spellsteal_rubiks = {
		nManaCost = 150,
		nCooldown = 15,
		nCastRange = {
			factor 		= W,
				first 	= 600, 
				gain	= 70,
		},
		nCastPoint = 0.3,
		nDuration = {
			factor 		= W,
				first 	= 13, 
				gain	= 3,
		},
	}


	Q, W, E = 1, 2, 3
	C.Const.sAbilName_hFormula = {
		invoker_fireBalls_hephaestus	= {E, W, 0},
		invoker_alacrity_of_zecora		= {W, E, 0},
		invoker_forge_spirits 			= {Q, E, 0},

		invoker_spellsteal_rubiks		= {W, Q, W},
	}  
	
	
	

  _G.ClassicConst = C
end






if Classic == nil then
  _G.Classic = class({})
end

function Classic:ApplyConstants(mode)
  mode = mode or self
  for k, v in pairs(ClassicConst) do
    mode[k] = v
	end
	local hSaveTable = Table2StringTable(ClassicConst.Const)
	CustomNetTables:SetTableValue("Hash", "hGameConst" , hSaveTable)
	require('AddonScripts/ConstUtils')
	SyncGameConst()
  return mode
end