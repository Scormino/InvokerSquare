require('BarebonesLib/timers')
require('AddonScripts/SpellSystem')

local sNPC_DUMMY = 'npc_dummy'
local nDEG_TO_RAD = 1 / 57.2958

function CreateRocket(hData)
  local hRocket = class({})

  local function GetLaunchVec(vPos, vTarget, nVerticalAngle, nHorizontalAngle)
    nVerticalAngle = (nVerticalAngle or 20) * nDEG_TO_RAD
    --nHorizontalAngle = (nHorizontalAngle or 0) * DEG_TO_RAD
    
    local v2Pos = Vector(vPos.x, vPos.y, 0)
    local v2Target = Vector(vTarget.x, vTarget.y, 0)

    local v2Direction = (v2Target - v2Pos):Normalized()

    local nVerticalSIN = math.sin(nVerticalAngle)
    local x = v2Direction.x * nVerticalSIN
    local y = v2Direction.y * nVerticalSIN
    local z = v2Direction:Length2D() * nVerticalSIN
    return Vector(x, y, z)
  end
  function hRocket:Init(hData)
    self.eSource = hData.eSource
    self.eTarget = hData.eTarget
    
    --определение Attachment - привязок
    if hData.hAttachments then
      if self.eSource and hData.hAttachments.sAttachSource then
        local nAttachId = self.eSource:ScriptLookupAttachment(hData.hAttachments.sAttachSource)
        self.vPos = self.eSource:GetAttachmentOrigin(nAttachId)
      end
      if hData.eTarget and hData.hAttachments.sAttachTarget then
        local nAttachId = self.eTarget:ScriptLookupAttachment(hData.hAttachments.sAttachTarget)
        self.nAttachTarget = nAttachId
        self.vTarget = self.eTarget:GetAttachmentOrigin(nAttachId)
      end
    end

    --координаты цели и начальной позиции
    self.vPos = hData.vPos or self.vPos or (hData.eSource:GetAbsOrigin() + Vector(0,0,200))
    self.vTarget = hData.vTarget or self.vTarget or hData.eTarget:GetAbsOrigin()
  
    --параметры движения
    self.nMaxSpeed = hData.nMaxSpeed or 1000
    self.nSpeed = hData.nSpeed or hRocket.nMaxSpeed
    self.vSpeed = hData.vSpeed or (GetLaunchVec(self.vPos, self.vTarget, hData.nVerticalAngle, hData.nHorizontalAngle) * self.nSpeed)
    self.nAcceleration = hData.nAcceleration or 1          --Ускорение в долях от hInfo.nMaxSpeed [ед./с^2]
    self.nDistanceHit = hData.nDistanceHit or 50
    self.sEffectName = hData.sEffectName or 'particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf'
    self.nTimeStep = hData.nTimeStep or FrameTime() 
    self.nTeam = hData.nTeam or self.eSource:GetTeam() or 5

    self.nTimeSpawn = GameRules:GetGameTime()
    self.nTimeLife = hData.nTimeLife or 10.0 -- 0 - Бесконечно
    
    --Видимость
    self.bUseFOWViewer = hData.bUseFOWViewer or false
      self.nDurationVision = hData.nDurationVision or 2*self.nTimeStep
      self.bFlyingVision = hData.bFlyingVision or true
    self.bUseDummyVision = hData.bUseDummyVision or false
      if hData.bFreeDummy == nil then --удалять ли Dummy при вызове Free()
        self.bFreeDummy = true
      else
        self.bFreeDummy = hData.bFreeDummy
      end
    self.nVisionRadius = hData.nVisionRadius or 250
    

    --События
    self.OnFinish = hData.OnFinish or function() end
    self.OnHit = hData.OnHit or function() end
    self.OnGroundHit = hData.OnGroundHit or function() end
    self.OnTimeOver = hData.OnTimeOver or function() end
    self.OnTick = hData.OnTick or function() end

    --контрольные точки снаряда
    self.hCP = {
      bDynEffect = hData.bDynEffect or true,  --Является ли ракета - динамичным снарядом (имеет CP заточенные на перемещение)
      nPosCP = hData.nPosCP or 0,
      nTargetCP = hData.nTargetCP or 1,
      nVelCP = hData.nVelCP or 2
    }

    --Создание Particle
    self.id = ParticleManager:CreateParticle(self.sEffectName, PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(self.id, self.hCP.nPosCP, self.vPos)
    if self.hCP.bDynEffect then
      ParticleManager:SetParticleControl(self.id, self.hCP.nTargetCP, self.vPos + self.vSpeed)
      ParticleManager:SetParticleControl(self.id, self.hCP.nVelCP, Vector(self.nSpeed, 0, 0))
    end

    --создание Dummy Vision
    if self.bUseDummyVision then
      self.eDummy = CreateUnitByName(sNPC_DUMMY, self.vPos, false, self.eSource, self.eSource, self.nTeam)
      self.eDummy:SetDayTimeVisionRange(self.nVisionRadius)
      self.eDummy:SetNightTimeVisionRange(self.nVisionRadius)

      SpellSystem:ApplyBuff({eCaster = self.eDummy, sBuff = "dummy", hStats = {
            MODIFIER_STATE_NOT_ON_MINIMAP = hData.bMiniMapHideVision,
            MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES = hData.bMiniMapHideVisionEnemy
          }
        }
      )
    end

    Timers:CreateTimer(
      function()
        return self:ApplyRocketMovement()
      end
    )

    return self --Возвращаем hRocket
  end

  function hRocket:Free()
    self:OnFinish()
    ParticleManager:DestroyParticle(self.id, false)
    ParticleManager:ReleaseParticleIndex(self.id)
    if self.bFreeDummy and self.eDummy then
      --self.eDummy:RemoveSelf()
      self.eDummy:ForceKill(false)
      self.eDummy = nil
    end
  end

  function hRocket:vTargetRefresh()
    if self.eTarget then
      --Снаряд направленный на юнита
      self.vTarget = self.eTarget:GetAbsOrigin()
    end
  end

  function hRocket:ApplyForce() --Рассчитывает вектор скорости
    local vMaxSpeed = (self.vTarget - self.vPos):Normalized() * self.nMaxSpeed
    local vDSpeed = (vMaxSpeed - self.vSpeed) * self.nAcceleration
    self.vSpeed = self.vSpeed + vDSpeed
    self.nSpeed = self.vSpeed:Length()
    --[[
      local vAcceleration = (self.vTarget - self.vPos):Normalized() * self.nAccelerationProcent
      local vSpeedGain = vAcceleration * self.nTimeStep  --м/с
      self.vSpeed = self.vSpeed + vSpeedGain
      if self.vSpeed:Length() > self.nMaxSpeed then     --Обеспечиваем предел макс. скорости для текущ. снаряда
        self.vSpeed = self.vSpeed:Normalized() * self.nMaxSpeed
      end
    ]]
  end

  function hRocket:ApplyRocketMovement()
    self:vTargetRefresh()
    self:ApplyForce()
    local vCurrentSpeed = self.vSpeed * self.nTimeStep
    self.vPos = self.vPos + vCurrentSpeed

    if self.bUseFOWViewer then
      AddFOWViewer(self.nTeam, self.vPos, self.nVisionRadius, self.nDurationVision, self.bFlyingVision)
    end
    if self.eDummy then
      self.eDummy:SetAbsOrigin(self.vPos)
    end

    if self.vPos.z <= GetGroundHeight(Vector(self.vPos.x, self.vPos.y, 0), nil) then
      if not self:OnGroundHit() then
        self.vSpeed = Vector(0,0,1) * self.nSpeed
      else
        self:Free()
        return
      end
    end

    --Расстояние между целью и ракетой меньше условного предела
    if (self.vTarget - self.vPos):Length() < self.nDistanceHit then
      --Событие Достижения цели
      if not self:OnHit() then
        self:Free()
        return
      end
    end
    if self.nTimeLife ~= 0 and GameRules:GetGameTime() >= self.nTimeSpawn + self.nTimeLife then
      --Событие истечения времени
      if not self:OnTimeOver() then
        self:Free()
        return
      end
    end

    if self.hCP.bDynEffect then
      ParticleManager:SetParticleControl(self.id, self.hCP.nTargetCP, self.vPos)
      ParticleManager:SetParticleControl(self.id, self.hCP.nVelCP, Vector(self.nSpeed, 0, 0))
    else
      ParticleManager:SetParticleControl(self.id, self.hCP.nPosCP, self.vPos)
    end


    



    --local alpha = 1
    --local color = Vector(200,0,0)
    --DebugDrawSphere(hRocket.vPos, color, alpha, 100, true, hRocket.nTimeStep)

    self:OnTick()
    return self.nTimeStep
  end

  return hRocket:Init(hData)
end