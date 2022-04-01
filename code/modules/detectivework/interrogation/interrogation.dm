/datum/interrogation
	var/goalrangelow = 25
	var/goalrangehigh = 75
	var/goalrangeamount=goalrangehigh-goalrangelow
	var/perfectrangelow = 38
	var/perfectrangehigh = 62
	var/mildtraumarangelow = 50
	var/mildtraumarangehigh = 75
	var/severetrauma = 90
	var/criticalfail = 10

/datum/interrogation/proc/messages(mob/user, mob/living/target, obj/item/flashlight/tool)
	if(target.isunconscious) //pseudocode
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they don't respond."), span_warning("[target] doesn't respond, they appear to be unconscious."),\
		span_hear("You hear muffled grunts and a lamp clicking on, followed by a sigh."))
		return FALSE
	if(target.stat == DEAD)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s head, they don't respond."), span_warning("Dead men tell no tales."),\
		span_hear("You hear a lamp clicking on followed by a sigh."))
		return FALSE
	if(target.isnottraitor) //pseudocode, TODO
		user.span_warning("Either [target] is telling the truth, or they're one hell of a poker player.")
	if(target.isbroken) // pseudocode, TODO
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they kick and scream."), span_warning("[target] screams, you've broken them already."),\
		span_hear("You hear screaming, a lamp clicking on, then followed by a sigh."))
	if(isimmunetointerrogation(target)) //pseudocode, TODO
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they smile smugly."), span_warning("[target] smiles smugly and refuses to cooperate."),\
		span_hear("You hear a lamp clicking on and smug chuckling, followed by a sigh."))
		return FALSE
	return TRUE

/datum/interrogation/proc/verify(mob/living/target,var/antagtype)
	torture(target)
	if(isimmunetointerrogation(target))
		
	
/datum/interrogation/proc/interrogation_selection(mob/user, mob/living/target, try_to_fail = FALSE)
	var/findtraitor = TRUE
	if(can_start) //pseudocode, TODO
		if(target.interrostage==1)
			menu.b1(verify(target,/datum/antagonist/cult)), "Cultist",TRUE)
			menu.b2(verify(target,/datum/antagonist/nukeops)), "Nuclear Operative",TRUE)
			menu.b3(verify(target,"rev"), "Revolutionary",TRUE)
			menu.b4(verify(target,"changeling"), "Changeling",TRUE)
			menu.b6(verify(target,"heretic"), "Heretic",TRUE)
			menu.b7(verify(target,"wizard"), "Wizard",TRUE)
			menu.b8(verify(target,"fugitive"), "Fugitive",TRUE)
			menu.b9(verify(target,"hunter"), "Hunter",TRUE)
			menu.b10(verify(target,"obsessed"), "Obsessed",TRUE)
			menu.b11(verify(target,"thief"), "Thief",TRUE)
		if(target.interrostage==2)
			if(user.get_antag_minds())
				menu.b1(interro_selector(target,"collabors","easy"),"Attempt to extract the names of other cultists")
				menu.b2(interro_selector(target,"location","hard"),"Attempt to find the location of summoning location")
				menu.b3(interro_selector(target,"attacktarget","veryhard"),"Attempt to determine who the cult's final target is")
			if(target.antagtype==nukeops)
				menu.b1(interro_selector(target,"collabors","easy"),"Attempt to extract the names of other nukies")
				menu.b2(interro_selector(target,"purchase","medium"),"Attempt to learn of a purchase the nukies have made")
				menu.b3(interro_selector(target,"location","hard"),"Attempt to find the location of the nukies' shuttle")
				menu.b3(interro_selector(target,"uplink","hard"),"Attempt to find the location of the nukies' shuttle")
				menu.b4(interro_selector(target,"codes","extreme"),"Attempt to extract the nuke code",extreme)
			if(target.antagtype==rev)
				menu.b1(interro_selector(target,"collabors","medium"),"Attempt to extract the names of other revolutionaries",hard) //crit success gives revhead? or there could be another option for heads
			if(target.antagtype==traitor&&findtraitor)
				menu.b1(interro_selector(target,"purchase","easy"),"Attempt to learn of a code phrase used by traitors to communicate)
				menu.b1(interro_selector(target,"phrases","medium"),"Attempt to learn of a code phrase used by syndicate operatives to communicate)
				menu.b2(interro_selector(target,"uplink","hard"),"Attempt to extract the uplink code used by this operative")
		menu.display
	return
