/datum/data/pda/app/status_display
	name = "Status Display"
	icon = "list-alt"
	template = "pda_status_display"
	category = "Utilities"

	var/message1	// used for status_displays
	var/message2

/datum/data/pda/app/status_display/app_data(mob/user as mob, list/data)
	data["records"] = list(
		"message1" = message1 ? message1 : "(none)",
		"message2" = message2 ? message2 : "(none)")

/datum/data/pda/app/status_display/proc/post_status(command, data1, data2, mob/user)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)
	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			if(user)
				log_admin("STATUS: [key_name(user)] set status screen with [pda]. Message: [data1] [data2]")
				message_admins("STATUS: [key_name_admin(user)] set status screen with [pda]. Message: [data1] [data2] [ADMIN_FLW(user)]")
			else
				var/turf/PDA_turf = get_turf(pda)
				log_admin("STATUS: UNKNOWN set status screen with [pda]. Message: [data1] [data2]")
				message_admins("STATUS: UNKNOWN set status screen with [pda]. Message: [data1] [data2] [pda.loc ? "[ADMIN_JMP(PDA_turf)]" : ""] ")

		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)

/datum/data/pda/app/status_display/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return


	. = TRUE
	switch(action)
		if("SetMessage")
			if(params["msgnum"])
				switch(params["msgnum"])
					if(1)
						message1 = input("Line 1", "Enter Message Text", message1) as text|null
						if(!message1)
							return
					if(2)
						message2 = input("Line 2", "Enter Message Text", message2) as text|null
						if(!message2)
							return

		if("Status")
			switch(params["statdisp"])
				if("message")
					post_status("message", message1, message2, user = usr)

				if("alert")
					post_status("alert", params["alert"], user = usr)

/datum/data/pda/app/signaller
	name = "Signaler System"
	icon = "rss"
	template = "pda_signaler"
	category = "Utilities"

/datum/data/pda/app/signaller/app_data(mob/user as mob, list/data)
	if(pda?.cartridge?.integ_signaler)
		var/obj/item/radio/integrated/signal/S = pda.cartridge.integ_signaler // Simpler access
		data["frequency"] = S.frequency
		data["code"] = S.code
		data["minFrequency"] = PUBLIC_LOW_FREQ
		data["maxFrequency"] = PUBLIC_HIGH_FREQ

/datum/data/pda/app/signaller/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	. = TRUE

	if(pda?.cartridge?.integ_signaler)
		var/obj/item/radio/integrated/signal/S = pda.cartridge.integ_signaler // Simpler access

		switch(action)
			if("signal")
				S.send_signal()

			if("freq")
				S.frequency = sanitize_frequency(text2num(params["freq"]) * 10)

			if("code")
				S.code = clamp(text2num(params["code"]), 1, 100)

/*
/datum/data/pda/app/power
	name = "Power Monitor"
	icon = "bolt"
	template = "pda_power"
	category = "Engineering"
	update = PDA_APP_UPDATE_SLOW

	var/datum/ui_module/power_monitor/digital/pm = new

/datum/data/pda/app/power/app_data(mob/user as mob, list/data)
	data.Add(pm.ui_data())

// All 4 args are important here because proxying matters
/datum/data/pda/app/power/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE
	// Observe
	pm.tgui_act(action, params, ui, state)
*/

/datum/data/pda/app/crew_records
	var/datum/data/record/general_records = null

/datum/data/pda/app/crew_records/app_data(mob/user as mob, list/data)
	var/list/records = list()

	if(general_records && (general_records in global.data_core.general))
		data["records"] = records
		records["general"] = general_records.fields
		return records
	else
		for(var/A in sortRecord(global.data_core.general))
			var/datum/data/record/R = A
			if(R)
				records += list(list(Name = R.fields["name"], "ref" = REF(R)))
		data["recordsList"] = records
		data["records"] = null
		return null

/datum/data/pda/app/crew_records/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("Records")
			var/datum/data/record/R = locate(params["target"])
			if(R)
				load_records(R)
			return
		if("Back")
			general_records = null
			has_back = FALSE
			return

/datum/data/pda/app/crew_records/proc/load_records(datum/data/record/R)
	general_records = R
	has_back = TRUE

/datum/data/pda/app/crew_records/medical
	name = "Medical Records"
	icon = "heartbeat"
	template = "pda_medical"
	category = "Medical"

	var/datum/data/record/medical_records = null

/datum/data/pda/app/crew_records/medical/app_data(mob/user as mob, list/data)
	var/list/records = ..()
	if(!records)
		return

	if(medical_records && (medical_records in global.data_core.medical))
		records["medical"] = medical_records.fields

	return records

