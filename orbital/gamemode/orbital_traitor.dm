/datum/role/orbital_traitor
	name = ORBITAL_TRAITOR
	id = ORBITAL_TRAITOR
	logo_state = "synd-logo"

	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "traitor"

	skillset_type = /datum/skillset/max
	moveset_type = /datum/combat_moveset/cqc
	change_to_maximum_skills = FALSE

/datum/role/orbital_traitor/forgeObjectives()
	AppendObjective(/datum/objective/interrupt)

	AppendObjective(/datum/objective/provoke_evac)

	AppendObjective(/datum/objective/hijack/orbital)

	return TRUE

/datum/role/orbital_traitor/Greet(greeting = GREET_DEFAULT, custom)
	antag.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	return TRUE

/datum/role/orbital_traitor/OnPostSetup(laterole)
	. = ..()

	ADD_TRAIT(antag.current, TRAIT_HIDDEN_STASH, ROLE_TRAIT)

	to_chat(antag, "<span class='warning'>Точно! В какой-то из мусорок я оставлял свое снаряжение. Только в какой?..</span>")
