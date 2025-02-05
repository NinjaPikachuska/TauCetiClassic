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
	silent = TRUE
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

/obj/item/device/pda/syndicate/New()
	..()
	var/datum/data/pda/app/messenger/M = find_program(/datum/data/pda/app/messenger)
	if(M)
		M.m_hidden = TRUE

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
	silent = TRUE //Quiet in the library!

/obj/item/device/pda/reporter
	icon_state = "pda-libc"

/obj/item/device/pda/forensic
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda-forensic"

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."

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
