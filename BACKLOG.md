# BACKLOG.md
**Last Updated:** February 24, 2026 (Victor Bonuses)

## Tasks

## Bugs
- No remaining bugs in backlog.

## Enhancements
- No remaining enhancements in backlog.

# Emperor’s Children Battle Triats (Honors)

## Draught of Despair

- Each time an **EMPEROR’S CHILDREN** unit from your Crusade army destroys an enemy unit that is **Battle-shocked**, that **EMPEROR’S CHILDREN** unit gains 2XP.
- At the end of the battle:
  - If one or more enemy units failed a Battle-shock test during the battle → gain 1 **Common** ingredient.
  - If three or more enemy units failed a Battle-shock test during the battle → gain 1 **Rare** ingredient.
  - If six or more enemy units failed a Battle-shock test during the battle, **or** if any of those enemy units destroyed while **Battle-shocked** were **AELDARI** units → gain 1 **Essence of Fear**.

## Adorn the Canvas Eclectic

At the end of each battle round:

- If you control more objective markers than your opponent → select one **EMPEROR'S CHILDREN** unit from your Crusade army within range of an objective marker you control; that unit gains 1XP.
- If more enemy units were destroyed this battle round than friendly units → select one **EMPEROR’S CHILDREN** unit from your Crusade army that destroyed one or more enemy units this battle round; that unit gains 1XP.

Additional rules:

- A unit cannot gain more than 3XP per battle from this Agenda.
- At the end of the battle, if units from your Crusade army gained a combined total of 6 or more XP from this Agenda during that battle → when rolling the D6 to determine whether a **Rare** ingredient is added to your Combat Elixirs Stash, add 3 to the result.

## Symphony of Pain and Hate

- Each time an **EMPEROR’S CHILDREN** unit from your Crusade army destroys an enemy unit that has destroyed one or more units from your Crusade army during the battle → that **EMPEROR’S CHILDREN** unit gains 2XP.
- At the end of the battle:
  - If one or more **EMPEROR’S CHILDREN** units from your Crusade army destroyed three or more such enemy units during the battle → gain 1 **Rare** ingredient.
  - If one or more such destroyed enemy units were **ADEPTUS ASTARTES**, **DEATHWATCH**, or **GREY KNIGHTS** units → gain 1 **Distillate of Hatred**.

## Feeding the Addiction

- Each time an **EMPEROR’S CHILDREN** unit from your Crusade army destroys an enemy unit with a melee attack → that **EMPEROR’S CHILDREN** unit gains 1XP.
- At the end of the battle, add to your Combat Elixirs Stash (gain all that apply):

| Enemy Units Killed During the Battle                              | Ingredient Added to Stash                                      |
|-------------------------------------------------------------------|----------------------------------------------------------------|
| One or more **CHAOS** units (excluding **DAEMONS**)               | 1 **Rare** ingredient **or** 1 **Infusion of Traitor’s Blood** |
| One or more units (excluding **IMPERIUM** and **CHAOS** units)    | 1 **Rare** ingredient **or** 1 **Extract of Xeno-matter**     |
| One or more **IMPERIUM** units                                    | 1 **Rare** ingredient **or** 1 **Dilution of False Hope**     |
| Six or more units                                                 | D3 **Common** ingredients                                      |

## Features
- **FEA-018 (Low)**: Pre-Battle Unit Assignment Screen — UX polish item (not required to prevent code bloat). Add an interlude screen between agenda selection and active game. Full-screen checklist per agenda for unit assignment. The current in-dialog multi-select approach scales fine for any number of agendas/units. Related: `active_game_screen.dart:_showUnitSelectionDialog`, `play_screen.dart`.

## Deferred / Honor-System Items (RP Spend Only – No Enforcement)
- **DEF-002 (Low)**: Stub "Maintenance and Upgrades" (if rules require; similar RP-only pattern: deduct 1–2 RP, log event)

## Data Fills (Separate Generation)
- **DATA-001 (Medium)**: Full Deathwatch unit data (MFM v3.8 page 19 reference; extract points/flags like prior factions – generate externally)

## Archived/Resolved This Sprint
- **EC Combat Elixirs**: Full inventory/crafting/equipping system — data model, stash management screen, OOB integration, pre-battle equipping, active game reference, post-game ingredient rolls. `factionDataJson` on Crusade, `equippedElixirsJson` on Game.
