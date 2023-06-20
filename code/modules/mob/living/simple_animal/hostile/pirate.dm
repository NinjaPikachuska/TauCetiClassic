/mob/living/simple_animal/hostile/pirate
	name = "Pirate"
	desc = "Делает, что хочет, потому что пират свободен."
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "piratemelee_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pushes the"
	response_disarm = "shoves"
	response_harm = "hits the"
	speed = 4
	stop_automated_movement_when_pulled = FALSE
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	melee_damage = 30
	attacktext = "slash"
	attack_sound = list('sound/weapons/bladeslice.ogg')

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	var/corpse = /obj/effect/landmark/mobcorpse/pirate
	var/weapon1 = /obj/item/weapon/melee/energy/sword/pirate

	faction = "pirate"

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "pirateranged"
	icon_living = "pirateranged"
	icon_dead = "piratemelee_dead"
	projectilesound = 'sound/weapons/guns/gunpulse_laser.ogg'
	ranged = TRUE
	amount_shoot = 3
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/beam
	corpse = /obj/effect/landmark/mobcorpse/pirate/ranged
	weapon1 = /obj/item/weapon/gun/energy/laser


/mob/living/simple_animal/hostile/pirate/death()
	..()
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	qdel(src)
	return
