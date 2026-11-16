---
name: Iron & Parchment
colors:
  surface: '#111417'
  surface-dim: '#111417'
  surface-bright: '#37393d'
  surface-container-lowest: '#0b0f11'
  surface-container-low: '#191c1f'
  surface-container: '#1d2023'
  surface-container-high: '#272a2d'
  surface-container-highest: '#323538'
  on-surface: '#e1e2e6'
  on-surface-variant: '#d0c5af'
  inverse-surface: '#e1e2e6'
  inverse-on-surface: '#2e3134'
  outline: '#99907c'
  outline-variant: '#4d4635'
  surface-tint: '#e9c349'
  primary: '#f2ca50'
  on-primary: '#3c2f00'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#735c00'
  secondary: '#fcba5f'
  on-secondary: '#462b00'
  secondary-container: '#905d01'
  on-secondary-container: '#ffe4c5'
  tertiary: '#ffbfb5'
  on-tertiary: '#690002'
  tertiary-container: '#ff9688'
  on-tertiary-container: '#871a12'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#ffddb5'
  secondary-fixed-dim: '#fcba5f'
  on-secondary-fixed: '#2a1800'
  on-secondary-fixed-variant: '#643f00'
  tertiary-fixed: '#ffdad5'
  tertiary-fixed-dim: '#ffb4a9'
  on-tertiary-fixed: '#410001'
  on-tertiary-fixed-variant: '#8a1c14'
  background: '#111417'
  on-background: '#e1e2e6'
  surface-variant: '#323538'
typography:
  headline-lg:
    fontFamily: Domine
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Domine
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Domine
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Domine
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 24px
  body-lg:
    fontFamily: Source Serif 4
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Source Serif 4
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Source Serif 4
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Source Serif 4
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Source Serif 4
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
  label-sm:
    fontFamily: Source Serif 4
    fontSize: 9px
    fontWeight: '600'
    lineHeight: 12px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 0.75rem
  gutter-mobile: 0.5rem
  margin: 1rem
  margin-mobile: 0.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system establishes a battle-hardened, historical medieval RTS command interface tailored for mobile screens. Inspired by classic fortress-building strategy games, it balances deep stone-slate surfaces with burnished antique gold trim, aged parchment undertones, and severe crimson alerts. The atmosphere is solemn, tactical, and authoritative—evoking fortified ramparts, war-room cartography, and heraldic battle honors.

The visual style blends **tactile skeuomorphism** with **modern military functionalism**:
- Heavy architectural weight: Interface panels feel forged from chiselled stone and tempered iron plates rather than weightless digital sheets.
- High-contrast strategic hierarchy: Warm antique gold highlights essential command paths, parchment ambers frame resource metrics, and crimson indicates casualty thresholds and active siege states.
- Utility-first clarity: Ornate medieval accents are restrained to structural perimeters, corner chamfers, and headers, ensuring complex resource tallies, troop counts, and tactical battle maps remain razor-sharp on mobile displays.

## Colors

The palette translates the martial reality of a fortress siege into functional digital tokens:

- **Primary (`#D4AF37` - Antique Gold):** Represents sovereignty, completed production, elite unit ranks, and primary interactive prompts. Used for ornate panel borders, key action buttons, and active tabs.
- **Secondary (`#D99B43` - Parchment Amber):** Evokes illuminated manuscripts and military reconnaissance maps. Used for economic resource values (wood, stone, grain), secondary alerts, trade interfaces, and neutral state indicators.
- **Tertiary (`#8A1C14` - Blood Crimson):** Denotes mortal peril, unit casualties, breached walls, enemy targeting, and critical siege weapon controls.
- **Neutral (`#1A1D20` - Stone Slate / Dark Iron):** The foundational substrate. Deep, desaturated slate and cold iron plates absorb glare, keeping cognitive load low during rapid unit micro-management.

### Dark Mode Semantic Mapping
- **Canvas Base:** `#111315` (Deep Fortress Slate)
- **Surface Layer 1 (Unit & Map Trays):** `#1A1D20` (Dark Chiseled Slate)
- **Surface Layer 2 (Cards & Resource Pods):** `#24282D` (Forged Iron Plate)
- **Surface Layer 3 (Modals & Overlays):** `#2D3238` (Reinforced Bastion Layer)
- **Text Primary:** `#F3EDE2` (Bleached Parchment)
- **Text Secondary:** `#B5ABA0` (Weathered Masonry Dust)
- **Text Disabled:** `#5C6166` (Cold Slag)

## Typography

Typography reinforces the historical command atmosphere while resisting decorative illegibility:

- **Headlines (`Domine`):** Selected for its commanding serifs, sturdy proportions, and medieval epigraphic weight. Headings feel etched into monumental architecture. Used for victory/defeat declarations, siege objectives, fortress sectors, and commander titles.
- **Body & Labels (`Source Serif 4`):** Features sharp vertical strokes, open counters, and high legibility at micro-scales on mobile touchscreens. Perfect for compact unit statistics (Armor, Range, Damage), building upgrade costs, trade logs, and chat notifications.
- **Resource Numbers & Counters:** Must render using tabular figures (`font-variant-numeric: tabular-nums`) with `Source Serif 4` bold weights, ensuring gold, timber, stone, and food rates remain stable without horizontal jitter.

