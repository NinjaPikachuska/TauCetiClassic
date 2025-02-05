/datum/data/pda/app/messenger
	name = "Messenger"
	icon = "comments-o"
	notify_icon = "comments"
	title = "SpaceMessenger V4.1.0"
	template = "pda_messenger"
	var/toff = 0 //If 1, messenger disabled
	var/search_target               // Just for message button in manifest
	var/m_hidden = 0                // Is the PDA hidden from the PDA list?
	var/datum/pda_chat/active_chat  // Current chat
	var/list/chats = list()         // For keeping up with who we have PDA messsages from.
	COOLDOWN_DECLARE(last_text)

/datum/data/pda/app/messenger/Destroy()
	QDEL_LIST_ASSOC_VAL(chats)
	. = ..()

/datum/data/pda/app/messenger/stop()
	. = ..()
	search_target = null
	active_chat = null

/datum/data/pda/app/messenger/unnotify()
	for(var/chat_ref in chats)
		var/datum/pda_chat/PC = chats[chat_ref]
		if(PC.has_unread)
			return
	..()

/datum/data/pda/app/messenger/app_static_data(mob/user, list/data)
	data["last_chats"] = get_last_chats_data()
	data["available_chats"] = get_available_chats_data()
	data["current_chat"] = list()
	if(active_chat)
		data["current_chat"] = active_chat.get_ui_data()

/datum/data/pda/app/messenger/app_data(mob/user, list/data)
	data["silent"] = pda.silent
	data["toff"] = toff
	data["searchTarget"] = search_target

	has_back = !!active_chat

	var/list/plugins = list()
	if(pda.cartridge)
		for(var/A in pda.cartridge.messenger_plugins)
			var/datum/data/pda/messenger_plugin/P = A
			plugins += list(list(name = P.name, icon = P.icon, ref = "[REF(P)]"))
	data["plugins"] = plugins

	data["charges"] = pda.cartridge ? pda.cartridge.charges : 0

	data["ringtone"] = pda.ringtone_name
	data["ringtone_list"] = global.ringtones_by_names

/datum/data/pda/app/messenger/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("Toggle Messenger")
			toff = !toff

		if("Toggle Ringer")
			pda.silent = !pda.silent

		if("Clear")
			if(params["option"] == "All")
				QDEL_LIST_ASSOC_VAL(chats)
				update_static_data(ui.user, ui)
			if(params["option"] == "Convo")
				remove_chat(active_chat)
			unnotify()

		if("Message")
			var/message = sanitize(params["message"])
			if(!message)
				return

			var/datum/pda_chat/PC = active_chat
			var/obj/item/device/pda/P = PC?.recipient?.resolve()
			if(!P)
				return

			create_message(usr, P, message)

		if("Select Chat")
			var/P = params["target"]
			if(!P)
				return

			var/datum/pda_chat/PC = chats[P]
			if(!PC)
				return

			open_chat(PC, ui)

		if("Create Chat")
			var/P = params["target"]
			if(!P)
				return

			var/datum/pda_chat/PC = find_chat_by_recipient(P)
			if(PC)
				open_chat(PC, ui)
				return

			var/obj/item/device/pda/pda = locate(P)
			if(!istype(pda))
				return

			var/datum/data/pda/app/messenger/PM = pda.find_program(/datum/data/pda/app/messenger)
			if(!PM || !PM.can_receive())
				return

			active_chat = create_chat(pda)
			update_static_data(ui.user, ui)

		if("Messenger Plugin")
			if(!params["target"] || !params["plugin"])
				return

			var/obj/item/device/pda/P = locate(params["target"])
			if(!istype(P))
				var/datum/pda_chat/PC = chats[params["target"]]
				P = PC?.recipient?.resolve()

			if(!P)
				to_chat(usr, "PDA not found.")
				return

			var/datum/data/pda/messenger_plugin/plugin = locate(params["plugin"])
			if(plugin && (plugin in pda.cartridge.messenger_plugins))
				plugin.messenger = src
				plugin.user_act(usr, P)

			update_static_data(ui.user, ui)

		if("Back")
			active_chat = null
			update_static_data(ui.user, ui)

		if("Search Target Clear")
			search_target = null

