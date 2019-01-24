invoker_quantum = class({})

require("AddonScripts/spells/R/invoker_reconstruction")

LinkLuaModifier( "invoker_quantum_passivebuff", "AddonScripts/spells/Q/invoker_quantum_passivebuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "invoker_quantum_autocast_buff", "AddonScripts/spells/Q/invoker_quantum_autocast_buff", LUA_MODIFIER_MOTION_NONE )

local bFirstUpgrade = false
local bQuantumAutoCastMemory = false
local hQuantumAutoCastModifier

function invoker_quantum:OnSpellStart()
	QWERSystem_SphereClick(self, 1)
end

function invoker_quantum:OnUpgrade()
	local caster = self:GetCaster()
	QWERSystem_LevelUpdate(caster)
	caster:AddNewModifier(caster, self, "invoker_quantum_passivebuff", {})
	if bFirstUpgrade == false then
		bFirstUpgrade = true
		Timers:CreateTimer(0,
			function()
				if bQuantumAutoCastMemory ~= self:GetAutoCastState() then
					bQuantumAutoCastMemory = self:GetAutoCastState()
					if bQuantumAutoCastMemory then
						caster:AddNewModifier(caster, self, "invoker_quantum_autocast_buff", {})
					else
						caster:RemoveModifierByName("invoker_quantum_autocast_buff")
					end
				end
				return 0.1
			end
		)
	end
end