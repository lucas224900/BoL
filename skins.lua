local version = "1.32"

--Global Skin Changer by Perplexity--
--Updated by lucas22490--
--Added Autoupdater --

local autoupdateenabled = true
local UPDATE_SCRIPT_NAME = "skins"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/lucas224900/BoL/master/skins.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local ServerData
if autoupdateenabled then
	GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH, function(d) ServerData = d end)
	function update()
		if ServerData ~= nil then
			local ServerVersion
			local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
			if sstart then
				send, tmp = string.find(ServerData, "\"", sstart+1)
			end
			if send then
				ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
			end

			if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
				DownloadFile(UPDATE_URL.."?nocache"..myHero.charName..os.clock(), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end



local championSkins = { ["Aatrox"] = {"Classic", "Justicar", "Mecha"}, 
["Ahri"] = {"Classic", "Dynasty", "Midnight", "Foxfire", "Popstar"}, 
["Akali"] = {"Classic", "Stinger", "Crimson", "All-star", "Nurse", "Blood Moon", "Silverfang"}, 
["Alistar"] = {"Classic", "Black", "Golden", "Matador", "Longhorn", "Unchained", "Infernal", "Sweeper"}, 
["Amumu"] = {"Classic", "Pharaoh", "Vancouver", "Emumu", "Re-Gifted", "Almost-Prom King", "Little Knight", "Sad Robot"}, 
["Anivia"] = {"Classic", "Team Spirit", "Bird of Prey", "Noxus Hunter", "Hextech", "Blackfrost"}, 
["Annie"] = {"Classic", "Goth", "Red Riding", "Annie in Wonderland", "Prom Queen", "Frostfire", "Reverse", "FrankenTibbers", "Panda"}, 
["Ashe"] = {"Classic", "Freljord", "Sherwood Forest", "Woad", "Queen", "Amethyst", "Heartseeker"},
["Azir"] = {"Classic", "Galactic"},
["Blitzcrank"] = {"Classic", "Rusty", "Goalkeeper", "Boom Boom", "Piltover Customs", "Definitely Not", "iBlitzcrank", "Riot"}, 
["Brand"] = {"Classic", "Apocalyptic", "Vandal", "Cryocore", "Zombie"}, 
["Braum"] = {"Classic", "Dragonslayer"}, 
["Caitlyn"] = {"Classic", "Resistance", "Sheriff", "Safari", "Arctic Warfare", "Officer", "Headhunter"}, 
["Cassiopeia"] = {"Classic", "Desperada", "Siren", "Mythic", "Jade Fang"}, 
["Chogath"] = {"Classic", "Nightmare", "Gentleman", "Loch Ness", "Jurassic", "Battlecast Prime"}, 
["Corki"] = {"Classic", "UFO", "Ice Toboggan", "Red Baron", "Hot Rod", "Urfrider", "Dragonwing", "Fnatic"}, 
["Darius"] = {"Classic", "Lord", "Bioforge", "Woad King", "Dunkmaster"}, 
["Diana"] = {"Classic", "Dark Valkyrie", "Lunar Goddess"}, 
["DrMundo"] = {"Classic", "Toxic", "Mr. Mundoverse", "Corporate Mundo", "Mundo Mundo", "Executioner Mundo", "Rageborn Mundo", "TPA Mundo"}, 
["Draven"] = {"Classic", "Soul Reaver", "Gladiator", "Primetime"}, 
["Elise"] = {"Classic", "Death Blossom", "Victorious"}, 
["Evelynn"] = {"Classic", "Shadow", "Masquerade", "Tango", "Safecracker"}, 
["Ezreal"] = {"Classic", "Nottingham", "Striker", "Frosted", "Explorer", "Pulsefire", "TPA", "Debonair"}, 
["FiddleSticks"] = {"Classic", "Spectral", "Union Jack", "Bandito", "Pumpkinhead", "Fiddle Me Timbers", "Surprise Party", "Dark Candy"}, 
["Fiora"] = {"Classic", "Royal Guard", "Nightraven", "Headmistress"}, 
["Fizz"] = {"Classic", "Atlantean", "Tundra", "Fisherman", "Void"}, 
["Galio"] = {"Classic", "Enchanted", "Hextech", "Commando", "Gatekeeper"}, 
["Gangplank"] = {"Classic", "Spooky", "Minuteman", "Sailor", "Toy Soldier", "Special Forces", "Sultan"}, 
["Garen"] = {"Classic", "Sanguine", "Desert Trooper", "Commando", "Dreadknight", "Rugged", "Steel Legion"},
["Gnar"] = {"Classic", "Dino"}, 
["Gragas"] = {"Classic", "Scuba", "Hillbilly", "Santa", "Gragas, Esq.", "Vandal", "Oktoberfest", "Superfan", "Fnatic"}, 
["Graves"] = {"Classic", "Hired Gun", "Jailbreak", "Mafia", "Riot", "Pool Party"}, 
["Hecarim"] = {"Classic", "Blood Knight", "Reaper", "Headless", "Arcade"}, 
["Heimerdinger"] = {"Classic", "Alien Invader", "Blast Zone", "Piltover Customs", "Snowmerdinger", "Hazmat"}, 
["Irelia"] = {"Classic", "Nightblade", "Aviator", "Infiltrator", "Frostblade"}, 
["Janna"] = {"Classic", "Tempest", "Hextech", "Frost Queen", "Victorious", "Forecast", "Fnatic"}, 
["JarvanIV"] = {"Classic", "Commando", "Dragonslayer", "Darkforge", "Victorious", "Warring Kingdoms", "Fnatic"}, 
["Jax"] = {"Classic", "The Mighty", "Vandal", "Angler", "PAX", "Jaximus", "Temple", "Nemesis", "SKT T1"}, 
["Jayce"] = {"Classic", "Full Metal", "Debonair"}, 
["Jinx"] = {"Classic", "Mafia"},
["Kalista"] = {"Classic", "Blood Moon"},  
["Karma"] = {"Classic", "Sun Goddess", "Sakura", "Traditional", "Order of the Lotus"}, 
["Karthus"] = {"Classic", "Phantom", "Statue of", "Grim Reaper", "Pentakill", "Fnatic"}, 
["Kassadin"] = {"Classic", "Festival", "Deep One", "Pre-Void", "Harbinger"}, 
["Katarina"] = {"Classic", "Mercenary", "Red Card", "Bilgewater", "Kitty Cat", "High Command", "Sandstorm", "Slay Belle"}, 
["Kayle"] = {"Classic", "Silver", "Viridian", "Unmasked", "Battleborn", "Judgment", "Aether Wing", "Riot"}, 
["Kennen"] = {"Classic", "Deadly", "Swamp Master", "Karate", "Kennen M.D.", "Arctic Ops"}, 
["Khazix"] = {"Classic", "Mecha", "Guardian of the Sands"}, 
["KogMaw"] = {"Classic", "Caterpillar", "Sonoran", "Monarch", "Reindeer", "Lion Dance", "Deep Sea", "Jurassic", "Battlecast"}, 
["Leblanc"] = {"Classic", "Wicked", "Prestigious", "Mistletoe", "Ravenborn"}, 
["LeeSin"] = {"Classic", "Traditional", "Acolyte", "Dragon Fist", "Muay Thai", "Pool Party", "SKT T1"}, 
["Leona"] = {"Classic", "Valkyrie", "Defender", "Iron Solari", "Pool Party"}, 
["Lissandra"] = {"Classic", "Bloodstone", "Blade Queen"}, 
["Lucian"] = {"Classic", "Hired Gun", "Striker"}, 
["Lulu"] = {"Classic", "Bittersweet", "Wicked", "Dragon Trainer", "Winter Wonder"}, 
["Lux"] = {"Classic", "Sorceress", "Spellthief", "Commando", "Imperial", "Steel Legion"}, 
["Malphite"] = {"Classic", "Shamrock", "Coral Reef", "Marble", "Obsidian", "Glacial", "Mecha"}, 
["Malzahar"] = {"Classic", "Vizier", "Shadow Prince", "Djinn", "Overlord"}, 
["Maokai"] = {"Classic", "Charred", "Totemic", "Festive", "Haunted", "Goalkeeper"}, 
["MasterYi"] = {"Classic", "Assassin", "Chosen", "Ionia", "Samurai Yi", "Headhunter"}, 
["MissFortune"] = {"Classic", "Cowgirl", "Waterloo", "Secret Agent", "Candy Cane", "Road Warrior", "Mafia", "Arcade"}, 
["Mordekaiser"] = {"Classic", "Dragon Knight", "Infernal", "Pentakill", "Lord"}, 
["Morgana"] = {"Classic", "Exiled", "Sinful Succulence", "Blade Mistress", "Blackthorn", "Ghost Bride", "Victorious"}, 
["Nami"] = {"Classic", "Koi", "River Spirit"}, 
["Nasus"] = {"Classic", "Galactic", "Pharaoh", "Dreadknight", "Riot K-9", "Infernal"}, 
["Nautilus"] = {"Classic", "Abyssal", "Subterranean", "AstroNautilus"}, 
["Nidalee"] = {"Classic", "Snow Bunny", "Leopard", "French Maid", "Pharaoh", "Bewitching", "Headhunter"}, 
["Nocturne"] = {"Classic", "Frozen Terror", "Void", "Ravager", "Haunting", "Eternum"}, 
["Nunu"] = {"Classic", "Sasquatch", "Workshop", "Grungy", "Nunu Bot", "Demolisher", "TPA"}, 
["Olaf"] = {"Classic", "Forsaken", "Glacial", "Brolaf", "Pentakill"}, 
["Orianna"] = {"Classic", "Gothic", "Sewn Chaos", "Bladecraft", "TPA"}, 
["Pantheon"] = {"Classic", "Myrmidon", "Ruthless", "Perseus", "Full Metal", "Glaive Warrior", "Dragonslayer"}, 
["Poppy"] = {"Classic", "Noxus", "Lollipoppy", "Blacksmith", "Ragdoll", "Battle Regalia", "Scarlet Hammer"}, 
["Quinn"] = {"Classic", "Phoenix", "Woad Scout"}, 
["Rammus"] = {"Classic", "King", "Chrome", "Molten", "Freljord", "Ninja", "Full Metal"}, 
["Renekton"] = {"Classic", "Galactic", "Outback", "Bloodfury", "Rune Wars", "Scorched Earth", "Pool Party"}, 
["Rengar"] = {"Classic", "Headhunter", "Night Hunter"}, 
["Riven"] = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade"}, 
["Rumble"] = {"Classic", "Rumble in the Jungle", "Bilgerat", "Super Galaxy"}, 
["Ryze"] = {"Classic", "Human", "Tribal", "Uncle", "Triumphant", "Professor", "Zombie", "Dark Crystal", "Pirate"}, 
["Sejuani"] = {"Classic", "Sabretusk", "Darkrider", "Traditional", "Bear Cavalry"}, 
["Shaco"] = {"Classic", "Mad Hatter", "Royal", "Nutcracko", "Workshop", "Asylum", "Masked"}, 
["Shen"] = {"Classic", "Frozen", "Yellow Jacket", "Surgeon", "Blood Moon", "Warlord", "TPA"}, 
["Shyvana"] = {"Classic", "Ironscale", "Boneclaw", "Darkflame", "Ice Drake", "Championship"}, 
["Singed"] = {"Classic", "Riot Squad", "Hextech", "Surfer", "Mad Scientist", "Augmented", "Snow Day"}, 
["Sion"] = {"Classic", "Hextech", "Barbarian", "Lumberjack", "Warmonger"}, 
["Sivir"] = {"Classic", "Warrior Princess", "Spectacular", "Huntress", "Bandit", "PAX", "Snowstorm"}, 
["Skarner"] = {"Classic", "Sandscourge", "Earthrune", "Battlecast Alpha"}, 
["Sona"] = {"Classic", "Muse", "Pentakill", "Silent Night", "Guqin", "Arcade"}, 
["Soraka"] = {"Classic", "Dryad", "Divine", "Celestine", "Reaper"}, 
["Swain"] = {"Classic", "Northern Front", "Bilgewater", "Tyrant"}, 
["Syndra"] = {"Classic", "Justicar", "Atlantean"}, 
["Talon"] = {"Classic", "Renegade", "Crimson Elite", "Dragonblade"}, 
["Taric"] = {"Classic", "Emerald", "Armor of the Fifth Age", "Bloodstone"}, 
["Teemo"] = {"Classic", "Happy Elf", "Recon", "Badger", "Astronaut", "Cottontail", "Super", "Panda"}, 
["Thresh"] = {"Classic", "Deep Terror", "Championship"}, 
["Tristana"] = {"Classic", "Riot Girl", "Earnest Elf", "Firefighter", "Guerilla", "Buccaneer", "Rocket Girl"}, 
["Trundle"] = {"Classic", "Lil' Slugger", "Junkyard", "Traditional", "Constable"}, 
["Tryndamere"] = {"Classic", "Highland", "King", "Viking", "Demonblade", "Sultan", "Warring Kingdoms"}, 
["TwistedFate"] = {"Classic", "PAX", "Jack of Hearts", "The Magnificent", "Tango", "High Noon", "Musketeer", "Underworld", "Red Card"}, 
["Twitch"] = {"Classic", "Kingpin", "Whistler Village", "Medieval", "Gangster", "Vandal", "Pickpocket"}, 
["Udyr"] = {"Classic", "Black Belt", "Primal", "Spirit Guard"}, 
["Urgot"] = {"Classic", "Giant Enemy Crabgot", "Butcher", "Battlecast"}, 
["Varus"] = {"Classic", "Blight Crystal", "Arclight", "Arctic Ops"}, 
["Vayne"] = {"Classic", "Vindicator", "Aristocrat", "Dragonslayer", "Heartseeker", "SKT T1"}, 
["Veigar"] = {"Classic", "White Mage", "Curling", "Veigar Greybeard", "Leprechaun", "Baron Von", "Superb Villain", "Bad Santa", "Final Boss"}, 
["Velkoz"] = {"Classic", "Battlecast"}, 
["Vi"] = {"Classic", "Neon Strike", "Officer", "Debonair"}, 
["Viktor"] = {"Classic", "Full Machine", "Prototype", "Creator"}, 
["Vladimir"] = {"Classic", "Count", "Marquis", "Nosferatu", "Vandal", "Blood Lord", "Soulstealer"}, 
["Volibear"] = {"Classic", "Thunder Lord", "Northern Storm", "Runeguard", "Captain"}, 
["Warwick"] = {"Classic", "Grey", "Urf the Manatee", "Big Bad", "Tundra Hunter", "Feral", "Firefang", "Hyena"}, 
["MonkeyKing"] = {"Classic", "Volcanic", "General", "Jade Dragon", "Underworld"}, 
["Xerath"] = {"Classic", "Runeborn", "Battlecast", "Scorched Earth"}, 
["XinZhao"] = {"Classic", "Commando", "Imperial", "Viscero", "Winged Hussar", "Warring Kingdoms"}, 
["Yasuo"] = {"Classic", "High Noon", "Project"}, 
["Yorick"] = {"Classic", "Undertaker", "Pentakill"}, 
["Zac"] = {"Classic", "Special Weapon"}, 
["Zed"] = {"Classic", "Shockblade", "SKT T1"}, 
["Ziggs"] = {"Classic", "Mad Scientist", "Major", "Pool Party", "Snow Day"}, 
["Zilean"] = {"Classic", "Old Saint", "Groovy", "Shurima Desert", "Time Machine"}, 
["Zyra"] = {"Classic", "Wildfire", "Haunted", "SKT T1"}
}

local skinNum = nil

function OnLoad()
  menu = scriptConfig("Skin Changer", "skin")
  skinNum = #championSkins[player.charName]
  for i, skin in pairs(championSkins[player.charName]) do
    menu:addParam("skin"..i, skin, SCRIPT_PARAM_ONOFF, false)
  end
  
   print("<font color=\"#FF0000\">Skin Changer loaded. Pick a skin from the menu! Updated 11/05/2014 by lucas22490</font>")
end

function OnDraw()
if menu then
        for i = 1, skinNum do
            if menu["skin"..i] then
                menu["skin"..i] = false
                GenModelPacket(player.charName, i - 1)
            end
        end
    end
end

function GenModelPacket(champ, skinId)
    p = CLoLPacket(0x97)
    p:EncodeF(player.networkID)
    p.pos = 1
    t1 = p:Decode1()
    t2 = p:Decode1()
    t3 = p:Decode1()
    t4 = p:Decode1()
    p:Encode1(t1)
    p:Encode1(t2)
    p:Encode1(t3)
    p:Encode1(bit32.band(t4,0xB))
    p:Encode1(1)
    p:Encode4(skinId)
    for i = 1, #champ do
        p:Encode1(string.byte(champ:sub(i,i)))
    end
    for i = #champ + 1, 64 do
        p:Encode1(0)
    end
    p:Hide()
    RecvPacket(p)
end