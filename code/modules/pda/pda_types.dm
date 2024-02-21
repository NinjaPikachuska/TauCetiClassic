/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-m"

/obj/item/device/pda/viro
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-v"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-e"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-s"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-det"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-j"
	ttone = "slip"

/obj/item/device/pda/science
	default_cartridge = /obj/item/weapon/cartridge/signal/science
	icon_state = "pda-tox"
	ttone = "boom"

/obj/item/device/pda/clown
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/clown/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 4, NONE, CALLBACK(src, PROC_REF(AfterSlip)))

/obj/item/device/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != owner))
		var/obj/item/weapon/cartridge/clown/cart = cartridge
		if(istype(cart) && cart.charges < 5)
			cart.charges++

/obj/item/device/pda/clown/Destroy()
	if(slot_equipped)
		unslip_lying_user(loc)
		var/mob/living/carbon/human/H = loc
		if(istype(H) && H.lying)
			remove_user_slip(loc)
	return ..()

/obj/item/device/pda/clown/proc/make_user_slip(mob/living/carbon/user)
	user.AddComponent(/datum/component/slippery, 2, NO_SLIP_WHEN_WALKING)

/obj/item/device/pda/clown/proc/remove_user_slip(mob/living/carbon/user)
	qdel(user.GetComponent(/datum/component/slippery))

/obj/item/device/pda/clown/equipped(mob/living/carbon/user, slot)
	..()
	if(slot in list(SLOT_L_STORE, SLOT_R_STORE, SLOT_BELT, SLOT_WEAR_ID))
		slip_lying_user(user)
		if(user.lying)
			make_user_slip(user)
	else
		unslip_lying_user(user)
		if(user.lying)
			remove_user_slip(user)

/obj/item/device/pda/clown/proc/slip_lying_user(mob/living/carbon/user)
	RegisterSignal(user, COMSIG_MOB_STATUS_LYING, PROC_REF(make_user_slip))
	RegisterSignal(user, COMSIG_MOB_STATUS_NOT_LYING, PROC_REF(remove_user_slip))

/obj/item/device/pda/clown/proc/unslip_lying_user(mob/living/carbon/user)
	UnregisterSignal(user, list(COMSIG_MOB_STATUS_LYING, COMSIG_MOB_STATUS_NOT_LYING))

/obj/item/device/pda/clown/dropped(mob/living/carbon/user)
	..()
	unslip_lying_user(user)
	if(user.lying)
		remove_user_slip(user)

/obj/item/device/pda/mime
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	message_silent = 1
	ttone = "silence"

/obj/item/device/pda/velocity
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-velocity"

/obj/item/device/pda/velocity/doctor
	default_cartridge = /obj/item/weapon/cartridge/medical

/obj/item/device/pda/heads
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"

/obj/item/device/pda/heads/hop
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-c"
	detonate = 0

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-q"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	default_pen = /obj/item/weapon/pen/edagger
	icon_state = "pda-syn"
	name = "Military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-holy"
	ttone = "holy"

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/device/pda/lawyer2
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer-old"
	ttone = "..."

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-robot"

/obj/item/device/pda/librarian
	icon_state = "pda-libb"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	message_silent = 1 //Quiet in the library!

/obj/item/device/pda/reporter
	icon_state = "pda-libc"

/obj/item/device/pda/forensic
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda-forensic"

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/chef
	icon_state = "pda-chef"

/obj/item/device/pda/barber
	icon_state = "pda-barber"

/obj/item/device/pda/bar
	icon_state = "pda-bar"

/obj/item/device/pda/atmos
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmo"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chem"

/obj/item/device/pda/geneticist
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-gene"

/obj/item/device/pda/blueshield
	icon_state = "pda-blu"
	default_pen = /obj/item/weapon/pen/edagger/legitimate

// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/silicon
	icon_state = "NONE"
	ttone = "data"
	detonate = 0


/obj/item/device/pda/silicon/proc/set_name_and_job(newname, newjob, newrank)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	name = newname + " (" + ownjob + ")"


//AI verb and proc for sending PDA messages.
/obj/item/device/pda/silicon/verb/cmd_send_pdamesg()
	set category = "AI Commands"
	set name = "Send Message"
	set src in usr
	set hidden = 1
	if(usr.stat == DEAD)
		to_chat(usr, "You can't send PDA messages because you are dead!")
		return
	var/list/plist = available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		create_message(usr, selected)


/obj/item/device/pda/silicon/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	toff = !toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>")


/obj/item/device/pda/silicon/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	message_silent = !message_silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(message_silent ? "Off" : "On")]!</span>")


/obj/item/device/pda/silicon/verb/cmd_show_message_log()
	set category = "AI Commands"
	set name = "Show Message Log"
	set src in usr
	set hidden = 1
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/HTML = ""
	for(var/index in tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=\ref[src];choice=Message;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=\ref[src];choice=Message;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")

	var/datum/browser/popup = new(usr, "log", "AI PDA Message Log", 400, 444)
	popup.set_window_options("border=1;can_minimize=0")
	popup.set_content(HTML)
	popup.open()

/obj/item/device/pda/silicon/can_use()
	var/mob/living/silicon/ai/ai_user = loc
	if(istype(ai_user) && ai_user.control_disabled)
		return FALSE
	else
		var/mob/living/silicon/robot/borg_user = loc
		if(istype(borg_user) && borg_user.incapacitated())
			return FALSE
	return TRUE

/obj/item/device/pda/silicon/attack_self(mob/user)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MASTER, 30)
	return

//Special PDA for robots

/obj/item/device/pda/silicon/robot/cmd_toggle_pda_receiver()
	set category = "Robot Commands"
	set hidden = 1
	..()

/obj/item/device/pda/silicon/robot/cmd_toggle_pda_silent()
	set category = "Robot Commands"
	set hidden = 1
	..()

/obj/item/device/pda/silicon/pai
	ttone = "assist"
