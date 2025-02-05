// All the TGUI interactions are in their own file to keep things simpler

/obj/item/device/pda/tgui_state(mob/user)
	return global.inventory_state

/obj/item/device/pda/ui_interact(mob/user)
	tgui_interact(user)

/obj/item/device/pda/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PDA", name)
		ui.open()

/obj/item/device/pda/tgui_static_data(mob/user)
	var/list/data = list()

	current_app.app_static_data(user, data)

	return data

/obj/item/device/pda/tgui_data(mob/user)
	var/list/data = list()

	data["owner"] = owner
	data["ownjob"] = ownjob

	// update list of shortcuts, only if they changed
	if(!length(shortcut_cache))
		shortcut_cache = list()
		shortcut_cat_order = list()
		var/list/prog_list = programs.Copy()
		if(cartridge)
			prog_list |= cartridge.programs

		for(var/A in prog_list)
			var/datum/data/pda/P = A

			if(P.hidden)
				continue
			var/list/cat
			if(P.category in shortcut_cache)
				cat = shortcut_cache[P.category]
			else
				cat = list()
				shortcut_cache[P.category] = cat
				shortcut_cat_order += P.category
			cat |= list(list(name = P.name, icon = P.icon, notify_icon = P.notify_icon))

		// force the order of a few core categories
		shortcut_cat_order = list("General") \
			+ sortList(shortcut_cat_order - list("General", "Scanners", "Utilities")) \
			+ list("Scanners", "Utilities")

	data["idInserted"] = (id ? TRUE : FALSE)
	data["idLink"] = (id ? "[id.registered_name], [id.assignment]" : "--------")

	data["cartridge_name"] = cartridge ? cartridge.name : ""
	data["stationTime"] = worldtime2text()

	data["app"] = list()

	current_app.app_data(user, data)
	data["app"] |= list(
		"name" = current_app.title,
		"icon" = current_app.icon,
		"template" = current_app.template,
		"has_back" = current_app.has_back)

	return data

/obj/item/device/pda/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	add_fingerprint(ui.user)

	. = TRUE
	switch(action)
		if("Home") //Go home, largely replaces the old Return
			var/datum/data/pda/app/main_menu/A = find_program(/datum/data/pda/app/main_menu)
			if(A)
				start_program(A, ui.user)
		if("Refresh")
			update_static_data(ui.user, ui)
		if("StartProgram")
			if(params["program"])
				var/datum/data/pda/app/A = find_program_by_name(params["program"])
				if(A)
					start_program(A, ui.user)
		if("Eject")//Ejects the cart, only done from hub.
			if(!isnull(cartridge))
				var/turf/T = loc
				if(ismob(T))
					T = T.loc
				var/obj/item/weapon/cartridge/C = cartridge
				C.forceMove(T)
				if(scanmode in C.programs)
					scanmode = null
				if(current_app in C.programs)
					start_program(find_program(/datum/data/pda/app/main_menu, ui.user))
				for(var/datum/data/pda/P in notifying_programs)
					if(P in C.programs)
						P.unnotify()
				cartridge = null
				update_shortcuts()
		if("Authenticate") //Checks for ID
			id_check(ui.user, 1)
		if("Available_Ringtones")
			set_ringtone(params["selected_ringtone"])
			play_ringtone(ignore_presence = TRUE)
		if("Ringtone")
			var/t = sanitize(input(ui.user, "Введите новый рингтон") as message|null, MAX_CUSTOM_RINGTONE_LENGTH, extra = FALSE, ascii_only = TRUE)
			if (!t || !Adjacent(ui.user))
				return
			set_ringtone(CUSTOM_RINGTONE_NAME, t)
			play_ringtone(ignore_presence = TRUE)
		else
			if(current_app)
				. = current_app.tgui_act(action, params, ui, state) // It needs proxying through down here so apps actually have their interacts called

	if((honkamt > 0) && (prob(60))) //For clown virus.
		honkamt--
		playsound(src, 'sound/items/bikehorn.ogg', 30, TRUE)