/datum/data/pda/app/messenger/proc/create_message(mob/living/U, obj/item/device/pda/P, message = null)
	if(!message)
		message = sanitize(input(U, "Please enter message", name, null) as text|null)

	if(!message || !istype(P))
		return FALSE

	if(!in_range(pda, U) && pda.loc != U)
		return FALSE

	var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)
	if(!PM || PM.toff || toff || !P.owner)
		return FALSE

	var/datum/pda_chat/chat = find_chat_by_recipient(REF(P))
	if(PM.m_hidden && !chat)
		return FALSE

	if(!COOLDOWN_FINISHED(src, last_text))
		return FALSE

	if(!pda.can_use())
		return FALSE

	COOLDOWN_START(src, last_text, 3 SECONDS)

	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, message)
	var/obj/machinery/message_server/useMS = null
	if(global.message_servers)
		for(var/A in global.message_servers)
			var/obj/machinery/message_server/MS = A
		//PDAs are now dependent on the Message Server.
			if(MS.active)
				useMS = MS
				break

	if(!useMS) // only send the message if its going to work
		to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")
		return FALSE

	useMS.send_pda_message("[P.owner]","[pda.owner]","[message]")

	// Show it to ghosts
	for(var/mob/dead/observer/M in global.dead_mob_list)
		if(M.client?.prefs.toggles & CHAT_GHOSTEARS)
			var/ghost_message = "<span class='name'>[pda.owner]</span> ([FOLLOW_LINK(M, pda)]) <span class='game say'>PDA Message</span> --> <span class='name'>[P.owner]</span> ([FOLLOW_LINK(M, P)]): <span class='message emojify linkify'>[message]</span>"
			to_chat(M, "[ghost_message]")

	var/datum/pda_message/message_from = new(message, TRUE, worldtime2text())
	add_message(message_from, P)

	var/datum/pda_message/message_to = new(message, FALSE, worldtime2text())
	PM.add_message(message_to, pda)

	SStgui.update_uis(src)
	PM.notify("<b>Message from [pda.owner] ([pda.ownjob]), </b>\"<span class='message emojify linkify'>[message]</span>\" (<a href='?src=[REF(PM)];choice=Message;target=[REF(pda)]'>Reply</a>)")
	log_pda("(PDA: [name]) sent \"[message]\" to [P.name]", U)

	return TRUE

/datum/data/pda/app/messenger/proc/add_message(datum/pda_message/message, obj/item/device/pda/P, fake_name = "Unknown", fake_job = "Unknown")
	var/datum/pda_chat/chat
	if(P)
		chat = find_chat_by_recipient(REF(P))
	else
		chat = find_chat_by_recipient(fake_name, TRUE)
	if(!chat)
		chat = create_chat(P, fake_name, fake_job)
	if(!message.outgoing && chat != active_chat)
		chat.has_unread = TRUE
	chat.messages += message
	pda.update_static_data(usr)

/datum/data/pda/app/messenger/proc/create_chat(recipient, fake_name, fake_job)
	var/datum/pda_chat/new_chat = new(recipient)
	var/obj/item/device/pda/P = recipient

	new_chat.cached_name = istype(P) ? P.owner : fake_name
	new_chat.cached_job = istype(P) ? P.ownjob : fake_job

	chats[REF(new_chat)] = new_chat

	return new_chat

/datum/data/pda/app/messenger/proc/remove_chat(datum/pda_chat/chat)
	if(!istype(chat))
		chat = chats[chat]

	if(!istype(chat))
		return

	if(chat == active_chat)
		active_chat = null

	chats.Remove(REF(chat))
	qdel(chat)
	pda.update_static_data(usr)

/datum/data/pda/app/messenger/proc/open_chat(datum/pda_chat/PC, datum/tgui/ui)
	PC.has_unread = FALSE
	unnotify()
	active_chat = PC
	update_static_data(ui.user, ui)

