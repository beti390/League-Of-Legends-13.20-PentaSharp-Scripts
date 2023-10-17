local ffi = require "ffi"
local C = ffi.load("free_orbwalker")

ffi.cdef([[
typedef enum {
    OrbwalkingMode_None = 0,
    OrbwalkingMode_Combat,
    OrbwalkingMode_LastHit,
    OrbwalkingMode_Clear
} OrbwalkingMode_;

typedef enum {
    OrbwalkerTargetingMode_HealthAbsolute = 0,
    OrbwalkerTargetingMode_HealthPercent,
    OrbwalkerTargetingMode_EffectiveHealthMagical,
    OrbwalkerTargetingMode_EffectiveHealthPhysical
} OrbwalkerTargetingMode_;
    
typedef int OrbwalkingMode;
typedef int OrbwalkerTargetingMode;

typedef struct Orbwalker Orbwalker;

Orbwalker* Orbwalker_init(ScriptEnv *env);

bool Orbwalker_can_move(Orbwalker * const me);
bool Orbwalker_can_attack(Orbwalker * const me);
bool Orbwalker_is_winding_up(Orbwalker * const me);
bool Orbwalker_is_tick_after_wind_up_time(Orbwalker * const me);
float Orbwalker_internal_attack_cooldown(Orbwalker * const me);
float Orbwalker_get_attack_range(Orbwalker * const me, AttackableUnit *target);
bool Orbwalker_is_in_attack_range(Orbwalker * const me, AttackableUnit *target);
bool Orbwalker_is_potential_target(Orbwalker * const me, AttackableUnit *target);

//functions returning information about the orbwalker
//not affected by the "set_next" functions
OrbwalkingMode Orbwalker_get_orbwalking_mode(Orbwalker * const me);
OrbwalkerTargetingMode Orbwalker_get_targeting_mode(Orbwalker * const me);
float3 Orbwalker_get_move_pos(Orbwalker * const me);
GameObject* Orbwalker_get_target(Orbwalker * const me);

//functions returning information about the orbwalker
//affected by the "set_next" functions
OrbwalkingMode Orbwalker_get_effective_orbwalking_mode(Orbwalker * const me);
OrbwalkerTargetingMode Orbwalker_get_effective_targeting_mode(Orbwalker * const me);
float3 Orbwalker_get_effective_move_pos(Orbwalker * const me);
GameObject* Orbwalker_get_effective_target(Orbwalker * const me);

//functions to alter orbwalking behaviour (only for the current tick)
bool Orbwalker_set_next_mode(Orbwalker * const me, OrbwalkingMode mode);
bool Orbwalker_set_next_targeting_mode(Orbwalker * const me, OrbwalkerTargetingMode mode);
bool Orbwalker_set_next_move_pos(Orbwalker * const me, float3 pos);
bool Orbwalker_set_next_target(Orbwalker * const me, GameObject *obj);
bool Orbwalker_set_next_allow_move(Orbwalker * const me, bool allow_move);
bool Orbwalker_set_next_allow_attack(Orbwalker * const me, bool allow_attack);

//combat mode specific functions
GameObject* Orbwalker_combat_get_target(Orbwalker * const me);
GameObject* Orbwalker_lasthit_get_target(Orbwalker * const me);
GameObject* Orbwalker_clear_get_target(Orbwalker * const me);
]])

local camel_case = function(api)
    local t = {}
    for i, v in pairs(api) do
        local j = i:sub(1,1):upper()..i:sub(2,#i)
        local k = j:find("_")
        while k do
            j = j:sub(1, k)..j:sub(k+1,k+1):upper()..j:sub(k+2, #j)
            k = j:find("_", k+1)
        end
        j = j:gsub("_", "")
        t[j] = v
    end
    for i, v in pairs(t) do
        api[i] = v
    end
end

local M = {}

M.can_move = C.Orbwalker_can_move
M.can_attack = C.Orbwalker_can_attack
M.is_winding_up = C.Orbwalker_is_winding_up
M.is_tick_after_wind_up_time = C.Orbwalker_is_tick_after_wind_up_time
M.internal_attack_cooldown = C.Orbwalker_internal_attack_cooldown
M.get_attack_range = function(self, target)
    target = target:TryAsAttackableUnit()
    return C.Orbwalker_get_attack_range(self, target)
end
M.is_in_attack_range = function(self, target)
    target = target:TryAsAttackableUnit()
    return C.Orbwalker_is_in_attack_range(self, target)
end
M.is_potential_target = function(self, target)
    target = target:TryAsAttackableUnit()
    return C.Orbwalker_is_potential_target(self, target)
end

M.get_orbwalking_mode = C.Orbwalker_get_orbwalking_mode
M.get_targeting_mode = C.Orbwalker_get_targeting_mode
M.get_move_pos = C.Orbwalker_get_move_pos
M.get_target = function(self)
    local target = C.Orbwalker_get_target(self)
    return target ~= nil and target:ToDerivedClass() or nil
end

M.get_effective_orbwalking_mode = C.Orbwalker_get_effective_orbwalking_mode
M.get_effective_targeting_mode = C.Orbwalker_get_effective_targeting_mode
M.get_effective_move_pos = C.Orbwalker_get_effective_move_pos
M.get_effective_target = function(self)
    local target = C.Orbwalker_get_effective_target(self)
    return target ~= nil and target:ToDerivedClass() or nil
end


M.set_next_mode = C.Orbwalker_set_next_mode
M.set_next_targeting_mode = C.Orbwalker_set_next_targeting_mode
M.set_next_move_pos = C.Orbwalker_set_next_move_pos
M.set_next_target = C.Orbwalker_set_next_target
M.set_next_allow_move = C.Orbwalker_set_next_allow_move
M.set_next_allow_attack = C.Orbwalker_set_next_allow_attack

M.combat_get_target = function(self)
    local target = C.Orbwalker_combat_get_target(self)
    return target ~= nil and target:ToDerivedClass() or nil
end
M.lasthit_get_target = function(self)
    local target = C.Orbwalker_lasthit_get_target(self)
    return target ~= nil and target:ToDerivedClass() or nil
end
M.clear_get_target = function(self)
    local target = C.Orbwalker_clear_get_target(self)
    return target ~= nil and target:ToDerivedClass() or nil
end

camel_case(M)

ffi.metatype("Orbwalker", {
    __index = function(self, i)
        if i == "lib" then
            return C
        end
        return M[i]
    end,
})

return C.Orbwalker_init(_SCRIPTENV)