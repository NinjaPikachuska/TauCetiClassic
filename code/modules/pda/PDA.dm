#define TRANSCATION_COOLDOWN 30	//delay between transactions
#define ALLOWED_ID_OVERLAYS list("id", "gold", "silver", "centcom", "ert", "ert-leader", "syndicate", "syndicate-command", "clown", "mime") // List of overlays in pda.dmi
ADD_TO_GLOBAL_LIST(/obj/item/device/pda, PDAs)
//The advanced pea-green monochrome lcd of tomorrow.

/obj/item/device/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = SIZE_TINY
	slot_flags = SLOT_FLAGS_ID | SLOT_FLAGS_BELT

	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/datum/data/pda/app/current_app = null
	var/datum/data/pda/app/lastapp = null

	var/default_pen = /obj/item/weapon/pen
	var/obj/item/weapon/pen/pen = null

	var/datum/data/pda/utility/scanmode/scanmode
	var/silent = FALSE //To beep or not to beep, that is the question
	var/ttone = "beep" //The PDA ringtone!

	var/pda_paymod = null

	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/detonate = TRUE // Can the PDA be blown up?

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above
	var/ownrank = null // this one is rank, never alt title

	var/list/programs = list(
		new/datum/data/pda/app/main_menu,
		new/datum/data/pda/app/notekeeper,
		new/datum/data/pda/app/messenger,
		new/datum/data/pda/app/manifest,
		new/datum/data/pda/app/nanobank,
		new/datum/data/pda/app/atmos_scanner,
		new/datum/data/pda/utility/flashlight)

	var/list/shortcut_cache = list()
	var/list/shortcut_cat_order = list()
	var/list/notifying_programs = list()

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device

	item_action_types = list(/datum/action/item_action/hands_free/toggle_pda_light)

	var/datum/music_player/chiptune_player
	var/ringtone_name = "Unknown"

/obj/item/device/pda/proc/click_to_pay()
	return

/datum/action/item_action/hands_free/toggle_pda_light
	name = "Toggle light"

/datum/action/item_action/hands_free/toggle_pda_light/Activate()
	var/obj/item/device/pda/P = target
	var/datum/data/pda/utility/flashlight/F = P.find_program(/datum/data/pda/utility/flashlight)
	if(!F)
		return
	F.start(owner)

/obj/item/device/pda/atom_init()
	. = ..()
	global.PDAs = sortAtom(global.PDAs)
	if(default_cartridge)
		cartridge = new default_cartridge(src)
		cartridge.update_programs(src)
	if(default_pen)
		pen = new default_pen(src)

	update_programs()
	start_program(find_program(/datum/data/pda/app/main_menu))

	chiptune_player = new(src, "sound/musical_instruments/pda")

	set_ringtone(pick(ringtones_by_names))

/obj/item/device/pda/Destroy()
	if (id)
		if (prob(90)) //IDs are kept in 90% of the cases
			id.forceMove(get_turf(loc))
			id = null
		else
			QDEL_NULL(id)
	QDEL_NULL(pen)
	QDEL_NULL(cartridge)
	QDEL_NULL(chiptune_player)

	QDEL_LIST(programs)
	return ..()

/obj/item/device/pda/unable_to_play(mob/living/user)
	return FALSE

/obj/item/device/pda/examine(mob/user)
	..()
	if(src in user)
		if (SSshuttle.online)
			to_chat(user, "The time [worldtime2text()] and shuttle ETA [shuttleeta2text()] are displayed in the corner of the screen.")
		else
			to_chat(user, "The time [worldtime2text()] is displayed in the corner of the screen.")

/obj/item/device/pda/AltClick(mob/user)
	if (can_use(user) && id)
		remove_id(user)

/obj/item/device/pda/CtrlClick(mob/user)
	if (can_use(user))
		remove_pen(user)
		return

	return ..()

/obj/item/device/pda/proc/assign(real_name)
	if(!istext(real_name))
		stack_trace("Expected text, got reference")
		real_name = "[real_name]"

	owner = real_name
	name = "PDA-[real_name][ownjob ? " ([ownjob])" : ""]"

/obj/item/device/pda/proc/start_program(datum/data/pda/P, mob/user)
	if(P && ((P in programs) || (cartridge && (P in cartridge.programs))))
		. = P.start(user)
		update_static_data(user)
		return
	return FALSE

/obj/item/device/pda/proc/find_program_by_name(name)
	if(!name)
		return null
	for(var/datum/data/pda/P as anything in programs)
		if(P.name == name)
			return P
	for(var/datum/data/pda/P as anything in cartridge.programs)
		if(P.name == name)
			return P
	return null


