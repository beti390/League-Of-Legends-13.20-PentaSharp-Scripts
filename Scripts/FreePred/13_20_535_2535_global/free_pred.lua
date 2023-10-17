local ffi = require "ffi"
local C = ffi.load("free_pred")

ffi.cdef([[
typedef enum {
    CollisionFlags_None = 0,
    CollisionFlags_AlliedMinions = 1 << 1,
    CollisionFlags_EnemyMinions = 1 << 2,
    CollisionFlags_NeutralMinions = 1 << 3,
    CollisionFlags_AlliedLaneMinions = 1 << 4,
    CollisionFlags_EnemyLaneMinions = 1 << 5,
    CollisionFlags_EnemyHeroes = 1 << 6,
    CollisionFlags_AlliedHeroes = 1 << 7,
} CollisionFlags_;

typedef int CollisionFlags;

typedef struct {
    float effect_radius;
    float cast_time;
    bool add_target_bbox;
    float target_range;
} PredInputCirclePrompt;

typedef struct {
    float effect_radius;
    float cast_time;
    float speed;
    bool add_target_bbox;
    float target_range;
} PredInputCircle;

typedef struct {
    float width;
    float cast_time;
    bool add_target_bbox;
    float target_range;
} PredInputLinePrompt;

typedef struct {
    float width;
    float cast_time;
    float speed;
    bool add_target_bbox;
    float target_range;
} PredInputLine;

typedef struct {
    float3 pos;
    float3 source_pos;
    bool is_in_target_range;
} PredResult;

typedef struct {
    bool target_just_changed_path;
    bool is_higher_hitchance;
    float time_to_hit;
    float distance;
} PredEval;

typedef struct Pred Pred;

Pred* Pred_init(ScriptEnv *env);
void Pred_enable_debug(Pred * const me);
void Pred_disable_debug(Pred * const me);
float3 Pred_pos_after_time(Pred * const me, AIClient *source, float time);
void Pred_circle_prompt_src3d(Pred * const me, PredInputCirclePrompt *input, AIClient *target, PredResult *res, const float3 source);
void Pred_circle_prompt_src2d(Pred * const me, PredInputCirclePrompt *input, AIClient *target, PredResult *res, const float2 source);
void Pred_circle_prompt_src(Pred * const me, PredInputCirclePrompt *input, AIClient *target, PredResult *res, AIClient *source);
void Pred_circle_prompt(Pred * const me, PredInputCirclePrompt *input, AIClient *target, PredResult *res);
void Pred_circle_src3d(Pred * const me, PredInputCircle *input, AIClient *target, PredResult *res, const float3 source);
void Pred_circle_src2d(Pred * const me, PredInputCircle *input, AIClient *target, PredResult *res, const float2 source);
void Pred_circle_src(Pred * const me, PredInputCircle *input, AIClient *target, PredResult *res, AIClient *source);
void Pred_circle(Pred * const me, PredInputCircle *input, AIClient *target, PredResult *res);
void Pred_line_prompt_src3d(Pred * const me, PredInputLinePrompt *input, AIClient *target, PredResult *res, const float3 source);
void Pred_line_prompt_src2d(Pred * const me, PredInputLinePrompt *input, AIClient *target, PredResult *res, const float2 source);
void Pred_line_prompt_src(Pred * const me, PredInputLinePrompt *input, AIClient *target, PredResult *res, AIClient *source);
void Pred_line_prompt(Pred * const me, PredInputLinePrompt *input, AIClient *target, PredResult *res);
void Pred_line_src3d(Pred * const me, PredInputLine *input, AIClient *target, PredResult *res, const float3 source);
void Pred_line_src2d(Pred * const me, PredInputLine *input, AIClient *target, PredResult *res, const float2 source);
void Pred_line_src(Pred * const me, PredInputLine *input, AIClient *target, PredResult *res, AIClient *source);
void Pred_line(Pred * const me, PredInputLine *input, AIClient *target, PredResult *res);
bool Pred_collision(Pred * const me, PredInputLine *input, PredResult *res, AIClient *target, CollisionFlags flags);
void Pred_eval_circle_prompt(Pred * const me, PredInputCirclePrompt *input, PredResult *res, AIClient *target, PredEval *eval);
void Pred_eval_circle(Pred * const me, PredInputCircle *input, PredResult *res, AIClient *target, PredEval *eval);
void Pred_eval_line_prompt(Pred * const me, PredInputLinePrompt *input, PredResult *res, AIClient *target, PredEval *eval);
void Pred_eval_line(Pred * const me, PredInputLine *input, PredResult *res, AIClient *target, PredEval *eval);
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
M.PredInputCirclePrompt = ffi.typeof("PredInputCirclePrompt")
M.PredInputCircle = ffi.typeof("PredInputCircle")
M.PredInputLinePrompt = ffi.typeof("PredInputLinePrompt")
M.PredInputLine = ffi.typeof("PredInputLine")
M.PredResult = ffi.typeof("PredResult")
M.PredEval = ffi.typeof("PredEval")

M.enable_debug = C.Pred_enable_debug
M.disable_debug = C.Pred_disable_debug
M.pos_after_time = function(self, source, time)
    source = source:TryAsAiClient(source)
    assert(source, "arg 'source' is not of type AIClient")
    return C.Pred_pos_after_time(self, source, time)
end
M.circle_prompt_src3d = C.Pred_circle_prompt_src3d
M.circle_prompt_src2d = C.Pred_circle_prompt_src2d
M.circle_prompt_src = C.Pred_circle_prompt_src
M.circle_prompt = function(self, input, target, res)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_circle_prompt(self, input, target, res)
end
M.circle_src3d = C.Pred_circle_src3d
M.circle_src2d = C.Pred_circle_src2d
M.circle_src = C.Pred_circle_src
M.circle = function(self, input, target, res)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_circle(self, input, target, res)
end
M.line_prompt_src3d = C.Pred_line_prompt_src3d
M.line_prompt_src2d = C.Pred_line_prompt_src2d
M.line_prompt_src = C.Pred_line_prompt_src
M.line_prompt = function(self, input, target, res)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_line_prompt(self, input, target, res)
end
M.line_src3d = C.Pred_line_src3d
M.line_src2d = C.Pred_line_src2d
M.line_src = C.Pred_line_src
M.line = function(self, input, target, res)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_line(self, input, target, res)
end
M.collision = function(self, input, res, target, flags)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_collision(self, input, res, target, flags)
end
M.eval_circle_prompt = function(self, input, res, target, eval)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_eval_circle_prompt(self, input, res, target, eval)
end
M.eval_circle = function(self, input, res, target, eval)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_eval_circle(self, input, res, target, eval)
end
M.eval_line_prompt = function(self, input, res, target, eval)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_eval_line_prompt(self, input, res, target, eval)
end
M.eval_line = function(self, input, res, target, eval)
    target = target:TryAsAiClient(target)
    assert(target, "arg 'target' is not of type AIClient")
    return C.Pred_eval_line(self, input, res, target, eval)
end

camel_case(M)

ffi.metatype("Pred", {
    __index = function(self, i)
        if i == "lib" then
            return C
        end
        return M[i]
    end,
})

return C.Pred_init(_SCRIPTENV)