/datum/data/pda/messenger_plugin
	var/datum/data/pda/app/messenger/messenger

/datum/data/pda/messenger_plugin/proc/user_act(mob/user as mob, obj/item/device/pda/P)


/datum/data/pda/messenger_plugin/virus
	name = "*Send Virus*"

/datum/data/pda/messenger_plugin/virus/user_act(mob/user as mob, obj/item/device/pda/P)
	var/datum/data/pda/app/messenger/M = P.find_program(/datum/data/pda/app/messenger)

	if(M && !M.toff && pda.cartridge.charges > 0)
		pda.cartridge.charges--
		return 1
	return 0


/datum/data/pda/messenger_plugin/virus/clown
	icon = "star"

/datum/data/pda/messenger_plugin/virus/clown/user_act(mob/user as mob, obj/item/device/pda/P)
	. = ..(user, P)
	if(.)
		user.show_message("<span class='notice'>Virus sent!</span>", 1)
		P.honkamt = (rand(15,20))
		P.ttone = "honk"


/datum/data/pda/messenger_plugin/virus/mime
	icon = "arrow-circle-down"

/datum/data/pda/messenger_plugin/virus/mime/user_act(mob/user as mob, obj/item/device/pda/P)
	. = ..(user, P)
	if(.)
		user.show_message("<span class='notice'>Virus sent!</span>", 1)
		P.silent = TRUE
		P.ttone = "silence"


/datum/data/pda/messenger_plugin/virus/detonate
	name = "*Detonate*"
	icon = "exclamation-circle"

/datum/data/pda/messenger_plugin/virus/detonate/user_act(mob/user, obj/item/device/pda/pda_to_detonate)
	. = ..()
	if(.)
		if(!pda_to_detonate.detonate || pda_to_detonate.hidden_uplink)
			user.show_message("<span class='warning'>The target PDA does not seem to respond to the detonation command.</span>", 1)
			pda.cartridge.charges++
		else
			user.show_message("<span class='notice'>Success!</span>", 1)
			log_admin("[key_name(user)] just blew up [pda_to_detonate] with the Detomatix cartridge")
			message_admins("[key_name_admin(user)] just blew up [pda_to_detonate] with the Detomatix cartridge", 1)
			pda.detonate_act(pda_to_detonate)
