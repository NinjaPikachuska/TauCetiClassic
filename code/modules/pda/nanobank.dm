/datum/data/pda/app/nanobank
	name = "NanoBank"
	icon = "fas fa-university"
	notify_icon = "comments"
	title = "NanoBank 1.1"
	template = "pda_nanobank"


	var/login_fail_reason  //login failure reason for the interface
	var/logged_in = FALSE

	var/datum/money_account/selected_account

	var/datum/money_account/user_account
	var/datum/data/record/insurance_record

	COOLDOWN_DECLARE(transaction_cd)

/datum/data/pda/app/nanobank/start(mob/user)
	. = ..()
	if(!user || !user.mind)
		return

	if(!user_account)
		return

	if(!insurance_record)
		link_record(user_account.account_number)

	var/auto_pin_entry = user.mind.get_key_memory(MEM_ACCOUNT_PIN)
	if(!auto_pin_entry)
		return

	to_chat(user, "<span class='notice'>Вы вводите ПИН код по <a href=byond://?src=\ref[user.mind];key_memories=1>памяти</a>.</span>")
	attempt_login(auto_pin_entry, pda.id?.associated_account_number, user)

/datum/data/pda/app/nanobank/stop()
	logged_in = FALSE
	login_fail_reason = null
	. = ..()

/datum/data/pda/app/nanobank/Destroy()
	if(user_account)
		unlink_account()
	return ..()

/datum/data/pda/app/nanobank/app_static_data(mob/user, list/data)
	data["transaction_log"] = list()
	for(var/datum/transaction/T as anything in user_account.transaction_log)
		data["transaction_log"] += list(T.get_ui_data())

	data["available_accounts"] = get_available_account_data()

	var/list/subordinate_staff = my_subordinate_staff(pda.ownrank)
	data["subordinate_staff"] = subordinate_staff

	data["selected_account"] = list()
	if(selected_account)
		data["selected_account"] = selected_account.get_ui_data()

/datum/data/pda/app/nanobank/app_data(mob/user, list/data)
	data["has_id"] = !!pda.id
	data["id_name"] = pda.id ? "[pda.id.registered_name] ([pda.id.assignment])" : "--------"

	data["has_account"] = FALSE
	data["logged_in"] = logged_in
	data["login_fail_reason"] = login_fail_reason
	if(user_account)
		data["has_account"] = TRUE
		data["owner_name"] = user_account.owner_name
		data["owner_account_number"] = user_account.account_number
		data["money"] = user_account.money
		data["salary"] = user_account.owner_salary

		data["is_head"] = (pda.ownrank in global.heads_positions)

		data["insurances"] = list()
		data["changable_insurances"] = list()
		for(var/insurance in SSeconomy.insurance_prices)
			var/list/insurance_data = list(
				"name" = insurance,
				"price" = SSeconomy.insurance_prices[insurance],
				"price_with_time_addition" = SSeconomy.insurance_prices[insurance] != 0 ? \
				SSeconomy.insurance_prices[insurance] + INSURANCE_TIME_ADDITION : 0
			)
			data["insurances"] += list(insurance_data)
			if(insurance_data["price"] != 0)
				data["changable_insurances"] += list(insurance_data)

		data["owner_insurance_type"] = insurance_record ? insurance_record.fields["insurance_type"] : "error"
		data["owner_insurance_price"] = insurance_record ? SSeconomy.insurance_prices[insurance_record.fields["insurance_type"]] : "error"
		data["owner_preferred_insurance_type"] = user_account.owner_preferred_insurance_type
		data["owner_preferred_insurance_price"] = insurance_record ? \
		SSeconomy.insurance_prices[insurance_record.fields["insurance_type"]] : "error"
		data["owner_max_insurance_payment"] = user_account.owner_max_insurance_payment

		data["cartridge_insurance_access"] = pda.cartridge?.can_change_insurance_price ? TRUE : FALSE
		data["id_insurance_access"] = pda.id ? (access_cmo in pda.id.access) : FALSE

		data["insurance_price_change_default_cooldown"] = time2text(round(INSURANCE_PRICE_CHANGE_CD), "mm:ss")
		data["insurance_price_change_cooldown"] = time2text(round(global.insurance_price_change_cd - world.time), "mm:ss")
		data["is_insurance_price_change_on_cooldown"] = !COOLDOWN_FINISHED(global, insurance_price_change_cd)

		data["max_insurance_price"] = MAX_INSURANCE_PRICE

		data["security_level"] = user_account.security_level

	return data

