local texture = "levels/textures/ds_fog1.tex"
local shader = "shaders/vfx_particle.ksh"

local colour_envelope_name = "edgefogcolourenvelope"
local scale_envelope_name = "edgefogscaleenvelope"

local assets =
{
	Asset( "IMAGE", texture ),
	Asset( "SHADER", shader ),
}

local max_scale = 10

local init = false
local function InitEnvelopes()
	EnvelopeManager:AddColourEnvelope(
		colour_envelope_name,
		{	{ 0,	{ 1, 1, 1, 0 } },
			{ 0.1,	{ 1, 1, 1, 1 } },
			{ 0.75,	{ 1, 1, 1, 1 } },
			{ 1,	{ 1, 1, 1, 0 } },
		} )

	EnvelopeManager:AddVector2Envelope(
		scale_envelope_name,
		{	{ 0,	{ 6, 6 } },
			{ 1,	{ max_scale, max_scale } },
		} )

	InitEnvelopes = nil
end

local max_num_particles = 100
local max_lifetime = 5
local ground_height = 0.4
local emitter_radius = 25

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst:AddTag("FX")
	inst.persists = false

    if InitEnvelopes ~= nil then
        InitEnvelopes()
    end

	local emitter = inst.entity:AddParticleEmitter() --添加粒子发射器
	emitter:SetRenderResources( texture, shader )
	emitter:SetMaxNumParticles( max_num_particles)
	emitter:SetMaxLifetime( max_lifetime )
	emitter:SetSpawnVectors( -1, 0, 1, 1, 0, 1 ) --( config.SV[1].x, config.SV[1].y, config.SV[1].z, config.SV[2].x, config.SV[2].y, config.SV[2].z)
	emitter:SetSortOrder( 3 )
	emitter:SetColourEnvelope( colour_envelope_name )
	emitter:SetScaleEnvelope( scale_envelope_name );
	emitter:SetRadius(emitter_radius)

	local tick_time = TheSim:GetTickTime()
	local desired_particles_per_second = 0

	local area_emitter = CreateCircleEmitter(40) --获取随机圆形坐标

	inst.num_particles_to_emit = 0
	inst.particles_per_tick = desired_particles_per_second * tick_time

	local emit_fn = function()
		--print("emit....")
		local vx, vy, vz = 0.01 * UnitRand(), 0, 0.01 * UnitRand()
		local lifetime = max_lifetime * ( 0.9 + UnitRand() * 0.1 )
		local px, pz

		local py = math.random(3,10)*0.1
		px, pz = area_emitter()

		emitter:AddParticle(
			lifetime,			-- lifetime
			px, py, pz,			-- position
			vx, vy, vz			-- velocity
		)
	end
	
	local updateFunc = function()
		while inst.num_particles_to_emit > 1 do
			emit_fn( emitter ) --生成粒子
			inst.num_particles_to_emit = inst.num_particles_to_emit - 1
		end

		inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
	end
	
	EmitterManager:AddEmitter( inst, nil, updateFunc ) --注册粒子发射器函数 形参：对象 生存周期 更新函数

    return inst
end

return Prefab("zdy_mist_of", fn, assets) --zdy_mist
 
