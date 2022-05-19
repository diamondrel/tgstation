/// Allows an item to  be used to initiate initiator.
/datum/component/interro_initiator
	/// The currently selected target that the user is interrogating
	var/datum/weakref/interro_target_ref

	/// The last user, as a weakref
	var/datum/weakref/last_user_ref

/datum/component/interro_initiator/Initialize()
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/interro_initiator/Destroy(force, silent)
	last_user_ref = null
	interro_target_ref = null

	return ..()

/datum/component/interro_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_interro_moment)

/datum/component/interro_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	unregister_signals()

/datum/component/interro_initiator/proc/unregister_signals()
	var/mob/living/last_user = last_user_ref?.resolve()
	if (!isnull(last_user_ref))
		UnregisterSignal(last_user, COMSIG_MOB_SELECTED_ZONE_SET)

	var/mob/living/interro_target = interro_target_ref?.resolve()
	if (!isnull(interro_target_ref))
		UnregisterSignal(interro_target, COMSIG_MOB_INTERRO_STARTED)

// Initiates interrogation
/datum/component/interro_initiator/proc/initiate_interro_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER
	if(target.stat == UNCONSCIOUS)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, who softly grunts in response."), span_warning("[target] merely grunts in response, they appear to be unconscious."),\
		span_hear("You hear muffled grunts and a [tool] clicking on, followed by a sigh."))
		return
	if(!isliving(target))
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s head, who doesn't respond."), span_warning("Dead men tell no tales."),\
		span_hear("You hear a [tool] clicking on, followed by a sigh."))
		return
	if(!(target in GLOB.alive_player_list))
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, who stares blankly past."), span_warning("[target] stares right through you and appears completely unresponsive to anything. They may snap out of it soon."),\
		span_hear("You hear a [tool] clicking on, followed by a sigh."))
		return
	if(HAS_TRAIT(target,TRAIT_BROKEN))
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, who kicks and screams."), span_warning("[target] screams, you've broken them already."),\
		span_hear("You hear screaming and a [tool] clicking on, followed by a sigh."))
		return
	INVOKE_ASYNC(src, .proc/do_initiate_interro_moment, target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/interro_initiator/proc/do_initiate_interro_moment(mob/living/target, mob/user)
	var/datum/interrogation/current_interro

	if (!isnull(current_interro) && !current_interro.step_in_progress)
		attempt_cancel_interro(current_interro, target, user)
		return

	var/list/available_interro = get_available_interro(user, target)

	if(!length(available_interro))
		if (!HAS_TRAIT(target, TRAIT_RESTRAINED))
			target.balloon_alert(user, "no interrogations available!")
		else
			target.balloon_alert(user, "restrain them!")

		return

	unregister_signals()

	last_user_ref = WEAKREF(user)
	interro_target_ref = WEAKREF(target)

	RegisterSignal(target, COMSIG_MOB_INTERRO_STARTED, .proc/on_mob_interro_started)

	ui_interact(user)

/datum/component/interro_initiator/proc/get_available_interro(mob/user, mob/living/target)
	var/list/available_interro = list()

	var/mob/living/carbon/carbon_target
	if (iscarbon(target))
		carbon_target = target

	for(var/datum/interrogation/interro as anything in GLOB.interro_list)
		if(!HAS_TRAIT(target, TRAIT_RESTRAINED))
			continue
		if(!interrogation.can_start(user, target))
			continue
		for(var/path in interrogation.target_mobtypes)
			if(istype(target, path))
				available_interro += interro
				break
		return available_interro

// De-initialzes the interrogation
/datum/component/interro_initiator/proc/attempt_cancel_interro(datum/interrogation/the_interro, mob/living/target, mob/user)

	if(the_interro.status == 1)
		patient.interro -= the_interro
		REMOVE_TRAIT(patient, TRAIT_ALLOWED_HONORBOUND_ATTACK, type)
		user.visible_message(
			span_notice("[user] rips the [parent] away from [target]'s face."),
			span_notice("You rip the [parent] away from [target]'s face."),
		)

		patient.balloon_alert(user, "stopped interrogating you")

		qdel(the_interro)
		return

	if(!the_interro.can_cancel)
		return

	patient.interro -= the_interro
	REMOVE_TRAIT(patient, TRAIT_ALLOWED_HONORBOUND_ATTACK, ELEMENT_TRAIT(type))

	qdel(the_interro)

/datum/component/interro_initiator/proc/on_mob_interro_started(mob/source, datum/interrogation/interrogation)
	SIGNAL_HANDLER

	var/mob/living/last_user = last_user_ref.resolve()

	if (!isnull(last_user))
		source.balloon_alert(last_user, "someone else started an interrogation!")

	ui_close()

/datum/component/interro_initiator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "InterroInitiator")
		ui.open()

