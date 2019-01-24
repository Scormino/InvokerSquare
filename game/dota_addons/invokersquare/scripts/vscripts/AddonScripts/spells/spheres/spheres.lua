require('AddonScripts/SpellSystem') --для индексации модификаторов

hBuffSphereNames = {
  [1] = 'invoker_quantum_spherebuff',
  [2] = 'invoker_warp_spherebuff',
  [3] = 'invoker_expanse_spherebuff'
}

LinkLuaModifier( hBuffSphereNames[1], "AddonScripts/spells/spheres/Q/" .. hBuffSphereNames[1],  LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( hBuffSphereNames[2], "AddonScripts/spells/spheres/W/" .. hBuffSphereNames[2],  LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( hBuffSphereNames[3], "AddonScripts/spells/spheres/E/" .. hBuffSphereNames[3],  LUA_MODIFIER_MOTION_NONE)


function StartRandomCastAnimation(eCaster)
	local RandInt = RandomInt(1, 2)
	local a = ACT_DOTA_OVERRIDE_ABILITY_1
	if RandInt == 2 then
		a = ACT_DOTA_OVERRIDE_ABILITY_2
	end
    StartAnimation(eCaster, {
        duration=5.0, 
        activity=a
      }
    )
	return RandInt
end


function GethSpheres(eCaster)
  local hSpheres = {}
  local nSphereType
  for nSphereType = 1, #hBuffSphereNames do
    local hSpheresForThisType = eCaster:FindAllModifiersByName(hBuffSphereNames[nSphereType])
    for _, eSphere in ipairs(hSpheresForThisType) do
      hSpheres[eSphere.nSphereIndex] = eSphere
    end
  end

  return hSpheres --nSphereIndex_eSphere
end



function ApplyBuffSphere(eCaster, nSphereType, nAnim)
  eCaster.nCurrentSphereIndex = eCaster.nCurrentSphereIndex or 1
  
  local eOldSphereBuff = GethSpheres(eCaster)[eCaster.nCurrentSphereIndex]
  if eOldSphereBuff then
    eCaster:RemoveModifierByName(hBuffSphereNames[eOldSphereBuff.nSphereType])
  end

  SpellSystem:ApplyBuff({
      eCaster = eCaster,
      sBuff = hBuffSphereNames[nSphereType],
      hStats = {
        nSphereIndex = eCaster.nCurrentSphereIndex,
        nAnim=nAnim,
      }  
    }
  )
  --eCaster:AddNewModifier(eCaster, nil, hBuffSphereNames[nSphereType], hOnCreatedDATA)
  eCaster.nCurrentSphereIndex = eCaster.nCurrentSphereIndex + 1
  if eCaster.nCurrentSphereIndex > #hBuffSphereNames then 
    eCaster.nCurrentSphereIndex = 1 
  end
end

function RemoveAllSpheres(eCaster)
  local nSphereIndex_eSphere = GethSpheres(eCaster)
  for nSphereIndex, eSphere in ipairs(nSphereIndex_eSphere) do
    eCaster:RemoveModifierByName(hBuffSphereNames[eSphere.nSphereType])
  end
  eCaster.nCurrentSphereIndex = nil
end

function CreateShpereParticle(eBuff, nSphereType, nUseSlot, nAnim)
  if IsClient() then return end
	nAnim = nAnim or 1
	local hPartPath = {}	--пути к .vpcf сфер invoker'а
	hPartPath[1] = "particles/invoker/quantum/invoker_quantum_orb.vpcf"
  hPartPath[2] = "particles/invoker/warp/invoker_warp_orb.vpcf"
	hPartPath[3] = "particles/invoker/expanse/invoker_expanse_orb.vpcf"
	local eCaster = eBuff:GetCaster()

	eBuff.nSphereParticle = ParticleManager:CreateParticle(
		hPartPath[nSphereType],
		PATTACH_POINT_FOLLOW, eCaster)
	ParticleManager:SetParticleControlEnt(eBuff.nSphereParticle, 0, eCaster, PATTACH_POINT_FOLLOW, "attach_attack"..nAnim, eCaster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(eBuff.nSphereParticle, 1, eCaster, PATTACH_POINT_FOLLOW, "attach_orb"..nUseSlot, eCaster:GetAbsOrigin(), false)
end

function RemoveSphereParticle(eBuff)
  if eBuff.nSphereParticle ~= nil then
    ParticleManager:DestroyParticle(eBuff.nSphereParticle, false)
    ParticleManager:ReleaseParticleIndex(eBuff.nSphereParticle)
		eBuff.nSphereParticle = nil
  end
end