#ifndef ORBWALKER_H
#define ORBWALKER_H

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

#endif