/obj/item/device/pda/proc/find_program(type)
	var/datum/data/pda/A = locate(type) in programs
	if(A)
		return A
	if(cartridge)
		A = locate(type) in cartridge.programs
		if(A)
			return A
	return null

/obj/item/device/pda/proc/update_shortcuts()
	shortcut_cache.Cut()

/obj/item/device/pda/proc/update_programs()
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.pda = src

/*
 *	The Actual PDA
 */

/obj/item/device/pda/proc/can_use()

	if(!ismob(loc))
		return FALSE

	var/mob/M = loc
	if(M.incapacitated())
		return FALSE
	return TRUE

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	. = ..()
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && can_use())
		return attack_self(M)
	return

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user)
	if(active_uplink_check(user))
		return

	ui_interact(user) //NanoUI requires this proc
	stop_ringtone()
	return

/obj/item/device/pda/update_icon()
	..()

	cut_overlays()
	if(notifying_programs.len)
		add_overlay(image('icons/obj/pda.dmi', "pda-r"))
	if(id)
		var/id_overlay = get_id_overlay(id)
		if(id_overlay)
			add_overlay(image('icons/obj/pda.dmi', id_overlay))

/obj/item/device/pda/proc/get_id_overlay(obj/item/weapon/card/id/I)
	if(!I)
		return
	if(I.icon_state in ALLOWED_ID_OVERLAYS)
		return I.icon_state
	return "id"

/obj/item/device/pda/proc/remove_id(mob/user)
	if(issilicon(user))
		return

	if (can_use(user))
		if (id)
			if (loc == user)
				user.put_in_hands(id)
			else
				id.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You remove the ID from the [name].</span>")
			id = null
			update_icon()
		else
			to_chat(user, "<span class='notice'>This PDA does not have an ID in it.</span>")
	else
		to_chat(user, "<span class='notice'>You cannot do this while restrained.</span>")

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_id == src)
			H.sec_hud_set_ID()

/obj/item/device/pda/proc/remove_pen(mob/user)
	if(issilicon(user))
		return

	if (can_use(user))
		if(pen)
			if (loc == user)
				user.put_in_hands(pen)
				playsound(src, 'sound/items/penclick.ogg', VOL_EFFECTS_MASTER, 20)
			else
				pen.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You remove \the [pen] from \the [src].</span>")
			pen = null
		else
			to_chat(user, "<span class='notice'>This PDA does not have a pen in it.</span>")
	else
		to_chat(user, "<span class='notice'>You cannot do this while restrained.</span>")


/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	remove_id(usr)

/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	remove_pen(usr)

/obj/item/device/pda/proc/id_check(mob/user, choice)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				user.drop_from_inventory(I, src)
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_from_inventory(I, src)
			id = I
			user.put_in_hands(old_id)
	update_icon()
	return

// access to status display signals
/obj/item/device/pda/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/cartridge) && !cartridge)
		cartridge = I
		user.drop_from_inventory(I, src)
		to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
		cartridge.update_programs(src)
		update_shortcuts()
		SStgui.update_uis(src) // update all UIs attached to src

	else if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = I
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			ownjob = idcard.assignment
			assign(idcard.registered_name)
			ownrank = idcard.rank
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//Basic safety check. If card is held by user and PDA is near user or in user's hand.
			if(idcard.loc == user)
				id_check(user, 2)
				to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.</span>")
				if(ishuman(loc))
					var/mob/living/carbon/human/human_wearer = loc
					if(human_wearer.wear_id == src)
						human_wearer.sec_hud_set_ID()
			return	//Return in case of failed check or when successful.
	else if(istype(I, /obj/item/device/paicard) && !pai)
		user.drop_from_inventory(I, src)
		pai = I
		to_chat(user, "<span class='notice'>You slot \the [I] into [src].</span>")
		SStgui.update_uis(src) // update all UIs attached to src
	else if(istype(I, /obj/item/weapon/pen))
		if(pen)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			pen = I
			user.drop_from_inventory(I, src)
			to_chat(user, "<span class='notice'>You slide \the [I] into \the [src].</span>")
	else
		return ..()

