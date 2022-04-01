/datum/interrogation

/datum/interrogation/proc/can_start(mob/user, mob/living/target, try_to_fail = FALSE)
	var/goalrange
	var/perfectrange
	var/mildtraumarange
	var/severetraumarange
	var/criticalfailrange
	if(target.isunconscious)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they don't respond."), span_warning("[target] doesn't respond, they appear to be unconscious."),\
		span_hear("You hear muffled grunts and a lamp clicking on, followed by a sigh."))
		return FALSE
	if(target.isdead)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s head, they don't respond."), span_warning("Dead men tell no tales."),\
		span_hear("You hear a lamp clicking on followed by a sigh."))
		return FALSE
	if(target.isimmunetointerrogation)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they smile smugly."), span_warning("[target] smiles smugly and refuses to cooperate."),\
		span_hear("You hear a lamp clicking on and smug chuckling, followed by a sigh."))
		return FALSE
	if(target.isnottraitorconfirmed)
		user.span_warning("[target] isn't a traitor!")
	if(target.isbroken)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they kick and scream."), span_warning("[target] screams, you've broken them already."),\
		span_hear("You hear screaming, a lamp clicking on, then followed by a sigh."))
	return TRUE

/datum/interrogation/breakcheck
	/var/broken = FALSE
	if(stress>=sanity*2)
		broken = TRUE
	return FALSE

/datum/interrogation/interrogation_selection(mob/user, mob/living/target, try_to_fail = FALSE)
	var/findsyndies = TRUE
	if(can_start)
		if(target.interrostage==1)
			menu.b1(findtraitor, "Attempt to determine if the target is a traitor) //maybe only works on those a part of a traitor group, ones that can be pretty easily identified? so not basic syndie traitors?
		if(target.interrostage==2)
			menu.b1(findtraitortype, "Attempt to determine what affiliation the traitor has)
		if(target.interrostage==3)
			if(target.traitortype==cultist)
				menu.b1(break(collabors,culties,easy),"Attempt to extract the names of other cultists")
				menu.b2(break(base,culties,hard),"Attempt to find the location of a cultist base")
				menu.b3(break(atttarget,culties,veryhard),"Attempt to determine who the cult's final target is")
			if(target.traitortype==nukeops)
				menu.b1(break(collabors,nukies,medium),"Attempt to extract the names of other nukies")
				menu.b2(break(purchase,nukies,hard),"Attempt to learn of a purchase the nukies have made")
				menu.b3(break(base,nukies,veryhard),"Attempt to find the location of the nukies' shuttle")
				menu.b4(break(codes,nukies,extreme),"Attempt to extract the nuke code",extreme)
			if(target.traitortype==revs)
				menu.b1(getcollaborators(revs),"Attempt to extract the names of other revolutionaries",hard) //crit success gives revhead? or there could be another option for heads
			if(target.traitortype==syndie&&findsyndies)
				menu.b1(getcodephrases,"Attempt to learn of a code phrase used by syndicate operatives to communicate,medium)
				menu.b2(getuplinkcodes,"Attempt to extract the uplink code used by this operative",hard)
				menu.b3(get
		menu.display
	return
