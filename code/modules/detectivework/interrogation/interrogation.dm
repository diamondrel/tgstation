/datum/interrogation
	var/interrostage = 1
	var/goalrangelow = 25
	var/goalrangehigh = 75
	var/goalrangeamount=goalrangehigh-goalrangelow
	var/perfectrangelow = 38
	var/perfectrangehigh = 62
	var/mildtraumarangelow = 50
	var/mildtraumarangehigh = 75
	var/severetrauma = 90
	var/criticalfail = 10

/datum/interrogation/proc/can_start(mob/user, mob/living/target, obj/item/tool)
	if(target.stat == UNCONSCIOUS)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, who softly grunts in response."), span_warning("[target] doesn't respond, they appear to be unconscious."),\
		span_hear("You hear muffled grunts and a [tool] clicking on, followed by a sigh."))
		return FALSE
	if(target.stat == DEAD)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s head, who doesn't respond."), span_warning("Dead men tell no tales."),\
		span_hear("You hear a [tool] clicking on, followed by a sigh."))
		return FALSE
	if(!(target in GLOB.alive_player_list))
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, who stares blankly past."), span_warning("[target] stares right through you and appears completely unresponsive to anything. They may snap out of it soon."),\
		span_hear("You hear a [tool] clicking on, followed by a sigh."))
		return FALSE
	if(HAS_TRAIT(target,TRAIT_BROKEN))
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, who kicks and screams."), span_warning("[target] screams, you've broken them already."),\
		span_hear("You hear screaming and a [tool] clicking on, followed by a sigh."))
		return FALSE
	return TRUE

// /datum/interrogation/proc/isantag(mob/living/target,var/antagtype)
//	return target.mind.has_antag_datum(antagtype)

/datum/interrogation/proc/interrogation_selection(mob/user, mob/living/target,obj/item/tool, datum/tgui/ui)
	var/findtraitor = TRUE
	if(can_start(user,target,tool))
		if(target.interrostage==1)
			menu.b1(target.mind.has_antag_datum(/datum/antagonist/cult)), "Cultist",TRUE)
			menu.b2(target.mind.has_antag_datum(/datum/antagonist/nukeop)), "Nuclear Operative",TRUE)
			menu.b3(verifyinterro(target,"rev"), "Revolutionary",TRUE)
			menu.b4(verifyinterro(target,"changeling"), "Changeling",TRUE)
			menu.b6(verifyinterro(target,"heretic"), "Heretic",TRUE)
			menu.b7(verifyinterro(target,"wizard"), "Wizard",TRUE)
			menu.b8(verifyinterro(target,"fugitive"), "Fugitive",TRUE)
			menu.b9(verifyinterro(target,"hunter"), "Hunter",TRUE)
			menu.b10(verifyinterro(target,"obsessed"), "Obsessed",TRUE)
			menu.b11(verifyinterro(target,"thief"), "Thief",TRUE)
		if(target.interrostage==2)
			if(user.mind.has_antag_datum(datum/antagonist/cult))
				menu.b1(interro_selector(target,"collabors","easy"),"Attempt to extract the names of other cultists")
				menu.b2(interro_selector(target,"location","hard"),"Attempt to find a summoning location")
				menu.b3(interro_selector(target,"attacktarget","veryhard"),"Attempt to determine who the cult's final target is")
			if(user.mind.has_antag_datum(datum/antagonist/nukeop))
				menu.b1(interro_selector(target,"collabors","easy"),"Attempt to extract the names of other nukies")
				menu.b2(interro_selector(target,"purchase","medium"),"Attempt to learn of a purchase the nukies have made")
				menu.b3(interro_selector(target,"location","hard"),"Attempt to find the location of the nukies' shuttle")
				menu.b3(interro_selector(target,"uplink","hard"),"Attempt to find the location of the nukies' shuttle")
				menu.b4(interro_selector(target,"codes","extreme"),"Attempt to extract the nuke code")
			if(user.mind.has_antag_datum(datum/antagonist/rev))
				menu.b1(interro_selector(target,"collabors","medium"),"Attempt to extract the names of other revolutionaries") //crit success gives revhead? or there could be another option for heads
			if(user.mind.has_antag_datum(datum/antagonist/traitor)&&findtraitor)
				menu.b1(interro_selector(target,"purchase","easy"),"Attempt to learn of a code phrase used by traitors to communicate)
				menu.b1(interro_selector(target,"phrases","medium"),"Attempt to learn of a code phrase used by syndicate operatives to communicate)
				menu.b2(interro_selector(target,"uplink","hard"),"Attempt to extract the uplink code used by this operative")
		ui_interact(user)
	return

/datum/interrogation/ui_interact(mob/user,datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "InterrogationInitiator")
		ui.open()

/datum/interrogation/ui_data(mob/user)
	var/list/data = list()
	data["stage"] = interrostage
	//// CONTINUE ADDING UI

/*/datum/interrogation/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .


/datum/component/surgery_initiator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/body_zones),
	)

/datum/component/surgery_initiator/ui_data(mob/user)
	var/mob/living/surgery_target = surgery_target_ref.resolve()

	var/list/surgeries = list()
	if (!isnull(surgery_target))
		for (var/datum/surgery/surgery as anything in get_available_surgeries(user, surgery_target))
			var/list/surgery_info = list(
				"name" = surgery.name,
			)

			if (surgery_needs_exposure(surgery, surgery_target))
				surgery_info["blocked"] = TRUE

			surgeries += list(surgery_info)

	return list(
		"selected_zone" = user.zone_selected,
		"target_name" = surgery_target?.name,
		"surgeries" = surgeries,
	)

/datum/component/surgery_initiator/ui_close(mob/user)
	unregister_signals()
	surgery_target_ref = null

	return ..()

/datum/component/surgery_initiator/ui_status(mob/user, datum/ui_state/state)
	var/obj/item/item_parent = parent
	if (user != item_parent.loc)
		return UI_CLOSE

	var/mob/living/surgery_target = surgery_target_ref?.resolve()
	if (isnull(surgery_target))
		return UI_CLOSE

	if (!can_start_surgery(user, surgery_target))
		return UI_CLOSE

	return ..()*/