/obj/item/device/pda/proc/detonate_act(obj/item/device/pda/P)
	//TODO: sometimes these attacks show up on the message server
	var/i = rand(1,100)
	var/j = rand(0,1) //Possibility of losing the PDA after the detonation
	var/message = ""
	var/mob/living/M = null
	if(ismob(P.loc))
		M = P.loc

	//switch(i) //Yes, the overlapping cases are intended.
	if(i<=10) //The traditional explosion
		P.explode()
		j=1
		message += "Your [P] suddenly explodes!"
	if(i>=10 && i<= 20) //The PDA burns a hole in the holder.
		j=1
		if(M && isliving(M))
			M.apply_damage( rand(30,60) , BURN)
		message += "You feel a searing heat! Your [P] is burning!"
	if(i>=20 && i<=25) //EMP
		empulse(P.loc, 3, 6, 1)
		message += "Your [P] emits a wave of electromagnetic energy!"
	if(i>=25 && i<=40) //Smoke
		var/datum/effect/effect/system/smoke_spread/S = new /datum/effect/effect/system/smoke_spread
		S.attach(P.loc)
		S.set_up(n = 10, c = 0, loca = P.loc, direct = 0)
		playsound(P, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
		S.start()
		message += "Large clouds of smoke billow forth from your [P]!"
	if(i>=40 && i<=45) //Bad smoke
		var/datum/effect/effect/system/smoke_spread/bad/B = new /datum/effect/effect/system/smoke_spread/bad
		B.attach(P.loc)
		B.set_up(n = 10, c = 0, loca = P.loc, direct = 0)
		playsound(P, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
		B.start()
		message += "Large clouds of noxious smoke billow forth from your [P]!"
	if(i>=65 && i<=75) //Weaken
		if(M && isliving(M))
			M.apply_effects(0,1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=75 && i<=85) //Stun and stutter
		if(M && isliving(M))
			M.apply_effects(1,0,0,0,1)
		message += "Your [P] flashes with a blinding white light! You feel weaker."
	if(i>=85) //Sparks
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(n = 2, c = 1, loca = P.loc)
		s.start()
		message += "Your [P] begins to spark violently!"
	if(i>45 && i<65 && prob(50)) //Nothing happens
		message += "Your [P] bleeps loudly."
		j = prob(10)

	if(j) //This kills the PDA
		if(message)
			message += "It melts in a puddle of plastic."
		else
			message += "Your [P] shatters in a thousand pieces!"
		qdel(P)

	if(M && isliving(M))
		message = "<span class='warning'></span>" + message
		M.show_message(message, SHOWMSG_ALWAYS) //vas visual only before, it's important message so I changed this. You can add more different messages

/obj/item/device/pda/attack(mob/living/L, mob/living/user)
	if(iscarbon(L) && scanmode)
		scanmode.scan_mob(L, user)

/obj/item/device/pda/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(scanmode)
		scanmode.scan_atom(target, user)
	if(!scanmode && istype(target, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = target
		var/datum/data/pda/app/notekeeper/note = find_program(/datum/data/pda/app/notekeeper)
		if(note)
			note = P.info
			to_chat(user, "<span class='notice'>Paper scanned.</span>")//concept of scanning paper copyright brainoblivion 2009

/obj/item/device/pda/get_current_temperature()
	. = 5
	if(detonate)
		. += 10

/obj/item/device/pda/process()
	if(current_app)
		current_app.program_process()

/obj/item/device/pda/proc/explode() //This needs tuning. //Sure did.
	if(!detonate) return
	var/turf/T = get_turf(loc)
	if(T)
		T.hotspot_expose(700,125)
		explosion(T, 0, 0, 1, rand(1,2))
	return

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emplode(severity)

/obj/item/device/pda/proc/check_pda_server()
	if(!global.message_servers)
		return
	for (var/obj/machinery/message_server/MS in global.message_servers)
		if(MS.active)
			var/turf/pos = get_turf(src)
			return is_station_level(pos.z)

/obj/item/device/pda/proc/play_ringtone(ignore_presence = FALSE)
	if(!ignore_presence)
		var/mob/user = usr
		if(nanomanager.get_open_ui(user, src, "main"))
			return

	if(chiptune_player.playing)
		return

	chiptune_player.playing = TRUE
	INVOKE_ASYNC(chiptune_player, TYPE_PROC_REF(/datum/music_player, playsong), null)

/obj/item/device/pda/proc/stop_ringtone()
	chiptune_player.playing = FALSE

/obj/item/device/pda/proc/set_ringtone(ringtone, melody = null)
	if(!ringtone)
		return
	stop_ringtone()

	ringtone_name = ringtone
	if(ringtone == CUSTOM_RINGTONE_NAME)
		if(!melody)
			return

		chiptune_player.repeat = 1
		chiptune_player.parse_song_text(melody)
	else
		var/datum/ringtone/Ring = global.ringtones_by_names[ringtone]
		if(!Ring)
			return
		chiptune_player.repeat = Ring.replays
		chiptune_player.parse_song_text(Ring.melody)

	SStgui.update_uis(src)

#undef TRANSCATION_COOLDOWN
