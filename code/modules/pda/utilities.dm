/datum/data/pda/utility/flashlight
	name = "Enable Flashlight"
	icon = "lightbulb-o"

	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function

/datum/data/pda/utility/flashlight/start(mob/user)
	fon = !fon
	name = fon ? "Disable Flashlight" : "Enable Flashlight"
	pda.update_shortcuts()
	pda.set_light(fon ? f_lum : 0)
	if(fon)
		pda.overlays += image('icons/obj/pda.dmi', "pda-light")
	else
		pda.overlays -= image('icons/obj/pda.dmi', "pda-light")

/datum/data/pda/utility/honk
	name = "Honk Synthesizer"
	icon = "smile-o"
	category = "Clown"

	var/last_honk //Also no honk spamming that's bad too

/datum/data/pda/utility/honk/start(mob/user)
	if(!(last_honk && world.time < last_honk + 20))
		playsound(pda.loc, 'sound/items/bikehorn.ogg', 50, 1)
		last_honk = world.time

/datum/data/pda/utility/toggle_door
	name = "Toggle Door"
	icon = "external-link-alt"
	var/remote_door_id = ""

/datum/data/pda/utility/toggle_door/start(mob/user)
	for(var/obj/machinery/door/poddoor/M in global.poddoor_list)
		if(M.id == remote_door_id)
			if(M.density)
				M.open()
			else
				M.close()


/datum/data/pda/utility/scanmode/medical
	base_name = "Med Scanner"
	icon = "heart-o"

/datum/data/pda/utility/scanmode/medical/scan_mob(mob/living/M, mob/living/user)
	user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", "<span class='notice'>You analyze [M]'s vitals.</span>")

	var/message = health_analyze(M, user, TRUE, TRUE)
	to_chat(user, message)

/datum/data/pda/utility/scanmode/dna
	base_name = "DNA Scanner"
	icon = "link"

/datum/data/pda/utility/scanmode/dna/scan_mob(mob/living/C as mob, mob/living/user as mob)
	var/message = ""
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!istype(H.dna, /datum/dna))
			message += "<span class='notice'>No fingerprints found on [H]</span>"
		else
			message += "<span class='notice'>[H]'s Fingerprints: [md5(H.dna.uni_identity)]</span>"
	if(length(message))
		to_chat(user, message)
	scan_blood(C, user)

/datum/data/pda/utility/scanmode/dna/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	scan_blood(A, user)

/datum/data/pda/utility/scanmode/dna/proc/scan_blood(atom/A, mob/user)
	var/message = ""
	if(!A.blood_DNA)
		message += "<span class='notice'>No blood found on [A]</span>"
		if(A.blood_DNA)
			qdel(A.blood_DNA)
	else
		message += "<span class='notice'>Blood found on [A]. Analysing...</span>"
		spawn(15)
		for(var/blood in A.blood_DNA)
			message += "<span class='notice'>Blood type: [A.blood_DNA[blood]]\nDNA: [blood]</span>"
	to_chat(user, message)

/datum/data/pda/utility/scanmode/halogen
	base_name = "Halogen Counter"
	icon = "exclamation-circle"

/datum/data/pda/utility/scanmode/halogen/scan_mob(mob/living/C as mob, mob/living/user as mob)
	var/message = ""
	C.visible_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>")

	message += "<span class='notice'>Analyzing Results for [C]:</span>"
	if(C.radiation)
		message += "<span class='notice'>Radiation Level: [C.radiation > 0 ? "</span><span class='danger'>[C.radiation]" : "0"]</span>"
	else
		message += "<span class='notice'>No radiation detected.</span>"
	to_chat(user, message)

/datum/data/pda/utility/scanmode/reagent
	base_name = "Reagent Scanner"
	icon = "flask"

/datum/data/pda/utility/scanmode/reagent/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	if(isnull(A.reagents))
		to_chat(user, "<span class='notice'>No significant chemical agents found in [A].</span>")
		return

	var/message = ""
	if(A.reagents.reagent_list.len)
		for (var/datum/reagent/R in A.reagents.reagent_list)
			message += "\n &emsp; <span class='notice'>[R]</span>"

	if(message)
		to_chat(user, "<span class='notice'>Chemicals found: [message]</span>")
	else
		to_chat(user, "<span class='notice'>No active chemical agents found in [A].</span>")

/datum/data/pda/utility/scanmode/gas
	base_name = "Gas Scanner"
	icon = "tachometer-alt"

/datum/data/pda/utility/scanmode/gas/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	pda.analyze_gases(A, user, FALSE)
