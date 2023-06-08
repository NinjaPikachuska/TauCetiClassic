/obj/machinery/disposal/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(action == "eject" && HAS_TRAIT(usr, TRAIT_HIDDEN_STASH))
		to_chat(usr, "<span class='notice'>А вот и мой набор.</span>")
		usr.put_in_active_hand(new /obj/item/weapon/storage/backpack/satchel/orbital(loc))
		REMOVE_TRAIT(usr, TRAIT_HIDDEN_STASH, ROLE_TRAIT)

/obj/item/weapon/storage/backpack/satchel/orbital/atom_init()
	. = ..()
	new /obj/item/weapon/card/emag(src)
	new /obj/item/device/radio/beacon/syndicate_bomb(src)
	new /obj/item/weapon/gun/projectile/revolver/orbital(src)

/obj/item/weapon/gun/projectile/revolver/orbital
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/orbital

/obj/item/ammo_box/magazine/internal/cylinder/orbital
	max_ammo = 3
	ammo_type = /obj/item/ammo_casing/a357/orbital

/obj/item/ammo_casing/a357/orbital
	projectile_type = /obj/item/projectile/bullet/revbullet/orbital

/obj/item/projectile/bullet/revbullet/orbital
	damage = 35
	armor_multiplier = 1
