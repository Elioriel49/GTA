local banks = {
	["fleeca"] = {
		position = { ['x'] = 147.04908752441, ['y'] = -1044.9448242188, ['z'] = 29.36802482605 },
		reward = 125000,
		prettyName = "Fleeca Bank (Legion Square)",
		lastRob = 0
	},
	["fleeca2"] = {
		position = { ['x'] = -2957.6674804688, ['y'] = 481.45776367188, ['z'] = 15.697026252747 },
		reward = 125000,
		prettyName = "Fleeca Bank (Great Ocean Highway)",
		lastRob = 0
	},
	["blainecounty"] = {
		position = { ['x'] = -107.06505584717, ['y'] = 6474.8012695313, ['z'] = 31.62670135498 },
		reward = 250000,
		prettyName = "Blaine County Savings (Paleto Bay)",
		lastRob = 0
	}
}

local curRobbers = {}

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('es_robberies:walkedOff')
AddEventHandler('es_robberies:walkedOff', function(rob)
	if(curRobbers[source])then
		TriggerClientEvent('es_robberies:robberyCancelled', source)
		curRobbers[source] = nil

		TriggerEvent('es:getPlayers', function(pl)
			for k,v in pairs(pl) do
				TriggerEvent('es_roleplay:getPlayerJob', k, function(job)
					if(job)then
						if(job.job == "police")then
							TriggerClientEvent('chatMessage', k, 'BRAQUAGE', {255, 0, 0}, "Braquage annulé à: ^2" .. banks[rob].prettyName)
						end
					end
				end)
			end
		end)
	end
end)

AddEventHandler("es_roleplay:playerCuffed", function(player, cuffed)
	if(curRobbers[player])then
		if(cuffed)then
			TriggerClientEvent('es_robberies:robberyStoreCancelled', player)
			curRobbers[player] = nil

			TriggerEvent('es:getPlayers', function(pl)
				for k,v in pairs(pl) do
					TriggerEvent('es_roleplay:getPlayerJob', k, function(job)
						if(job)then
							if(job.job == "police")then
								TriggerClientEvent('chatMessage', k, 'BRAQUAGE', {255, 0, 0}, "Les braqueurs ont été mis en garde à vue à: ^2" .. banks[rob].prettyName)
							end
						end
					end)
				end
			end)
		end
	end
end)

RegisterServerEvent('es_robberies:robBank')
AddEventHandler('es_robberies:robBank', function(rob)
	if banks[rob] then
		local bank = banks[rob]

		if (os.time() - bank.lastRob) < 1200 and bank.lastRob ~= 0 then
			TriggerClientEvent('chatMessage', source, 'BRAQUAGE', {255, 0, 0}, "Déjà été braqué récemment, reviens dans: ^2" .. (1200 - (os.time() - bank.lastRob)) .. "^0 secondes.")
			return
		end

		TriggerEvent('es:getPlayerFromId', source, function(user)
			TriggerEvent('es_roleplay:getPlayerJob', source, function(job)
				if(job) then
					TriggerClientEvent('chatMessage', source, 'BRAQUAGE', {255, 0, 0}, "Tu ne peux pas braquer en tant que ^2" .. job.job)
				else
					if get3DDistance(user.coords.x, user.coords.y, user.coords.z, bank.position.x, bank.position.y, bank.position.z) < 4.5 then
						local cops = 0
						TriggerEvent('es:getPlayers', function(pl)
							for k,v in pairs(pl) do
								TriggerEvent('es_roleplay:getPlayerJob', k, function(job)
									if(job)then
										if(job.job == "police")then
											cops = cops + 1
										end
									end
								end)
							end
						end)

						if(cops < 1)then

							TriggerEvent('es:getPlayers', function(pl)
								for k,v in pairs(pl) do
									TriggerEvent('es_roleplay:getPlayerJob', k, function(job)
										if(job)then
											if(job.job == "police")then
												TriggerClientEvent('chatMessage', k, 'BRAQUAGE', {255, 0, 0}, "Braquage en cours à ^2" .. bank.prettyName)
											end
										end
									end)
								end
							end)

							TriggerClientEvent('chatMessage', source, 'BRAQUAGE', {255, 0, 0}, "Tu commences à braquer: ^2^*" .. bank.prettyName .. "^0^r, ne t'éloignes pas de ce point!")
							TriggerClientEvent('es_robberies:robbingBank', source, rob)
							banks[rob].lastRob = os.time()
							curRobbers[source] = true

							SetTimeout(600000, function()
								if(curRobbers[source])then
									TriggerClientEvent('es_robberies:robbingBankDone', source, job)
									TriggerEvent('es:getPlayerFromId', source, function(target) 
										target:addMoney(bank.reward)
									end)

									TriggerEvent('es:getPlayers', function(pl)
										for k,v in pairs(pl) do
											TriggerEvent('es_roleplay:getPlayerJob', k, function(job)
												if(job)then
													if(job.job == "police")then
														TriggerClientEvent('chatMessage', k, 'BRAQUAGE', {255, 0, 0}, "Braquage terminé à: ^2" .. bank.prettyName)
													end
												end
											end)
										end
									end)
								end
							end)
						else
							TriggerClientEvent('chatMessage', source, "ROBBERY", {255, 0, 0}, "Pas assez de policiers en ligne (2 requis).")
						end
					end
				end
			end)
		end)
	end
end)