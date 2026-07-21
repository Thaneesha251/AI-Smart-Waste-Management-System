PRIORITY_RULES = {
    'Electronics': ('CRITICAL', 4, 'E-waste contains toxic materials'),
    'Container for household chemicals': ('CRITICAL', 4, 'Chemical exposure risk'),
    'Aerosols': ('HIGH', 3, 'Pressurized hazardous container'),
    'Glass bottle': ('HIGH', 3, 'Broken glass can cause injuries'),
    'Organic': ('HIGH', 3, 'Organic waste can decompose and attract pests'),
    'Plastic bottle': ('MEDIUM', 2, 'Non-biodegradable plastic waste'),
    'Plastic bag': ('MEDIUM', 2, 'Plastic pollution risk'),
    'Paper': ('LOW', 1, 'Routine recyclable waste'),
    'Cardboard': ('LOW', 1, 'Routine recyclable waste'),
}

PRIORITY_ORDER = {
    'LOW': 1,
    'MEDIUM': 2,
    'HIGH': 3,
    'CRITICAL': 4
}


def assign_priority(detections):
    if not detections:
        return {
            'priority': 'LOW',
            'priority_score': 1,
            'reason': 'No waste detected'
        }

    highest_priority = 'LOW'
    highest_score = 1
    highest_reason = 'Routine waste'

    for detection in detections:
        label = detection['class_name']

        priority, score, reason = PRIORITY_RULES.get(
            label,
            ('MEDIUM', 2, 'Unknown waste type')
        )

        if PRIORITY_ORDER[priority] > PRIORITY_ORDER[highest_priority]:
            highest_priority = priority
            highest_score = score
            highest_reason = reason

    return {
        'priority': highest_priority,
        'priority_score': highest_score,
        'reason': highest_reason
    }