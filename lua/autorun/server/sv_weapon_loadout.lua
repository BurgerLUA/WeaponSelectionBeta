AddCSLuaFile( "autorun/client/cl_weaponselection.lua" )

--cvar.SetFlags("convarname" , cvar2.GetFlags("convarname") - FCVAR_SERVER_CAN_EXECUTE)

CreateConVar("bur_spawnprotection", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE , "Enable or disable spawn protection. Values other than 0 enables it " )
CreateConVar("bur_shieldtime", "3", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE , "Time it takes for the spawn protection to wear off." )
CreateConVar("bur_giveweaponsafter", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE , "Enable or disable giving weapons AFTER spawn protection . Values other than 0 enables it " )
CreateConVar("bur_spawneffect", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE , "Enable or disable spawn protection effect. Values other than 0 enables it " )

local folder = "weaponselection"


function FirstWeaponSpawn( ply )

	local storename = string.gsub(ply:SteamID(), ":", "_")

	if not file.Exists( folder, "DATA") then
		file.CreateDir( folder ) 
		print(folder .. " doesn't exist, creating a new one.")
	else
		print(folder .. " exists.")
	end
	
	
	
	print("Folder:" .. folder)
	
	if not file.Exists( folder.."/"..storename .. ".txt", "DATA" ) then 
		file.Write( folder.."/"..storename..".txt", "nil nil nil nil nil" )
		print(folder.."/"..storename .. ".txt doesn't exist, creating a new one.")
	else	
		print(folder.."/"..storename .. ".txt exists.")
	end
	
	TrackerString = string.Explode(" ",file.Read(folder.."/"..storename ..".txt"))
	--PrintTable(TrackerString)
	ply.Wep = {}
		
	for i=1, 5 do
		ply.Wep[i] = TrackerString[i]
		ply:SetNWString("Wep"..i,ply.Wep[i])
	end
	
	
	
	
end

hook.Add( "PlayerInitialSpawn", "Load Previous Loadout", FirstWeaponSpawn )


function PlayerSpawn(ply)

	ply:StripAmmo()
	ply:StripWeapons()
	ply:Give("weapon_physgun")
	ply:Give("gmod_tool")
	ply:ConCommand("gm_giveswep weapon_bur_medkit")
	ply:ConCommand("gm_giveswep weapon_cs_he")

	if GetConVar("bur_spawnprotection"):GetInt() == 0 or GetConVar("bur_giveweaponsafter"):GetInt() <= 0 then 
		GiveWeapons(ply)
	else
		EnableProtection(ply)
		
		timer.Create( ply:Name() .. "removehealth", GetConVar("bur_shieldtime"):GetInt(), 1, function()
			DisableProtection(ply)
			if GetConVar("bur_giveweaponsafter"):GetInt() >= 1 then 
				GiveWeapons(ply)
			end
		end)

		if not ply:Alive() then
			timer.Destroy(ply:Name() .. "removehealth")
		end
	end
end

hook.Add("PlayerSpawn", "Player Spawn", PlayerSpawn)

function GivePlayerAWeapon( ply, cmd, args )

	ply.Wep = {}

	for i=1, 5 do
		ply.Wep[i] = args[i]
		ply:SetNWString("Wep"..i,args[i])
	end
	


	
	local storename = string.gsub(ply:SteamID(), ":", "_")
	local folder = "weaponselection"


	file.Write( folder.."/"..storename..".txt", ply.Wep[1] .. " " .. ply.Wep[2] .. " " .. ply.Wep[3] .. " " .. ply.Wep[4] .. " " .. ply.Wep[5]  )
	
	
	
ply:ChatPrint("Your loadout will change next spawn")
end
 
concommand.Add("weapon_take", GivePlayerAWeapon) --make the console command "weapon_take" run the GivePlayerAWeapon function




function EnableProtection(ply)
	ply:GodEnable()
	ply:SetMaterial("Models/effects/splodearc_sheet")
	if GetConVar("bur_spawneffect"):GetInt() == 1 then 
		ply:ConCommand("pp_mat_overlay_refractamount 0.1")
		ply:ConCommand("pp_mat_overlay effects/combine_binocoverlay")
	end
end


function DisableProtection(ply)
	ply:GodDisable()
	ply:SetMaterial("")
	ply:ConCommand("pp_mat_overlay_refractamount 0")
	ply:ConCommand("pp_mat_overlay \"\" ")
	ply:PrintMessage( HUD_PRINTCENTER, "Spawn Protection has worn off!" )
end


function GiveWeapons(ply)
	if ply.Wep == nil then return end
	for i=1, 5 do
		if ply.Wep[i] ~= nil then 
			ply:ConCommand("gm_giveswep " .. ply.Wep[i])
		end
	end
end

