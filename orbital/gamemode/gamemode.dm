/datum/game_mode/orbital
	name = "Orbital Station"
	config_name = "orbital"

	minimum_player_count = 1

	var/time_to_awake = 5 MINUTES

/datum/game_mode/orbital/Setup()
	addtimer(CALLBACK(src, .proc/awake_traitor), time_to_awake)
	return TRUE

/datum/game_mode/orbital/proc/create_traitor(mob/traitor)
	if(!traitor)
		awake_traitor()
		return

	to_chat(traitor, "<span class='warning'>Оу...</span>")

	var/datum/faction/orbital_traitor/O = create_uniq_faction(/datum/faction/orbital_traitor)
	add_faction_member(O, traitor, FALSE, TRUE)

/datum/game_mode/orbital/proc/awake_traitor()
	var/list/possible_traitor = list()
	for(var/mob/living/carbon/human/player in living_list)
		if(player.client && player.mind && player.stat != DEAD)
			to_chat(player, "<span class='notice'>Ах да, кажется я начинаю вспоминать...</span>")
			possible_traitor += player

	var/mob/traitor = pick(possible_traitor)
	addtimer(CALLBACK(src, .proc/create_traitor, traitor), 5 SECONDS)

/datum/faction/orbital_traitor
	name = "Orbital Traitor"
	ID = ORBITAL_TRAITOR

	min_roles = 1
	max_roles = 1

	logo_state = "synd-logo"

	roletype = /datum/role/orbital_traitor
	initroletype = /datum/role/orbital_traitor