/datum/component/interro_initiator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .

	var/mob/user = usr
	var/mob/living/interro_target = interro_target_ref.resolve()

	if (isnull(interro_target))
		return TRUE
		if (action=="start_interro")
			for (var/datum/interrogation/interrogation as anything in get_available_interro(user, interro_target))
				if (interrogation.name == params["interro_name"])
					try_choose_interro(user, interro_target, interro)
					return TRUE

/datum/component/interro_initiator/ui_assets(mob/user)
	return list(
		//get_asset_datum(/datum/asset/simple/body_zones),
	)

/datum/component/interro_initiator/ui_data(mob/user)
	var/mob/living/interro_target = interro_target_ref.resolve()

	var/list/interro = list()
	if (!isnull(interro_target))
		for (var/datum/interrogation/interro as anything in get_available_interro(user, interro_target))
			var/list/interro_info = list(
				"name" = interrogation.name,
			)

			interro += list(interro_info)

	return list(
		"target_name" = interro_target?.name,
		"interro" = interro,
	)

/datum/component/interro_initiator/ui_close(mob/user)
	unregister_signals()
	interro_target_ref = null

	return ..()

/datum/component/interro_initiator/ui_status(mob/user, datum/ui_state/state)
	var/obj/item/item_parent = parent
	if (user != item_parent.loc)
		return UI_CLOSE

	var/mob/living/interro_target = interro_target_ref?.resolve()
	if (isnull(interro_target))
		return UI_CLOSE

	if (!can_start_interro(user, interro_target))
		return UI_CLOSE

	return ..()

/datum/component/interro_initiator/proc/can_start_interro(mob/user, mob/living/target)
	if (!user.Adjacent(target))
		return FALSE

	// The item was moved somewhere else
	if (!(parent in user))
		return FALSE

	// While we were choosing, another interro was started at the same location
	if (target.beingInterrogated)
		return FALSE

	return TRUE

/datum/component/interro_initiator/proc/try_choose_interro(mob/user, mob/living/target, datum/interrogation/interrogation)
	if (!can_start_interro(user, target))
		// This could have a more detailed message, but the UI closes when this is true anyway, so
		// if it ever comes up, it'll be because of lag.
		target.balloon_alert(user, "can't start the interrogation!")
		return

	if (iscarbon(target))
		var/mob/living/carbon/carbon_target = target

	if (!HAS_TRAIT(target, TRAIT_RESTRAINED))
		target.balloon_alert(user, "patient is not restrained!")
		return

	if (!interro.can_start(user, target))
		target.balloon_alert(user, "can't start the interrogation!")
		return

	ui_close()

	var/datum/interrogation/procedure = new interrogation.type(target,interro_type,stage)
	ADD_TRAIT(target, TRAIT_ALLOWED_HONORBOUND_ATTACK, type)

	target.balloon_alert(user, "starting \"[lowertext(procedure.name)]\"")

	user.visible_message(
		span_notice("[user] drapes [parent] over [target]'s [parse_zone(selected_zone)] to prepare for interro."),
		span_notice("You drape [parent] over [target]'s [parse_zone(selected_zone)] to prepare for \an [procedure.name]."),
	)

	log_combat(user, target, "operated on", null, "(OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

/datum/component/interro_initiator/proc/interro_needs_exposure(datum/interrogation/interro, mob/living/target)
	var/mob/living/user = last_user_ref?.resolve()
	if (isnull(user))
		return FALSE

	return !interro.ignore_clothes && !get_location_accessible(target, user.zone_selected)
