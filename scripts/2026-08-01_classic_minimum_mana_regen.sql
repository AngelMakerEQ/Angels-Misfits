-- Angels Misfits: classic minimum mana regeneration
--
-- Scope: active ruleset 1 (the ruleset assigned to the live classic zones).
-- Rationale: With Character:OldMinMana=false, a character with no Meditate
-- skill receives 0 mana per tick while sitting and standing.  The classic
-- baseline is 2 mana/tick sitting and 1 mana/tick standing.  This rule keeps
-- the normal Meditate formula intact and applies only that minimum floor.
--
-- Apply while the server is stopped, then restart World and all Zone processes
-- so the ruleset is reloaded.

START TRANSACTION;

UPDATE rule_values
SET rule_value = 'true'
WHERE ruleset_id = 1
  AND rule_name = 'Character:OldMinMana';

SELECT ruleset_id, rule_name, rule_value
FROM rule_values
WHERE ruleset_id = 1
  AND rule_name = 'Character:OldMinMana';

COMMIT;
