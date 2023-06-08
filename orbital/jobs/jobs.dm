/mob
	var/radio_voice


/datum/job/prom
	var/preffix

/datum/job/prom/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/names = splittext(H.real_name, " ")
	var/last_name = names[length(names)]
	H.radio_voice = "[preffix][last_name]"


/datum/job/prom/captain
	title = "Captain"
	preffix = "Captain "
	flag = CAPTAIN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "nobody! You're on your own, buddy."
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	is_head = TRUE
	access = list() 			//See get_access()
	outfit = /datum/outfit/job/prom_captain
	skillsets = list("Captain" = /datum/skillset/prom_captain)

/datum/job/prom/captain/get_access()
	return get_all_accesses()

/datum/job/prom/logistics_officer
	title = "Logistics Officer"
	preffix = "Logistics Officer "
	flag = QUARTERMASTER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargoGold
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_recycler)
	outfit = /datum/outfit/job/prom_logistics_officer
	skillsets = list("Logistics Officer" = /datum/skillset/prom_logistics_officer)

/datum/job/prom/pilot
	title = "Pilot"
	preffix = "Flight Officer "
	flag = MINER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the marshal"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_mining, access_mint, access_mining_station, access_mailsorting)
	outfit = /datum/outfit/job/prom_pilot
	skillsets = list("Pilot" = /datum/skillset/prom_pilot)

/datum/job/prom/chief_engineer
	title = "Chief Engineer!"
	preffix = "Chief Engineer "
	flag = CHIEF
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/engGold
	req_admin_notify = 1
	is_head = TRUE
	access = list(
		access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
		access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
		access_heads, access_construction, access_sec_doors, access_minisat,
		access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload, access_engineering_lobby
	)
	outfit = /datum/outfit/job/prom_chief_engineer
	skillsets = list("Chief Engineer" = /datum/skillset/prom_chief_engineer)

/datum/job/prom/engineer
	title = "Engineer"
	preffix = "Engineer "
	flag = ENGINEER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	idtype = /obj/item/weapon/card/id/eng
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_engineering_lobby)
	outfit = /datum/outfit/job/prom_engineer
	skillsets = list("Engineer" = /datum/skillset/prom_engineer)

/datum/job/prom/medic
	title = "Medical Officer"
	preffix = "Dr. "
	flag = DOCTOR
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_morgue, access_surgery, access_maint_tunnels, access_medbay_storage)
	outfit = /datum/outfit/job/prom_medic
	skillsets = list("Medical Officer" = /datum/skillset/prom_medic)

/datum/job/prom/psitherapist
	title = "Psi-therapist"
	preffix = "Dr. "
	flag = PSYCHIATRIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeef0"
	idtype = /obj/item/weapon/card/id/med
	access = list(access_medical, access_psychiatrist, access_medbay_storage)
	outfit = /datum/outfit/job/prom_psitherapist
	skillsets = list("Psy-therapist" = /datum/skillset/prom_psitherapist)

/datum/job/prom/research_director
	title = "Research Director!"
	preffix = "Research Director "
	flag = RD
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	idtype = /obj/item/weapon/card/id/sciGold
	req_admin_notify = 1
	is_head = TRUE
	access = list(
		access_rd, access_heads, access_tox, access_genetics, access_morgue,
		access_tox_storage, access_teleporter, access_sec_doors, access_minisat,
		access_research, access_robotics, access_xenobiology, access_ai_upload,
		access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway,
		access_xenoarch, access_maint_tunnels, access_eva
	)
	skillsets = list("Research Director" = /datum/skillset/prom_research_director)
	outfit = /datum/outfit/job/prom_research_director

/datum/job/prom/specialist
	title = "Specialist"
	preffix = "Specialist "
	flag = SCIENTIST
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the research director"
	selection_color = "#ffeeff"
	idtype = /obj/item/weapon/card/id/sci
	access = list(access_tox, access_tox_storage, access_research, access_xenoarch)
	outfit = /datum/outfit/job/prom_specialist
	skillsets = list("Specialist" = /datum/skillset/prom_specialist)

/datum/job/prom/marshal
	title = "Marshal"
	preffix = "Marshal "
	flag = HOS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	idtype = /obj/item/weapon/card/id/secGold
	req_admin_notify = 1
	is_head = TRUE
	access = list(
		access_security, access_sec_doors, access_brig, access_armory,
		access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
		access_research, access_mining, access_medical, access_construction, access_mailsorting,
		access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_detective
	)
	outfit = /datum/outfit/job/prom_marshal
	skillsets = list("Marshal" = /datum/skillset/prom_marshal)
