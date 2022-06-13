/// Allows an item to  be used to initiate interrogation.
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

	var/mob/living/interro_target = interro_target_ref?.resolve()
	if (!isnull(interro_target_ref))
		UnregisterSignal(interro_target, COMSIG_MOB_INTERRO_STARTED)

// Initiates interrogation
/datum/component/interro_initiator/proc/initiate_interro_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER
	if(!isliving(target)||!(target in GLOB.alive_player_list)||HAS_TRAIT(target,TRAIT_BROKEN))
		return
	INVOKE_ASYNC(src, .proc/do_initiate_interro_moment, target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/interro_initiator/proc/do_initiate_interro_moment(mob/living/target, mob/user)
	/*var/datum/detectivework/interrogation/current_interro
	current_interro = target.interro

	if (!isnull(current_interro) && !current_interro.step_in_progress)
		attempt_cancel_interro(current_interro, target, user)
		return*/

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

	for(var/datum/detectivework/interrogation/interro as anything in GLOB.interro_list)
		if(!HAS_TRAIT(target, TRAIT_RESTRAINED))
			continue
		if(!interro.can_start(user, target))
			continue
		for(var/path in interro.target_mobtypes)
			if(istype(target, path))
				available_interro += interro
				break
		return available_interro

// De-initialzes the interrogation
/*/datum/component/interro_initiator/proc/attempt_cancel_interro(datum/detectivework/interrogation/the_interro, mob/living/target, mob/user)

	if(the_interro.status == 1)
		target.being_interrogated = FALSE
		user.visible_message(
			span_notice("[user] rips the [parent] away from [target]'s face."),
			span_notice("You rip the [parent] away from [target]'s face."),
			)

		target.balloon_alert(user, "stopped interrogating you")
		return

	if(!the_interro.can_cancel)
		return

	target.being_interrogated = FALSE
*/
/datum/component/interro_initiator/proc/on_mob_interro_started(mob/source, datum/detectivework/interrogation/interrogation)
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
			for (var/datum/detectivework/interrogation/interro as anything in get_available_interro(user, interro_target))
				if (interro.name == params["interro_name"])
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
		for (var/datum/detectivework/interrogation/all_interros as anything in get_available_interro(user, interro_target))
			var/list/interro_info = list(
				"name" = all_interros.name,
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
	if (target.being_interrogated)
		return FALSE

	return TRUE

/datum/component/interro_initiator/proc/try_choose_interro(mob/user, mob/living/target, datum/detectivework/interrogation/interro)
	if (!can_start_interro(user, target))
		target.balloon_alert(user, "can't start the interrogation!")
		return

	if (!HAS_TRAIT(target, TRAIT_RESTRAINED))
		target.balloon_alert(user, "patient is not restrained!")
		return

	if (!interro.can_start(user, target))
		target.balloon_alert(user, "can't start the interrogation!")
		return

	ui_close()

	target.balloon_alert(user, "starting interrogation")

	user.visible_message(
		span_notice("[user] shoves [parent] into [target]'s face and begins grilling [target.p_them()]."),
		span_notice("You shove [parent] into [target]'s face to prepare to grill [target.p_them()]."),
	)

	log_combat(user, target, "interrogated for", null, "(OPERATION TYPE: [interro.name]) (SUSPECTED FACTION: [interro.faction]) (TARGET INFO: [interro.info])")