/datum/data/pda/app/crew_records/medical/load_records(datum/data/record/R)
	..(R)
	for(var/A in global.data_core.medical)
		var/datum/data/record/E = A
		if(E && (E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
			medical_records = E
			break

/datum/data/pda/app/crew_records/security
	name = "Security Records"
	icon = "id-badge"
	template = "pda_security"
	category = "Security"

	var/datum/data/record/security_records = null

/datum/data/pda/app/crew_records/security/app_data(mob/user as mob, list/data)
	var/list/records = ..()
	if(!records)
		return

	if(security_records && (security_records in global.data_core.security))
		records["security"] = security_records.fields

	return records

/datum/data/pda/app/crew_records/security/load_records(datum/data/record/R)
	..(R)
	for(var/A in global.data_core.security)
		var/datum/data/record/E = A
		if(E && (E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
			security_records = E
			break
/*
/datum/data/pda/app/secbot_control
	name = "Security Bot Access"
	icon = "rss"
	template = "pda_secbot"
	category = "Security"

	var/active_uid = null

/datum/data/pda/app/secbot_control/app_data(mob/user as mob, list/data)
	var/list/botsData = list()
	var/list/beepskyData = list()

	var/mob/living/simple_animal/bot/secbot/active_bot = locateUID(active_uid)

	if(active_bot && !QDELETED(active_bot))
		beepskyData["active"] = active_bot ? sanitize(active_bot.name) : null
		has_back = !!active_bot
		if(active_bot && !isnull(active_bot.mode))
			var/area/loca = get_area(active_bot)
			var/loca_name = sanitize(loca.name)
			beepskyData["botstatus"] = list("loca" = loca_name, "mode" = active_bot.mode)

	else
		var/botsCount = 0
		var/list/mob/living/simple_animal/bot/bots = list()
		for(var/mob/living/simple_animal/bot/secbot/SB in global.bots_list)
			bots += SB
		for(var/mob/living/simple_animal/bot/ed209/ED in global.bots_list)
			if(!("syndicate" in ED.faction))
				bots += ED

		for(var/mob/living/simple_animal/bot/B in bots)
			botsCount++
			if(B.loc)
				botsData[++botsData.len] = list("Name" = sanitize(B.name), "Location" = sanitize(get_area(B).name), "uid" = "[B.UID()]")

		if(!length(botsData))
			botsData[++botsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "uid"= null)

		beepskyData["bots"] = botsData
		beepskyData["count"] = botsCount

	data["beepsky"] = beepskyData

/datum/data/pda/app/secbot_control/tgui_act(action, list/params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE

	switch(action)
		if("control")
			active_uid = params["bot"]

		if("botlist", "Back") // "Back" is part of the PDA TGUI itself.
			active_uid = null

		if("stop", "go", "home")
			var/mob/living/simple_animal/bot/active_bot = locateUID(active_uid)
			if(active_bot && !QDELETED(active_bot))
				active_bot.handle_command(usr, action)
			else
				active_uid = null

		if("summon")
			var/mob/living/simple_animal/bot/active_bot = locateUID(active_uid)
			if(active_bot && !QDELETED(active_bot))
				active_bot.handle_command(usr, "summon", list("target" = get_turf(usr), "useraccess" = usr.get_access()))
			else
				active_uid = null
*/
/*
/datum/data/pda/app/mule_control
	name = "Delivery Bot Control"
	icon = "truck"
	template = "pda_mule"
	category = "Quartermaster"

	var/active_uid = null

/datum/data/pda/app/mule_control/app_data(mob/user as mob, list/data)
	var/list/muleData = list()
	var/list/mulebotsData = list()

	var/obj/machinery/bot/mulebot/active_bot = locateUID(active_uid)

	if(active_bot && !QDELETED(active_bot))
		muleData["active"] = active_bot ? sanitize(active_bot.name) : null
		has_back = !!active_bot
		if(active_bot && !isnull(active_bot.mode))
			var/area/loca = get_area(active_bot)
			var/loca_name = sanitize(loca.name)
			muleData["botstatus"] =  list(
				"loca" = loca_name,
				"mode" = active_bot.mode,
				"home" = active_bot.home_destination,
				"powr" = (active_bot.cell ? active_bot.cell.percent() : 0),
				"retn" = active_bot.auto_return,
				"pick" = active_bot.auto_pickup,
				"load" = active_bot.load,
				"dest" = sanitize(active_bot.destination)
			)

	else
		var/mulebotsCount = 0
		for(var/obj/machinery/bot/mulebot/B in global.bots_list)
			mulebotsCount++
			if(B.loc)
				mulebotsData[++mulebotsData.len] = list("Name" = sanitize(B.name), "Location" = get_area(B).name, "uid" = "[B.UID()]")

		if(!mulebotsData.len)
			mulebotsData[++mulebotsData.len] = list("Name" = "No bots found", "Location" = "Invalid", "uid"= null)

		muleData["bots"] = mulebotsData
		muleData["count"] = mulebotsCount

	data["mulebot"] = muleData

/datum/data/pda/app/mule_control/tgui_act(action, list/params)
	if(..())
		return

	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

	. = TRUE

	switch(action)
		if("control")
			active_uid = params["bot"]

		if("botlist", "Back") // "Back" is part of the PDA TGUI itself.
			active_uid = null

		if("stop", "start", "home", "unload", "target")
			var/mob/living/simple_animal/bot/active_bot = locateUID(active_uid)
			if(active_bot && !QDELETED(active_bot))
				active_bot.handle_command(usr, action)
			else
				active_uid = null

		if("set_auto_return", "set_pickup_type")
			var/mob/living/simple_animal/bot/active_bot = locateUID(active_uid)
			if(active_bot && !QDELETED(active_bot))
				active_bot.handle_command(usr, action, params)
			else
				active_uid = null
*/

/datum/data/pda/app/supply
	name = "Supply Records"
	icon = "archive"
	template = "pda_supplyrecords"
	category = "Quartermaster"

/datum/data/pda/app/supply/app_data(mob/user as mob, list/data)
	var/list/supplyData = list()

	if(SSshuttle.moving)
		supplyData["shuttle_moving"] = 1

	if(SSshuttle.at_station)
		supplyData["shuttle_loc"] = "Station"
	else
		supplyData["shuttle_loc"] = "CentCom"

	supplyData["shuttle_time"] = "([SSshuttle.eta] Mins)"

	var/supplyOrderCount = 0
	var/list/supplyOrderData = list()
	for(var/S in SSshuttle.shoppinglist)
		var/datum/supply_order/SO = S
		supplyOrderCount++
		supplyOrderData[++supplyOrderData.len] = list("Number" = SO.id, "Name" = html_encode(SO.object.name), "ApprovedBy" = SO.orderer, "Comment" = html_encode(SO.reason))

	if(!supplyOrderData.len)
		supplyOrderData[++supplyOrderData.len] = list("Number" = null, "Name" = null, "OrderedBy"=null)

	supplyData["approved"] = supplyOrderData
	supplyData["approved_count"] = supplyOrderCount

	var/requestCount = 0
	var/list/requestData = list()
	for(var/S in SSshuttle.requestlist)
		var/datum/supply_order/SO = S
		requestCount++
		requestData[++requestData.len] = list("Number" = SO.id, "Name" = html_encode(SO.object.name), "OrderedBy" = SO.orderer, "Comment" = html_encode(SO.reason))

	if(!requestData.len)
		requestData[++requestData.len] = list("Number" = null, "Name" = null, "orderedBy" = null, "Comment" = null)

	supplyData["requests"] = requestData
	supplyData["requests_count"] = requestCount

	data["supply"] = supplyData

/datum/data/pda/app/janitor
	name = "Custodial Locator"
	icon = "trash"
	template = "pda_janitor"
	category = "Utilities"

/datum/data/pda/app/janitor/app_data(mob/user as mob, list/data)
	var/list/JaniData = list()
	var/turf/cl = get_turf(pda)

	if(cl)
		JaniData["user_loc"] = list("x" = cl.x, "y" = cl.y)
	else
		JaniData["user_loc"] = list("x" = 0, "y" = 0)

	var/list/MopData = list()
	for(var/obj/item/weapon/mop/M in global.janitorial_equipment)
		var/turf/ml = get_turf(M)
		if(ml)
			if(ml.z != cl.z)
				continue
			var/direction = get_dir(pda, M)
			MopData[++MopData.len] = list ("x" = ml.x, "y" = ml.y, "dir" = uppertext(dir2text(direction)), "status" = M.reagents.total_volume ? "Wet" : "Dry")

	var/list/BucketData = list()
	for(var/obj/structure/mopbucket/B in global.janitorial_equipment)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			BucketData[++BucketData.len] = list ("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "volume" = B.reagents.total_volume, "max_volume" = B.reagents.maximum_volume)

	var/list/CbotData = list()
	for(var/obj/machinery/bot/cleanbot/B in global.bots_list)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			CbotData[++CbotData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "status" = B.on ? "Online" : "Offline")

	var/list/CartData = list()
	for(var/obj/structure/stool/bed/chair/janitorialcart/B in global.janitorial_equipment)
		var/turf/bl = get_turf(B)
		if(bl)
			if(bl.z != cl.z)
				continue
			var/direction = get_dir(pda,B)
			CartData[++CartData.len] = list("x" = bl.x, "y" = bl.y, "dir" = uppertext(dir2text(direction)), "volume" = B.reagents.total_volume, "max_volume" = B.reagents.maximum_volume)

	JaniData["mops"] = MopData.len ? MopData : null
	JaniData["buckets"] = BucketData.len ? BucketData : null
	JaniData["cleanbots"] = CbotData.len ? CbotData : null
	JaniData["carts"] = CartData.len ? CartData : null
	data["janitor"] = JaniData
