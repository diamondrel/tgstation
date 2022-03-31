/datum/interrogation

/datum/interrogation/proc/try_op(mob/user, mob/living/target, target_zone, obj/item/flashlight, datum/interrogation/interrogation, try_to_fail = FALSE)
	var/goalrange
	var/perfectrange
	var/mildtraumarange
	var/severetraumarange
	var/criticalfailrange
	if(target.is_unconscious)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they don't respond."), span_warning("[target] doesn't respond, they appear to be unconscious."),\
		span_hear("You hear muffled grunts and a lamp clicking on, followed by a sigh."))
		return
	if(target.is_dead)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s head, they don't respond."), span_warning("Dead men tell no tales."),\
		span_hear("You hear a lamp clicking on followed by a sigh."))
		return
	if(target.isimmunetointerrogation)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they smile smugly."), span_warning("[target] smiles smugly and refuses to cooperate."),\
		span_hear("You hear a lamp clicking on and smug chuckling, followed by a sigh."))
		return
	if(target.isbroken)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they kick and scream."), span_warning("[target] screams, you've broken them already."),\
		span_hear("You hear a lamp clicking on and screaming, followed by a sigh."))
	run_interrogation_selection()
