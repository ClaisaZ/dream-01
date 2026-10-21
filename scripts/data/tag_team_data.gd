class_name TagTeamData
extends Resource
## A tag-team attack between two specific party members. Every pair has its own.
## Each one is saved as its own .tres file in /data/tag_teams/.
##
## It can trigger when the two members hit the same enemy in the same round
## (chances live in BattleRules). It's unlocked by a story event; until game
## progress exists, the test battle treats the test tag-team as unlocked.

@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Pair")
@export var member_a: UnitData
@export var member_b: UnitData

@export_group("Attack")
## The hit itself: power (e.g. 2.5, stronger than a special), physical or magic,
## and an optional status effect. Its meter gain is ignored: tag-teams fill no meter.
@export var attack: SkillData


## True if these two units are this tag-team's pair (in either order).
func is_pair(a: UnitData, b: UnitData) -> bool:
	return (a == member_a and b == member_b) or (a == member_b and b == member_a)
