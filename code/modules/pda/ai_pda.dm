// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/silicon
	icon_state = "NONE"
	ttone = "data"
	detonate = FALSE

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
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		to_chat(usr, "<span class='warning'>Cannot use messenger!</span>")
		return
	var/list/plist = M.available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		M.create_message(usr, selected)


/obj/item/device/pda/silicon/verb/cmd_toggle_pda_receiver()
	set category = "AI Commands"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		to_chat(usr, "<span class='warning'>Cannot use messenger!</span>")
		return
	M.toff = !M.toff
	to_chat(usr, "<span class='notice'>PDA sender/receiver toggled [(M.toff ? "Off" : "On")]!</span>")


/obj/item/device/pda/silicon/verb/cmd_toggle_pda_silent()
	set category = "AI Commands"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	silent = !silent
	to_chat(usr, "<span class='notice'>PDA ringer toggled [(silent ? "Off" : "On")]!</span>")


/obj/item/device/pda/silicon/verb/cmd_show_message_log()
	set category = "AI Commands"
	set name = "Show Message Log"
	set src in usr
	set hidden = 1
	if(usr.stat == DEAD)
		to_chat(usr, "You can't do that because you are dead!")
		return
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(!M)
		to_chat(usr, "<span class='warning'>Cannot use messenger!</span>")
		return
	var/HTML = ""
	for(var/chat_ref in M.chats)
		var/datum/pda_chat/pc = M.chats[chat_ref]
		HTML += "<b><a href='byond://?src=[REF(M)];choice=Message;target=[REF(pc.recipient?.resolve())]'>[pc.get_recipient_name()] ([pc.get_recipient_job()])</a></b><br>"
		for(var/datum/pda_message/pm in pc.messages)
			HTML += "[pm.outgoing ? "&rarr;" : "&larr;"] <i>[pm.message]</i><br>"

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