/datum/data/pda/app/messenger/proc/find_chat_by_recipient(recipient, fake_user = FALSE)
	for(var/chat_ref in chats)
		var/datum/pda_chat/chat = chats[chat_ref]
		if(fake_user && chat.cached_name == recipient)
			return chat
		else if(chat.recipient?.reference == recipient)
			return chat
	return null

/datum/data/pda/app/messenger/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if(toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for(var/obj/item/device/pda/P as anything in global.PDAs)
		var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

		if(!PM || !PM.can_receive() || P == pda )
			continue

		var/name = P.owner
		if(name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist

/datum/data/pda/app/messenger/proc/get_available_chats_data()
	var/list/chats_data = list()

	for(var/obj/item/device/pda/P as anything in global.PDAs)
		var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

		if(P == pda || !PM || !PM.can_receive())
			continue

		var/list/data = list()
		data["name"] = P.owner
		data["job"] = P.ownjob
		data["has_unread"] = FALSE
		data["ref"] = REF(P)
		chats_data += list(data)

	return chats_data

/datum/data/pda/app/messenger/proc/get_last_chats_data()
	var/list/data = list()

	for(var/chat_ref in chats)
		var/datum/pda_chat/PC = chats[chat_ref]

		var/list/chat_data = list()
		chat_data["name"] = PC.get_recipient_name()
		chat_data["job"] = PC.get_recipient_job()
		chat_data["has_unread"] = PC.has_unread
		chat_data["ref"] = REF(PC)
		data += list(chat_data)

	return data

/datum/data/pda/app/messenger/proc/can_receive()
	return pda.owner && !toff && !m_hidden

// Handler for the in-chat reply button
/datum/data/pda/app/messenger/Topic(href, href_list)
	if(!pda.can_use())
		return
	if(href_list["choice"] != "Message")
		return
	var/obj/item/device/pda/P = locate(href_list["target"])
	if(!create_message(usr, P))
		return
	var/datum/pda_chat/PC = find_chat_by_recipient(href_list["target"])
	if(!PC)
		return
	PC.has_unread = FALSE
	unnotify()
	active_chat = PC
	pda.update_static_data(usr)

/datum/pda_chat
	var/cached_name = "Unknown"
	var/cached_job = "Unknown"
	var/has_unread = FALSE
	var/datum/weakref/recipient = null
	var/list/datum/pda_message/messages = list()

/datum/pda_chat/New(obj/item/device/pda/recipient)
	src.recipient = WEAKREF(recipient)

/datum/pda_chat/Destroy(force, ...)
	QDEL_LIST(messages)
	. = ..()

/datum/pda_chat/proc/get_ui_data(mob/user)
	var/list/data = list()

	data["name"] = get_recipient_name()
	data["job"] = get_recipient_job()
	data["has_unread"] = has_unread

	data["ref"] = REF(src)

	var/list/messages_data = list()
	for(var/datum/pda_message/message as anything in messages)
		messages_data += list(message.get_ui_data(user))
	data["messages"] = messages_data

	data["can_reply"] = TRUE
	if(!recipient?.resolve())
		data["can_reply"] = FALSE

	return data

/datum/pda_chat/proc/get_recipient_name()
	var/obj/item/device/pda/P = recipient?.resolve()
	if(istype(P) && (P in global.PDAs))
		cached_name = P.owner
	return cached_name

/// Returns the messenger's job, caches the job in case the recipient becomes invalid later.
/datum/pda_chat/proc/get_recipient_job()
	var/obj/item/device/pda/P = recipient?.resolve()
	if(istype(P) && (P in global.PDAs))
		cached_job = P.ownjob
	return cached_job

/datum/pda_message
	var/message
	var/outgoing
	var/timestamp

/datum/pda_message/New(message, outgoing, timestamp)
	src.message = message
	src.outgoing = outgoing
	src.timestamp = timestamp

/datum/pda_message/proc/get_ui_data(mob/user)
	var/list/data = list()
	data["message"] = html_decode(message)
	data["outgoing"] = outgoing
	data["timestamp"] = timestamp
	return data
