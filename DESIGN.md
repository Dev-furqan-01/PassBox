---
name: Obsidian Vault
colors:
  surface: '#0d141d'
  surface-dim: '#0d141d'
  surface-bright: '#333a44'
  surface-container-lowest: '#080f17'
  surface-container-low: '#151c25'
  surface-container: '#192029'
  surface-container-high: '#232a34'
  surface-container-highest: '#2e353f'
  on-surface: '#dce3f0'
  on-surface-variant: '#bcc9cd'
  inverse-surface: '#dce3f0'
  inverse-on-surface: '#2a313b'
  outline: '#869397'
  outline-variant: '#3d494c'
  surface-tint: '#4cd7f6'
  primary: '#4cd7f6'
  on-primary: '#003640'
  primary-container: '#06b6d4'
  on-primary-container: '#00424f'
  inverse-primary: '#00687a'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#ffb95f'
  on-tertiary: '#472a00'
  tertiary-container: '#e79400'
  on-tertiary-container: '#563400'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#acedff'
  primary-fixed-dim: '#4cd7f6'
  on-primary-fixed: '#001f26'
  on-primary-fixed-variant: '#004e5c'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#0d141d'
  on-background: '#dce3f0'
  surface-variant: '#2e353f'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.025em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.02em
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: -0.015em
  body-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 21px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: -0.005em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-code-lg:
    fontFamily: JetBrains Mono
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.08em
  label-code-md:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 17px
    letterSpacing: 0.04em
  label-badge:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 12px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style
The design system embodies unyielding digital sovereignty, clinical precision, and instant visual reassurance. Designed for technical professionals, security-conscious executives, and power users, the UI avoids playful tropes in favor of an authoritative, high-density HUD aesthetic. 

The aesthetic is modern technical minimalism infused with subtle tactile realism:
- **Surface Integrity:** Deep, noise-free abyssal backdrops combined with multi-layer obsidian cards create optical discipline.
- **Precision Engineering:** Hairline borders, precise mono-spaced data alignments, and high-frequency tactile micro-feedback convey total control over encrypted credentials.
- **Calibrated Feedback:** Zero latency perceived response, stark visual status transitions (Emerald, Amber, Coral), and deliberate focal points using electric security cyan.

## Colors
The system relies on a high-contrast dark foundation engineered for low-light legibility and battery efficiency on OLED displays. 

- **Primary Accent (Electric Cyan `#06B6D4` / `#0EA5E9`):** Reserved for active biometric engagement, primary action triggers, multi-factor confirmations, and focus states.
- **Status Tiers:**
  - **Secure / Verified (`#10B981` Emerald):** Represents military-grade entropy, verified vaults, and active biometric sync.
  - **Caution / Attention (`#F59E0B` Amber):** Denotes expiring secrets, reused passwords, and missing multi-factor auth.
  - **Breached / Critical (`#EF4444` Coral Red):** Flags compromised credentials found in public breaches and exposed seeds.
- **Surfaces & Neutral Architecture:**
  - **Base Canvas (`#0B0F17`):** The foundational substrate.
  - **Card Layer (`#111827`):** Raised container surface.
  - **Stroke / Hairline Boundary (`#1F2937` & `#374151`):** Structural division without visual heaviness.
  - **Text Layers:** Primary labels shine in crisp `#F9FAFB`, secondary telemetry sits quietly in muted slate `#9CA3AF`.

## Typography
Typography is split into two disciplined roles:
1. **Primary Interface (`Inter`):** Renders navigation, titles, and body content with tight letter tracking and low line heights to maximize visible items per screen viewport without feeling cramped.
2. **Data & Security Tokens (`JetBrains Mono`):** Applied to TOTP codes, password masks, private keys, hexadecimal hashes, and security tags. The strict tabular alignment eliminates width shifting during countdown timers and live field generation.

## Layout & Spacing
The layout follows a fluid single-column mobile-first grid, built to present maximum relevant data inside the thumb zone.

- **System Spacing:** Employs an exact 4px sub-grid with base unit steps (`4px`, `8px`, `12px`, `16px`, `24px`). Vertical rhythm is deliberately compressed to display dense credentials (e.g., identity, username, password, two-factor badge) in compact list items.
- **Margins & Safe Zones:** Canvas borders enforce a strict 16px lateral safety margin. Nested elements within cards maintain internal padding of 12px or 16px.
- **Section Breaks:** Visual grouping relies on 12px separation between list groups, prioritizing hairline separators over whitespace gutters.

## Elevation & Depth
Elevation abandons traditional drop shadows in favor of ambient luminescence and tonal layering. 

- **Layer 0 (Canvas):** `#0B0F17` pure solid background.
- **Layer 1 (Card/Container):** `#111827` surface framed with a 1px border of `#1F2937`.
- **Layer 2 (Floating Action/Modals):** `#182234` surface with a 1px border of `#374151` paired with a directional glow: `0 8px 24px -4px rgba(6, 182, 212, 0.12)`.
- **Active State Glow:** Sensitive fields on focus emit a tight, controlled ring `0 0 0 1px #06B6D4, 0 0 12px rgba(6, 182, 212, 0.25)`.

## Shapes
Containers leverage an intentional contrast between generous outer frames and technical inner components:
- **Major Surfaces & Floating Sheets:** Use `rounded-2xl` (16px) for an approachable, handheld perimeter.
- **Inner Interactive Tokens & Fields:** Scale down to `rounded-lg` (8px) for buttons, text fields, and micro-cards, establishing crisp modularity.
- **Micro Badges & Status Pills:** Full circular pill corners (`9999px`) provide distinct silhouette contrast against rectangular credential items.

## Components

### Buttons
- **Primary Action:** Solid Electric Cyan background (`#06B6D4`), dark slate text (`#082F49`), weight 600, height 44px, `rounded-xl`. High-contrast focus state with matching cyan edge bloom.
- **Secondary / Ghost Action:** Hairline border (`#374151`), transparent background, light slate text (`#F9FAFB`), height 44px, `rounded-xl`. On tap: background transitions to `#1F2937`.

### Input Fields & Secret Concealers
- **Structure:** 44px uniform height, dark backdrop (`#0F172A`), structural 1px border (`#1F2937`).
- **Interactive Security Features:** Monospace font for passwords, instant reveal toggle button (eye icon), integrated entropy meter displayed as a 2px full-width colored edge at the bottom of the input container.

### Credential Cards
- **Structure:** `#111827` background, 1px border of `#1F2937`, `rounded-2xl`, internal padding 12px.
- **Data Arrangement:** Left-aligned 36px circular favicon/service logo, followed by two-tier text: Service Name (`headline-sm`) stacked above Username/Email (`body-sm`). Right-aligned slot accommodates 2FA live countdown rings or micro-badges.

### Micro-Badges & Status Tags
- **Entropy & Health Pills:** Compact padding (2px vertical, 8px horizontal), height 20px, `rounded-full`. 
- **States:** 
  - Verified: emerald text (`#10B981`) on `#064E3B` (20% opacity).
  - Weak: coral text (`#EF4444`) on `#7F1D1D` (20% opacity).
  - Warning: amber text (`#F59E0B`) on `#78350F` (20% opacity).
- **Typography:** Rendered strictly in `label-badge` (`JetBrains Mono`, 10px uppercase).

### TOTP / OTP Displays
- **Design:** Centered container displaying 6-to-8 digit blocks in `label-code-lg` with an accompanying SVG circular progress timer depleting smoothly across a 30-second window. Single-tap copies with haptic acknowledgement and a momentary "COPIED" cyan pill replacement.