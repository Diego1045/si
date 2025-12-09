local StaminaBar = {}
StaminaBar.__index = StaminaBar

local TweenService : TweenService = game:GetService("TweenService")

function StaminaBar.Init(Character : Model) : Initialize
	local Bar = script.Parent.Parent.Stamina
	local ScaleBar = Bar.Frame.Bar
	local Frame = Bar.Frame
	-- Posibles bordes (marcos) dibujados con UIStroke
	local FrameStroke = Frame and Frame:FindFirstChildOfClass("UIStroke") or nil
	local BarStroke = ScaleBar and ScaleBar:FindFirstChildOfClass("UIStroke") or nil
	local MaxOutput = 100
	local Count = Character:GetAttribute("stamina") or 0
	
	-- Asegurar que la barra esté anclada al jugador (no a la pelota ni a otros objetos)
	local rootPart = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
	if Bar and Bar:IsA("BillboardGui") then
		-- Reparentar al Character si fuese necesario
		if Bar.Parent ~= Character then
			Bar.Parent = Character
		end
		-- Fijar el Adornee al jugador
		Bar.Adornee = rootPart
		Bar.AlwaysOnTop = true
		-- Offset vertical para que quede por encima del jugador
		Bar.StudsOffset = Vector3.new(-1, 1, 0)
		-- Distancia de render suficientemente alta
		Bar.MaxDistance = 1000
	end
	
	
	local OriginalGradient = ScaleBar.UIGradient.Color :: UIGradient

	-- Ocultar por defecto; se mostrará al correr o cuando la barra no esté llena
	Bar.Enabled = true
	
	-- Estado de visibilidad y duración de fade
	local isVisible = false
	local fadeDuration = 0.25
	
	-- Forzar transparencia inicial (oculta)
	if Frame then 
		Frame.BackgroundTransparency = 1 
		if FrameStroke then FrameStroke.Transparency = 1 end
	end
	if ScaleBar then 
		ScaleBar.BackgroundTransparency = 1 
		if BarStroke then BarStroke.Transparency = 1 end
	end

	ScaleBar.AnchorPoint = Vector2.new(0, 1)
	ScaleBar.Position = UDim2.new(0, 0, 1, 0)


	local function UpdateBar()
		Count = Character:GetAttribute("stamina") or 0
		local state = Character:GetAttribute("state") or "neutral"
		local isRunning = (state == "running")

		-- Mostrar solo cuando el jugador corre o cuando la estamina no está al máximo
		local shouldShow = isRunning or (Count < MaxOutput)
		
		-- Fade in/out suave
		if shouldShow and not isVisible then
			isVisible = true
			Bar.Enabled = true
			if Frame then
				TweenService:Create(Frame, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
				if FrameStroke then
					TweenService:Create(FrameStroke, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {Transparency = 0}):Play()
				end
			end
			if ScaleBar then
				TweenService:Create(ScaleBar, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
				if BarStroke then
					TweenService:Create(BarStroke, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {Transparency = 0}):Play()
				end
			end
		elseif not shouldShow and isVisible then
			isVisible = false
			local tween1, tween2
			if Frame then
				tween1 = TweenService:Create(Frame, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
				tween1:Play()
				if FrameStroke then
					TweenService:Create(FrameStroke, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
				end
			end
			if ScaleBar then
				tween2 = TweenService:Create(ScaleBar, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
				if BarStroke then
					TweenService:Create(BarStroke, TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
				end
				tween2.Completed:Once(function()
					-- Desactivar el BillboardGui al finalizar el fade-out
					Bar.Enabled = false
				end)
				tween2:Play()
			else
				-- Si no existe ScaleBar, asegurar desactivar tras el tween del Frame
				if tween1 then
					tween1.Completed:Once(function()
						Bar.Enabled = false
					end)
				else
					Bar.Enabled = false
				end
			end
		end

		local fillRatio = math.clamp(Count / MaxOutput, 0, 1)
		local Goal = {}
		Goal.Size = UDim2.new(1, 0, fillRatio, 0)

		local Tween = TweenService:Create(
			ScaleBar,
			TweenInfo.new(.2, Enum.EasingStyle.Quint),
			Goal
		) :: Tween
		Tween:Play()
		
		
		-- Cambiar color de la barra
		if Count <= 30 then
			ScaleBar.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(255, 0, 0)) --> Red
		elseif Count <= 55 then
			ScaleBar.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(255, 255, 0)) --> Yellow
		else
			ScaleBar.UIGradient.Color = OriginalGradient
		end
	end

	-- Escuchar cambios en stamina y state
	Character:GetAttributeChangedSignal("stamina"):Connect(UpdateBar)
	Character:GetAttributeChangedSignal("state"):Connect(UpdateBar)
	UpdateBar()
end

return table.freeze(StaminaBar)
