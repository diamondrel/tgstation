/datum/interrogation

/datum/interrogation/proc/can_start(mob/user, mob/living/target, try_to_fail = FALSE)
	var/goalrange
	var/perfectrange
	var/mildtraumarange
	var/severetraumarange
	var/criticalfailrange
	if(target.isunconscious) //pseudocode
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they don't respond."), span_warning("[target] doesn't respond, they appear to be unconscious."),\
		span_hear("You hear muffled grunts and a lamp clicking on, followed by a sigh."))
		return FALSE
	if(target.stat == DEAD)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s head, they don't respond."), span_warning("Dead men tell no tales."),\
		span_hear("You hear a lamp clicking on followed by a sigh."))
		return FALSE
	if(target.isimmunetointerrogation) //pseudocode, TODO
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they smile smugly."), span_warning("[target] smiles smugly and refuses to cooperate."),\
		span_hear("You hear a lamp clicking on and smug chuckling, followed by a sigh."))
		return FALSE
	if(target.istraitor) //pseudocode, TODO
		user.span_warning("[target] isn't a traitor!")
	if(target.isbroken) // pseudocode, TODO
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they kick and scream."), span_warning("[target] screams, you've broken them already."),\
		span_hear("You hear screaming, a lamp clicking on, then followed by a sigh."))
	return TRUE

/datum/interrogation/proc/interro_selector(mob/user,mob/living/target,var/retinfo,var/difficulty)
	if(retinfo=="isantag")
		if(target.isantag)
			if(target.

/datum/interrogation/proc/verify(mob/user,mob/living/target,var/antagtype)
	if(user.isantag==TRUE&&user.antag==antagtype)
	
/datum/interrogation/proc/interrogation_selection(mob/user, mob/living/target, try_to_fail = FALSE)
	var/findtraitor = TRUE
	if(can_start) //pseudocode, TODO
		if(target.interrostage==1)
			menu.b1(verify(user,target,"cultist"), "Cultist",TRUE)
			menu.b2(verify(user,target,"nukie"), "Nuclear Operative",TRUE)
			menu.b3(verify(user,target,"rev"), "Revolutionary",TRUE)
			menu.b4(verify(user,target,"changeling"), "Changeling",TRUE)
			menu.b6(verify(user,target,"heretic"), "Heretic",TRUE)
			menu.b7(verify(user,target,"wizard"), "Wizard",TRUE)
			menu.b8(verify(user,target,"fugitive"), "Fugitive",TRUE)
			menu.b9(verify(user,target,"hunter"), "Hunter",TRUE)
			menu.b10(verify(user,target,"obsessed"), "Obsessed",TRUE)
			menu.b11(verify(user,target,"thief"), "Thief",TRUE)
		if(target.interrostage==2)
			if(target.antagtype==cultist)
				menu.b1(interro_selector(collabors,easy),"Attempt to extract the names of other cultists")
				menu.b2(interro_selector(location,hard),"Attempt to find the location of summoning location")
				menu.b3(interro_selector(attacktarget,culties,veryhard),"Attempt to determine who the cult's final target is")
			if(target.traitortype==nukeops)
				menu.b1(interro_selector(collabors,nukies,easy),"Attempt to extract the names of other nukies")
				menu.b2(interro_selector("purchase","nukies","medium"),"Attempt to learn of a purchase the nukies have made")
				menu.b3(interro_selector("location","nukies","hard"),"Attempt to find the location of the nukies' shuttle")
				menu.b3(interro_selector("uplink","nukies","hard"),"Attempt to find the location of the nukies' shuttle")
				menu.b4(interro_selector("codes","nukies","extreme"),"Attempt to extract the nuke code",extreme)
			if(target.traitortype==rev)
				menu.b1(interro_selector(collabors,rev,medium),"Attempt to extract the names of other revolutionaries",hard) //crit success gives revhead? or there could be another option for heads
			if(target.traitortype==traitor&&findtraitor)
				menu.b1(interro_selector(purchase,traitor,easy),"Attempt to learn of a code phrase used by traitors to communicate)
				menu.b1(interro_selector(phrases,traitor,medium),"Attempt to learn of a code phrase used by syndicate operatives to communicate)
				menu.b2(interro_selector("uplink","traitor","hard"),"Attempt to extract the uplink code used by this operative")
				menu.b3(get
		menu.display
	return
