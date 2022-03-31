/datum/interrogation

/datum/interrogation/proc/try_op(mob/user, mob/living/target, target_zone, obj/item/flashlight, datum/interrogation/interrogation, try_to_fail = FALSE)
	if(target.is_unconscious)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s face, they don't respond."), span_warning("[target] doesn't respond, they appear to unconscious."),\
		span_hear("You hear muffled grunts and a lamp clicking on, followed by a sigh."))
		return
	if(target.is_dead)
		user.visible_message(span_notice("[user] holds the [tool] close to [target]'s head, they don't respond."), span_warning("Dead men tell no tales."))
		span_hear("You hear muffled grunts and a lamp clicking on, followed by a sigh."))