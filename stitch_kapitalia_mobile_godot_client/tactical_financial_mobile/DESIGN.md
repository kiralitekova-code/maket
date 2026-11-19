---
name: Tactical Financial Mobile
colors:
  surface: '#151A21'
  surface-dim: '#111319'
  surface-bright: '#36393f'
  surface-container-lowest: '#0b0e13'
  surface-container-low: '#191c21'
  surface-container: '#1d2025'
  surface-container-high: '#272a30'
  surface-container-highest: '#32353a'
  on-surface: '#e1e2e9'
  on-surface-variant: '#d6c3af'
  inverse-surface: '#e1e2e9'
  inverse-on-surface: '#2e3036'
  outline: '#9e8e7c'
  outline-variant: '#514535'
  surface-tint: '#ffb956'
  primary: '#ffca85'
  on-primary: '#452b00'
  primary-container: '#f2a93b'
  on-primary-container: '#664000'
  inverse-primary: '#835400'
  secondary: '#44e2cd'
  on-secondary: '#003731'
  secondary-container: '#03c6b2'
  on-secondary-container: '#004d44'
  tertiary: '#c1d3ff'
  on-tertiary: '#002e6a'
  tertiary-container: '#96b7ff'
  on-tertiary-container: '#004598'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffddb5'
  primary-fixed-dim: '#ffb956'
  on-primary-fixed: '#2a1800'
  on-primary-fixed-variant: '#633f00'
  secondary-fixed: '#62fae3'
  secondary-fixed-dim: '#3cddc7'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005047'
  tertiary-fixed: '#d8e2ff'
  tertiary-fixed-dim: '#aec6ff'
  on-tertiary-fixed: '#001a42'
  on-tertiary-fixed-variant: '#004395'
  background: '#111319'
  on-background: '#e1e2e9'
  surface-variant: '#32353a'
  raised: '#1C232C'
  border: '#2A323D'
  text-primary: '#E6EDF3'
  text-secondary: '#93A1B0'
  text-muted: '#64748B'
  profit: '#2DD4BF'
  loss: '#F2555A'
  info: '#4C8DFF'
  scrim: '#000000'
typography:
  kpi-value:
    fontFamily: JetBrains Mono
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  screen-title:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  section-title:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 22px
  body-default:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 20px
  body-medium:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 20px
  label-default:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 16px
  label-medium:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
  mono-data:
    fontFamily: JetBrains Mono
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 20px
  mono-label:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.5rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

# KAPITALIA MOBILE — DESIGN.md (надстройка над базовой системой)
## Platform
Native-style mobile app, portrait 390x844. NOT a responsive website.
No hover states, no mouse cursors, no desktop sidebars, no multi-column tables.
## inherited colors/fonts
bg #0E1116 | surface #151A21 | raised #1C232C | border #2A323D
text #E6EDF3 / #93A1B0 / #64748B | amber #F2A93B | profit #2DD4BF | loss #F2555A | info #4C8DFF
Inter for UI, IBM Plex Mono tabular for every number.
## Mobile type scale
body 15px | label 13px | section 17px | screen title 22px | KPI value 26px mono
Minimum readable size 13px. Never shrink numbers to fit — truncate labels instead.
## Touch & layout
Tap target >= 48x48. Row height 64. List item spacing 8. Screen padding 16.
Bottom tab bar 56px + 34px home-indicator inset. Top safe area 44px.
Primary actions live in the bottom 40% of the screen (thumb zone).
Destructive actions never adjacent to primary ones.
## Persistent shell (identical on every screen)
- TopBar 56px: back-or-logo left, screen title center, alerts bell right.
  Under it a 28px TickStrip: "Week 12 · Thu" + "Next tick 02:14:33" amber chip.
- BottomTabBar: Home, Enterprises, Market, Reports, More. Active = amber icon + label.
- FAB is forbidden. Primary action = full-width sticky bottom button above the tab bar.
## Mobile components (reuse, do not reinvent)
CardRow: title 15px + subtitle 13px muted + right-aligned mono value + delta chip + chevron.
KPI carousel: horizontally scrollable 160x96 cards, 2.3 visible, snap.
Segmented control: 3-5 tabs, sticky under the header, horizontally scrollable.
BottomSheet: rounded 16px top corners, drag handle, 3 heights (40% / 70% / 92%), scrim #000 60%.
ChipFilter row: horizontally scrollable outline chips, active = amber fill.
NumericKeypad sheet for money/quantity input, with +/- steppers and "MAX" shortcut.
Swipe actions on CardRow: left = archive/mute, right = quick order.
States: skeleton shimmer, empty, offline banner, "orders locked" banner.
## Rules
Never invent colors, fonts, radii. Reuse TopBar + TickStrip + BottomTabBar exactly.
Realistic mock data always. Money format "1 240 500 CR", deltas "+4.2%" / "-1.8%".