/datum/data/pda/app/nanobank/tgui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	unnotify()
	var/mob/user = ui.user

	. = TRUE

	switch(action)
		if("link_account")
			var/card_account = pda.id?.associated_account_number
			var/tried_account_num = text2num(params["account_num"])
			var/tried_pin = text2num(params["account_pin"])
			try_link_account(tried_account_num, tried_pin, card_account, usr)

		if("unlink")
			unlink_account()

		if("switch_id")
			pda.id_check(usr, choice = 1)

	if(!user_account)
		return

	switch(action)
		if("login")
			var/card_account = pda.id?.associated_account_number
			var/tried_pin = text2num(params["account_pin"])
			attempt_login(tried_pin, card_account, user)

	if(!logged_in)
		return

	switch(action)
		if("select_account")
			var/account = sanitize(params["account"])
			if(!account)
				return
			select_account(account)

		if("transfer")
			if(!COOLDOWN_FINISHED(src, transaction_cd))
				return

			var/transfer_amount = text2num(params["amount"])
			if(!transfer_amount || transfer_amount <= 0) //if null, 0, or negative amount
				return

			var/target_account_number = text2num(params["account_number"])
			var/datum/money_account/account = get_account(target_account_number)

			if(!account)
				return
			if(account == user_account)
				return

			var/comment = sanitize(params["comment"], MAX_COMMENT_LEN)
			transfer_funds(user, transfer_amount, account.account_number, comment)
			update_static_data(ui.user, ui)

		if("set_security")
			var/new_sec_level = clamp(text2num(params["new_security_level"]), ACCOUNT_SECURITY_LEVEL_NONE, ACCOUNT_SECURITY_LEVEL_MAXIMUM)
			if(isnull(new_sec_level))
				return

			var/attempt_pin = input_account_pin(user)
			if(user_account.remote_access_pin == attempt_pin)
				user_account.security_level = new_sec_level
			else
				to_chat(user, "<span class='warning'>Authentification Failure: incorrect pin.</span>")

		if("change_salary")
			var/target = params["account"]
			var/datum/money_account/MA

			for(var/person in my_subordinate_staff(pda.ownrank))
				if(person["account"] == target)
					MA = get_account(target)

			if(!MA)
				return

			MA.change_salary(usr, pda.owner, pda.name, pda.ownrank)
			update_static_data(ui.user, ui)

		if("change_preferred_insurance")
			var/insurance_type = params["insurance"]
			if(!(insurance_type in SSeconomy.insurance_quality_decreasing))
				return

			var/insurance_price = SSeconomy.insurance_prices[insurance_type]

			user_account.owner_preferred_insurance_type = insurance_type
			user_account.owner_max_insurance_payment = max(insurance_price, user_account.owner_max_insurance_payment)

		if("change_insurance_immediately")
			var/insurance_type = params["insurance"]
			if(!(insurance_type in SSeconomy.insurance_quality_decreasing))
				return

			var/insurance_price = SSeconomy.insurance_prices[insurance_type]

			var/insurance_price_with_addition = insurance_price + INSURANCE_TIME_ADDITION
			if(insurance_price == 0)
				insurance_price_with_addition = 0

			if(user_account.money < insurance_price_with_addition)
				return

			if(!insurance_record)
				tgui_alert(usr, "Sorry, but your money account is not connected to your medical record, please check this information and try again.")
				return
			if(insurance_record.fields["insurance_type"] == insurance_type)
				return

			insurance_record.fields["insurance_type"] = insurance_type

			user_account.owner_preferred_insurance_type = insurance_type
			user_account.owner_max_insurance_payment = max(insurance_price, user_account.owner_max_insurance_payment)
			if(insurance_price_with_addition > 0)
				charge_to_account(user_account.account_number, "Medical", "[insurance_type] Insurance payment", "NT Insurance", -insurance_price_with_addition)
				var/med_account_number = global.department_accounts["Medical"].account_number
				charge_to_account(med_account_number, med_account_number,"[insurance_type] Insurance payment", "NT Insurance", insurance_price_with_addition)

		if("change_max_insurance_payment")
			var/new_max_insurance_payment = clamp(text2num(params["max_insurance_payment"]), 0, MAX_INSURANCE_PRICE)
			user_account.owner_max_insurance_payment = new_max_insurance_payment

		if("change_insurance_price")
			if(!pda.cartridge?.can_change_insurance_price)
				return

			if(!pda.id)
				return

			if(!(access_cmo in pda.id.access))
				return

			if(!COOLDOWN_FINISHED(global, insurance_price_change_cd))
				return

			var/list/insurances = params["insurances"]
			for(var/insurance_type in insurances)
				if(!(insurance_type in SSeconomy.insurance_quality_decreasing - INSURANCE_NONE))
					continue

				var/currentprice = SSeconomy.insurance_prices[insurance_type]
				var/newprice = clamp(text2num(insurances[insurance_type]), 1, MAX_INSURANCE_PRICE)

				if(newprice == currentprice)
					continue

				COOLDOWN_START(global, insurance_price_change_cd, INSURANCE_PRICE_CHANGE_CD)
				SSeconomy.insurance_prices[insurance_type] = newprice
				var/obj/item/device/radio/intercom/announcer = new /obj/item/device/radio/intercom(null)
				announcer.autosay("CMO has changed the price of \"[insurance_type]\" insurance from [currentprice] to [newprice] credits.", "Insurancer", "Common", freq = radiochannels["Common"])
				qdel(announcer)

