class_name ItemBag
extends Resource
## The party's shared bag: which items and how many of each.
## For now a test bag (/data/items/test_bag.tres) is handed to each battle.
## The real bag will come from game progress once saving exists.

## Item -> how many the party has.
@export var items: Dictionary[Item, int] = {}
