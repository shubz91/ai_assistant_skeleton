# UI Component Guidelines

> Replace this file with your organization's component patterns.

## Buttons

| Type | Usage | Style |
|------|-------|-------|
| Primary | Main actions | Dark bg, white text |
| Secondary | Secondary actions | Outlined border, transparent bg |
| Ghost | Tertiary, less emphasis | No border, text only |
| Destructive | Dangerous actions | Red bg or red text |

### Button Rules
- Always use clear action text — avoid generic "Click here"
- Minimum touch target: 44x44px on mobile
- Disabled: reduced opacity (0.5), no pointer events
- Loading state: replace text with spinner, maintain button width

## Forms

### Input Fields
- Label above input, never placeholder-only
- Visible focus ring for accessibility
- Error messages below affected field
- Success state: green border/check icon
- Required fields marked with asterisk (*)

## Cards

### Content Card
- Light background or white
- Clear visual hierarchy: tag/date → title → body → action

### Feature Card
- Larger format, may include image
- Prominent title and description

### Stats Card
- Key metric in large monospace font
- Label in small uppercase

## Dividers & Borders

| Type | Usage |
|------|-------|
| Major | 2px solid — section separators |
| Internal | 1px solid — within-section dividers |
| Accent | Colored border for highlighting |

## Spatial Principles
- **Consistent spacing**: Use a 4px or 8px grid
- **Generous whitespace**: Ample space between sections
- **Clear hierarchy**: Size and weight differentiate importance
- **Single accent rule**: One accent color per composition
- **Progressive disclosure**: Reveal complexity gradually

## Spacing Scale (8px base)
- `xs`: 4px
- `sm`: 8px
- `md`: 16px
- `lg`: 24px
- `xl`: 32px
- `2xl`: 48px
- `3xl`: 64px

> **To customize**: Update the styles and patterns above to match your design system.
