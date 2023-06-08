/datum/outfit/job/prom_logistics_officer
	name = OUTFIT_JOB_NAME("Logistics Officer")

	uniform = /obj/item/clothing/under/rank/cargo
	uniform_f = /obj/item/clothing/under/rank/cargo_fem
	shoes =  /obj/item/clothing/shoes/brown
	l_ear =  /obj/item/device/radio/headset

/datum/outfit/job/prom_pilot
	name = OUTFIT_JOB_NAME("Pilot")

	uniform = /obj/item/clothing/under/rank/miner
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_ENGINEERING

/datum/outfit/job/prom_captain
	name = OUTFIT_JOB_NAME("Captain")

	uniform = /obj/item/clothing/under/rank/captain
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_CAPTAIN

/datum/outfit/job/prom_chief_engineer
	name = OUTFIT_JOB_NAME("Chief Engineer")

	uniform = /obj/item/clothing/under/rank/chief_engineer
	shoes = /obj/item/clothing/shoes/boots/work
	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_ENGINEERING

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)

/datum/outfit/job/prom_engineer
	name = OUTFIT_JOB_NAME("Engineer")

	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/boots/work
	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_ENGINEERING

	survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen/engi)
	prevent_survival_kit_items = list(/obj/item/weapon/tank/emergency_oxygen)

/datum/outfit/job/prom_medic
	name = OUTFIT_JOB_NAME("Medical Officer")

	uniform = /obj/item/clothing/under/rank/medical
	uniform_f =/obj/item/clothing/under/rank/medical/skirt
	shoes = /obj/item/clothing/shoes/white

	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_MEDICAL

/datum/outfit/job/prom_psitherapist
	name = OUTFIT_JOB_NAME("Psi-Therapist")

	uniform = /obj/item/clothing/under/rank/psych
	shoes = /obj/item/clothing/shoes/laceup

	l_ear = /obj/item/device/radio/headset

/datum/outfit/job/prom_research_director
	name = OUTFIT_JOB_NAME("Research Director")

	uniform = /obj/item/clothing/under/rank/research_director
	shoes = /obj/item/clothing/shoes/brown

	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_RESEARCH

/datum/outfit/job/prom_specialist
	name = OUTFIT_JOB_NAME("Specialist")

	uniform = /obj/item/clothing/under/rank/scientist
	shoes = /obj/item/clothing/shoes/white

	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_RESEARCH

/datum/outfit/job/prom_marshal
	name = OUTFIT_JOB_NAME("Marshal")

	uniform = /obj/item/clothing/under/rank/head_of_security
	uniform_f = /obj/item/clothing/under/rank/head_of_security_fem
	shoes = /obj/item/clothing/shoes/boots
	l_ear = /obj/item/device/radio/headset

	back_style = BACKPACK_STYLE_SECURITY
