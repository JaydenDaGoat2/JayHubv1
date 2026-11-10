--!nonstrict
-- Tween helper that follows the player's "Animations" setting. With
-- animations off every change is applied instantly.

local TweenService = game:GetService("TweenService")

local Store = require(script.Parent.Parent.Core.Store)

local Tween = {}

local DEFAULT_STYLE = Enum.EasingStyle.Quint
local DEFAULT_DIRECTION = Enum.EasingDirection.Out

function Tween.enabled(): boolean
	return Store.get("Animations") ~= false
end

function Tween.play(
	instance: Instance,
	props: { [string]: any },
	duration: number?,
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?
): Tween?
	-- Unparented instances (still being built, or destroyed) can't animate.
	if not Tween.enabled() or duration == 0 or instance.Parent == nil then
		for prop, value in props do
			(instance :: any)[prop] = value
		end
		return nil
	end

	local info = TweenInfo.new(duration or 0.22, style or DEFAULT_STYLE, direction or DEFAULT_DIRECTION)
	local ok, tween = pcall(TweenService.Create, TweenService, instance, info, props)
	if not ok then
		warn("[JayHub] tween failed:", tween)
		return nil
	end
	tween:Play()
	return tween
end

-- Plays a tween and runs `callback` once it finishes (or right away when
-- animations are off).
function Tween.playThen(
	instance: Instance,
	props: { [string]: any },
	duration: number?,
	callback: () -> (),
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?
)
	local tween = Tween.play(instance, props, duration, style, direction)
	if tween then
		tween.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed then
				callback()
			end
		end)
	else
		task.defer(callback)
	end
	return tween
end

return Tween