## Layout & Spacing

Mobile warfare demands maximum screen real estate for the tactical viewport, bounded by HUD anchors:

- **HUD Frame Philosophy:** The screen is governed by a perimeter HUD overlay. Resource badges hug the top notch area, action trays and unit rosters dominate the bottom thumb-zone, and contextual battle reports expand from screen edges.
- **Grid Layout:** An 8-column mobile fluid layout with tight gutters (`gutter-mobile: 0.5rem`) maximizes space for 4-to-6 unit queue slots across horizontal screen widths.
- **Safe Zones:** Top margins accommodate device cutouts while anchoring the gold, iron, and grain resource headers. The lower edge incorporates 0.5rem safe-inset padding to guard gesture-navigation bars from accidental unit orders.
- **Micro-density Hierarchy:** Internal card spacing uses compact increments (`space-xs` and `space-sm`) to keep unit stat blocks readable without occluding ongoing battlefield action.

## Elevation & Depth

Depth is treated as architectural layers of a fortified fortress:

- **Chiseled Base (Level 0):** Background slate at `#111315` with fine noise/grain resembling quarried bedrock.
- **Inset Wells (Sunken Trays):** Unit recruitment queues and inventory slots sit inset within the base, marked by top-left inner shadows (`inset 1px 2px 4px rgba(0, 0, 0, 0.7)`) and subtle dark borders.
- **Raised Stone Plates (Level 1 - HUD Panels):** Surface `#1A1D20` bordered by a 1px solid iron outline (`#363C44`) with a faint bottom highlight (`rgba(255, 255, 255, 0.05)`). Ambient shadow: `0 4px 12px rgba(0, 0, 0, 0.6)`.
- **Command Overlays & Dialogs (Level 2):** Bastion layer `#24282D` enclosed in an antique gold filigree rim (`#D4AF37`), backdropped by a 60% black slate scrim. Ambient shadow: `0 8px 24px rgba(0, 0, 0, 0.85)`.
- **Gold Embellishments:** Interactive gold elements utilize a crisp bevel effect: a 1px top stroke of `#F4DC89` paired with a 1px bottom shadow of `#7A6218`.

## Shapes

The shape vocabulary rejects modern bulbous forms in favor of chiseled, disciplined masonry:

- **Base Curvature:** Restricted to `0.25rem` (Level 1 - Soft) on mobile touch targets to simulate subtly honed cut stone while preventing snagging or modern plastic appearances.
- **Corner Chamfers:** Prominent modals, fortress construction cards, and unit cards feature 45-degree clipped or notched corners (4px to 6px) to emulate iron corner-plates and medieval heraldic shield profiles.
- **Dividers & Borders:** Horizontal dividers are tapered iron bars: 1px thick, peaking at `#D4AF37` or `#363C44` in the center and fading to transparent at the edges.

## Components

### Command Buttons
- **Primary Action (Siege / Deploy):** Background in burnished gold gradient (`#D4AF37` to `#A88420`), text in deep slate (`#111315`), sharp 1px outer bevel, with inset corner braces.
- **Destructive Action (Raze / Retreat):** Crimson base (`#8A1C14`), antique gold text, 1px border of `#C43224`.
- **Secondary / Utility (Inspect / Cancel):** Dark iron plate (`#24282D`), text in `#F3EDE2`, 1px border of `#454C54`.

### Resource Badges (Mobile Top Bar)
- Slender horizontal capsules featuring an inset dark slate well (`#111315`), a metallic embossed icon (Gold ingot, Stone block, Grain sheaf, Meat), followed by high-contrast numeric values in `Source Serif 4` bold (`#F3EDE2`). A secondary delta badge displays yield per minute (`+124/m` in `#D99B43`).

### Unit & Structure Cards
- Heavy stone backgrounds (`#1E2226`) with a 1px perimeter border. Top header displays unit class accompanied by an antique gold crest. The center thumbnail is flanked by tier stars. The footer holds gold and iron production costs, alongside training progress represented by a gold fill bar.

### Battle Banners & Tabs
- Vertical swallowtail ribbon tabs fixed to the left or right edges. Active tabs display antique gold with black typography; inactive tabs display weathered iron with bronze insignias.

### Checkboxes & Toggle Switches
- Checkboxes take the form of iron lock-plates with an etched square well; checked states display a solid gold heraldic cross. Toggles are styled as miniature lever switches moving across an etched stone track.

### Sliders (Troop & Ration Allocation)
- Track carved like a stone channel (`#111315`). Active fill uses crimson-tinted amber. The thumb is an iron shield boss with a central gold stud.

### Text Inputs & War-Room Search
- Dark sunken stone wells with parchment-tinted typography. Active focus applies a 1px illuminated antique gold outline with an inner gold glow.