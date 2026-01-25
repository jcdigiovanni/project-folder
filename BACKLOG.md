# Backlog - Bugs & Enhancements

## Bugs

### BUG-001: Exit button doesn't function
- **Location**: Unknown (need to identify which screen)
- **Issue**: Exit button doesn't exit/function as expected
- **Priority**: High

### BUG-002: Supply limit increases not persisting
- **Location**: Settings/Supply limit selection
- **Issue**: Supply limit changes may not stick after reload. May need a save/update event after selecting.
- **Priority**: High

### BUG-003: Renowned Heroes requisition still showing after use
- **Location**: "Add Unit" popup in OOB screen
- **Issue**: Renowned Heroes requisition option is still available even after it has been applied to the first character
- **Expected**: Should be hidden after the requisition has been used
- **Priority**: Medium

---

## Enhancements

### ENH-001: Back button in dialogs/popups
- **Location**: All dialogs and popups (e.g., Add Unit to OOB dialog)
- **Issue**: No back button to return to parent screen - user must tap dead space to exit
- **Request**: Add explicit back/close button to all popup screens
- **Note**: Need to differentiate between popups and base screens for consistent UX
- **Priority**: Medium

### ENH-002: Consistent button styling across dialogs
- **Location**: All dialogs and popups
- **Issue**: Buttons and selections in dialogs/popups have inconsistent styling
- **Request**: Sanity pass to ensure all functional buttons use the same style
- **Priority**: Low

### ENH-003: Show RP/CP summary on Modify OOB screen
- **Location**: `oob_modify_screen.dart`
- **Issue**: No visibility into RP budget on the OOB screen
- **Request**: Add summary display showing:
  - Total Crusade Points (sum of all units)
  - Available RP
  - Remaining RP (Available - spent)
  - Supply Limit
- **Display Order**: Total CP | Available RP | Remaining | Supply Limit
- **Priority**: Medium

---

## Notes

- Dialogs vs Base Screens: Need to establish a pattern for navigation in popups (explicit close button) vs full screens (app bar back button)
- Button Styling: Consider creating a shared button style/theme for consistency
