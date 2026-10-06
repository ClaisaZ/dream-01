class_name Equipment
extends Resource
## A weapon or armor piece. Each piece belongs to one character: it's listed
## in that character's UnitData gear line (weapons / armors), where its position
## is its tier. Tier 0 is starting gear; each boss beaten unlocks the next tier in the shop.
## Each piece is saved as its own .tres file in /data/equipment/.

enum Slot { WEAPON, ARMOR }

@export var display_name: String = ""
@export_multiline var description: String = ""
## Placeholder is fine until the real art arrives.
@export var icon: Texture2D
@export var slot: Slot = Slot.WEAPON

@export_group("Stat Bonuses")
## Flat bonuses added to the character's stats while equipped.
## Weapons usually give ATK or MAG (sometimes SPD); armor usually gives DEF and HP.
@export var atk_bonus: int = 0
@export var def_bonus: int = 0
@export var spd_bonus: int = 0
@export var mag_bonus: int = 0
@export var max_hp_bonus: int = 0

@export_group("Shop")
## 0 = not sold (e.g. starting gear).
@export var price: int = 0