/datum/data/pda/app/nanobank/proc/attempt_login(tried_pin, card_account, mob/user)
	if(user_account.security_level == ACCOUNT_SECURITY_LEVEL_MAXIMUM)
		if(user_account.account_number != card_account)
			login_fail_reason = "Invalid ID card!"
			return FALSE

	if(user_account.security_level != ACCOUNT_SECURITY_LEVEL_NONE)
		if(user_account.remote_access_pin != tried_pin)
			login_fail_reason = "Invalid PIN code!"
			return FALSE

	login_fail_reason = null
	logged_in = TRUE
	return TRUE

/datum/data/pda/app/nanobank/proc/try_link_account(account_num, account_pin, id_account_num, mob/user)
	if(user_account || logged_in)
		return FALSE

	if(!account_num && !id_account_num)
		login_fail_reason = "Please, enter your account number or insert a card."
		return FALSE

	var/datum/money_account/account = get_account(account_num)
	if(!account)
		account = get_account(id_account_num)

	if(!account)
		login_fail_reason = "The account was not found!"
		return FALSE

	if(account.security_level == ACCOUNT_SECURITY_LEVEL_MAXIMUM)
		if(!account_num)
			login_fail_reason = "Please, enter your account number."
			return FALSE
		if(!id_account_num)
			login_fail_reason = "Please, insert your card."
			return FALSE
		if(account_num != id_account_num)
			login_fail_reason = "Invalid account number!"
			return FALSE

	if(account.security_level != ACCOUNT_SECURITY_LEVEL_NONE)
		if(account.remote_access_pin != account_pin)
			login_fail_reason = "Invalid PIN code!"
			return FALSE

	link_account(account)
	logged_in = TRUE
	login_fail_reason = null
	return TRUE

/datum/data/pda/app/nanobank/proc/link_account(datum/money_account/account)
	if(!istype(account))
		return

	user_account = account
	user_account.assigned_pdas += src
	//lets make sure to unlink if the account gets deleted somehow
	RegisterSignal(user_account, COMSIG_PARENT_QDELETING, PROC_REF(unlink_account))

	link_record(user_account.account_number)

/datum/data/pda/app/nanobank/proc/unlink_account()
	SIGNAL_HANDLER

	if(!user_account)
		return

	UnregisterSignal(user_account, COMSIG_PARENT_QDELETING)

	logged_in = FALSE
	user_account.assigned_pdas -= src
	unlink_record()
	user_account = null

/datum/data/pda/app/nanobank/proc/link_record(account_num)
	// we keep insurance information here, so yeah...
	var/datum/data/record/rec = find_record("insurance_account_number", account_num, data_core.general)
	if(!istype(rec))
		return

	insurance_record = rec
	RegisterSignal(insurance_record, COMSIG_PARENT_QDELETING, PROC_REF(unlink_record))

/datum/data/pda/app/nanobank/proc/unlink_record()
	SIGNAL_HANDLER

	UnregisterSignal(insurance_record, COMSIG_PARENT_QDELETING)
	insurance_record = null

/datum/data/pda/app/nanobank/proc/select_account(account_num)
	if(selected_account)
		unselect_account()

	var/datum/money_account/MA = get_account(account_num)
	if(!MA)
		return

	has_back = TRUE
	selected_account = MA
	RegisterSignal(selected_account, COMSIG_PARENT_QDELETING, PROC_REF(unselect_account))

/datum/data/pda/app/nanobank/proc/unselect_account()
	SIGNAL_HANDLER

	has_back = FALSE
	UnregisterSignal(selected_account, COMSIG_PARENT_QDELETING)
	selected_account = null

/datum/data/pda/app/nanobank/proc/transfer_funds(mob/user, amount, target, comment)
	var/purpose = "Transfer"
	if(comment)
		purpose += " ([comment])"

	if(charge_to_account(user_account.account_number, target, purpose, "NanoBank Transfer Services", -amount))
		charge_to_account(target, user_account.account_number, purpose, "NanoBank Transfer Services", amount)
		COOLDOWN_START(src, transaction_cd, TRANSFER_COOLDOWN)
		return TRUE
	else
		error_message(user, "Insufficient Funds")
	return FALSE

/datum/data/pda/app/nanobank/proc/input_account_pin(mob/user)
	var/attempt_pin = input(user, "Enter pin code", "NanoBank Account Auth") as num|null
	if(!user_account || !attempt_pin)
		return
	return attempt_pin

/datum/data/pda/app/nanobank/proc/error_message(mob/user, message)
	to_chat(user, "<span class='warning'>ERROR: [message].</span>")

/datum/data/pda/app/nanobank/proc/get_available_account_data()
	var/list/found_accounts = list()
	for(var/datum/money_account/account as anything in global.all_money_accounts)
		if(account.hidden || account.hidden_for_pda)
			continue
		if(account != user_account)
			var/list/account_data = list(
				"name" = account.owner_name,
				"account_number"  = account.account_number,
				"ref" = REF(account)
			)
			found_accounts += list(account_data)
	return found_accounts

/datum/data/pda/app/nanobank/proc/announce_payday(amount)
	if(ishuman(pda.loc))
		var/mob/user = pda.loc
		if(user.stat != UNCONSCIOUS) // Awake or dead people can see their messages
			to_chat(user, "<span class='notice'>NanoBank: Paycheck of [amount] credits received.</span>")
	if(!pda.silent)
		playsound(pda, 'sound/machines/ping.ogg', 50, 0)

/datum/data/pda/app/nanobank/proc/salary_change_inform(source, amount)
	if(!ishuman(pda.loc))
		return
	var/mob/user = pda.loc
	if(user.stat != UNCONSCIOUS) // Awake or dead people can see their messages
		if(amount > 0)
			to_chat(user, "[bicon(pda)]<span color='#579914'><b>[user_account.owner_name], your salary was increased by [source] by [amount]%!</b></font>")
		else if(amount < 0)
			to_chat(user, "[bicon(pda)]<span class='red'>[user_account.owner_name], your salary was reduced by [source] by [amount]%!</span>")
		else
			to_chat(user, "[bicon(pda)]<span class='notice'><b>[user_account.owner_name], [source] returned your base salary.</b></span>")

/datum/data/pda/app/nanobank/proc/transaction_inform(target, source, amount)
	if(!ishuman(pda.loc))
		return
	var/mob/user = pda.loc
	if(user.stat != UNCONSCIOUS) // Awake or dead people can see their messages
		if(amount > 0)
			to_chat(user, "[bicon(pda)]<span class='notice'>[user_account.owner_name], the amount of [amount]$ from [source] was transferred to your account.</span>")
		else if(amount < 0)
			to_chat(user, "[bicon(pda)]<span class='notice'>You have successfully transferred [abs(amount)]$ to [target] account number.</span>")

/datum/data/pda/app/nanobank/proc/transaction_stock_inform(target, source, department, amount)
	if(!ishuman(pda.loc))
		return
	var/mob/user = pda.loc
	if(user.stat != UNCONSCIOUS) // Awake or dead people can see their messages
		if(amount > 0)
			to_chat(user, "[bicon(pda)]<span class='notice'>[user_account.owner_name], the amount of [amount] of [department] stock from [source] was transferred to your account.</span>")
		else
			to_chat(user, "[bicon(pda)]<span class='notice'>You have successfully transferred [amount] of [department] stock to [target] account number.</span>")
