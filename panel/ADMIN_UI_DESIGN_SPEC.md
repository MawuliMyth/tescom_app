# TESCON Admin UI — Portable Design Specification

This specification describes the existing TESCON administration interface in a framework-neutral way. It can be implemented in React, Flutter, Vue, Angular, Laravel, or another UI system.

## 1. Visual direction

The interface is a clean, light operations dashboard. It combines a deep indigo brand color with restrained teal and yellow accents. Surfaces are white, corners are compact, borders are visible but soft, and shadows are subtle. The overall impression should be professional, calm, and information-dense without feeling crowded.

Use Lucide-style outline icons at 16–20 px. Use Inter, or a modern system sans-serif fallback.

## 2. Design tokens

### Color palette

| Token | Value | Usage |
|---|---:|---|
| Brand primary | `#34368C` | Primary buttons, active navigation, focus, charts |
| Brand primary hover | `#292B75` | Primary hover state |
| Brand tint | `#EFF1FF` | Active navigation and indigo icon backgrounds |
| Accent teal | `#18BFC6` | Charts and secondary visual accent |
| Success teal | `#0F9F8F` | Success controls and positive states |
| Success tint | `#E7FBF7` | Success badge/card background |
| TESCON yellow | `#F2C94C` | Brand accent and chart category |
| Page background | `#F6F8FB` | Main application canvas |
| Input background | `#F8FAFC` | Search and quiet controls |
| Surface | `#FFFFFF` | Sidebar, top bar, cards, modals |
| Primary text | `#111827` | Headings and important values |
| Secondary text | `#64748B` | Supporting text and metadata |
| Muted text | `#94A3B8` | Labels and placeholders |
| Border | `#DFE5ED` | Cards and panels |
| Divider | `#E2E8F0` | Layout separators |
| Danger | `#B42318` | Destructive actions |
| Danger tint | `#FFF7F7` | Destructive control background |

### Shape, depth, and spacing

- Base corner radius: `8px`
- Pills and avatars: `999px`
- Card border: `1px solid #DFE5ED`
- Card shadow: `0 10px 26px rgba(15, 23, 42, 0.05)`
- Modal shadow: `0 18px 42px rgba(15, 23, 42, 0.14)`
- Base spacing unit: `4px`
- Common gaps: `8px`, `12px`, `16px`, `18px`, `24px`, `28px`
- Button minimum height: `40px`
- Input height: approximately `48–52px`

### Typography

- Font: `Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`
- Page title: `30px`, bold/extra-bold
- Card KPI: `28–34px`, extra-bold
- Section title: `20px`, bold
- Body: `13–16px`
- Eyebrow/section label: `11–12px`, weight `900`, uppercase
- Navigation: `14px`, bold

## 3. Desktop application shell

Use a two-column full-height shell:

- Left sidebar: `278px`, white background, `1px` right divider, `20px 12px` padding.
- Main canvas: flexible width, `22px 28px 32px` padding, `#F6F8FB` background.
- Top bar: white, at least `64px` high, full main-column width, bottom divider.

### Sidebar

At the top, show the TESCON logo in a `42 × 42px` bordered tile. Beside it show:

- `TESCON` in 20 px indigo bold text
- `Admin Panel` in 12 px muted text

Navigation is divided by uppercase section labels. Each item is at least `42px` high, left-aligned, with an 18 px outline icon and label. The active item uses `#EFF1FF` background and `#34368C` text. Hover uses `#F1F5F9`. Place Logout at the bottom.

### Top bar

The left side contains a module search field up to `520px` wide. Include search icon, input, optional clear icon, and an `Enter` keyboard hint. The right side contains notification and settings icon buttons, followed by a divider and admin identity: circular initials avatar, name, and role.

### Page heading

Below the top bar, show an uppercase `Operations Console` eyebrow and the current 30 px page title. On the right, show the current date in a bordered compact control with a calendar icon.

## 4. Information architecture

### General

- Dashboard

### Management modules

- Admin Users
- Members
- Executives
- Chapters
- News
- Events
- Announcements
- History
- Jobs
- Job Applicants
- Polls
- Chat Rooms
- Notifications
- Contact Inbox
- Activity Logs

Hide modules the current admin cannot read. Also hide create, edit, and delete actions independently based on permissions.

## 5. Dashboard page template

The dashboard uses an 18 px grid gap and contains:

1. Three KPI cards across the first row. Each card is white, at least `112px` high, with a 34 px tinted icon tile, a large value, a short label, and optional positive trend badge.
2. Analytics row: a wide seven-day activity bar chart and a narrower donut/category breakdown card.
3. A responsive grid of module-count cards. Cards contain an icon, 34 px count, and module label; they navigate to the module on click.
4. A recent-records activity card with divided rows and timestamps.

Use indigo as the dominant data color, teal as the secondary category, and yellow as the tertiary category.

## 6. Records/list page template

Use one large white table panel:

- Header: record count and module title on the left; search, filter, and create button on the right.
- Optional filter strip: wrap select controls, each with an uppercase 11 px label.
- Table/list rows: thumbnail or icon, primary title, secondary description, metadata/status chips, and right-aligned action buttons.
- Actions: view where applicable, edit with a neutral icon button, delete with a pale-red icon button.
- Footer: total range, rows-per-page select, previous/next controls.

On an empty list, center a 44 px indigo-tinted icon tile, a concise title, supporting text, and an optional create action.

## 7. Create/edit pattern

Open forms in a centered modal over a dark translucent backdrop with `8px` blur.

- Modal width: up to `920px`
- Maximum height: `86vh`
- White surface, 8 px radius
- Header: uppercase context label, 20 px form title, close icon
- Body padding: `28px`
- Form: two-column grid with 16 px gaps
- Textareas, media uploaders, and long content span both columns
- Sticky footer: Cancel and primary Save/Create actions

Inputs use a 1 px `#CFD8E3` border, 8 px radius, and `13px 14px` padding. Focus changes only the border to brand indigo. Labels are 13 px and extra-bold.

### Specialized controls

- Image upload: bordered drag-and-drop card with preview, Browse, Remove, and upload state.
- Gallery upload: multiple thumbnails with per-image remove controls; maximum ten images.
- Date/time: segmented date and time control with custom calendar/time popovers.
- Status: select control and compact colored status chips in records.
- Checkbox: 18 px checkbox aligned with a bold label.

## 8. Feedback and states

- Loading: skeleton shimmer using `#E8EDF5 → #F8FAFC → #E8EDF5`.
- Success: teal text/tint.
- Warning: yellow/amber text/tint.
- Error and destructive: dark red with pale-red tint.
- Disabled: reduce opacity to about `0.45` and use a not-allowed cursor.
- Refresh: support pull-to-refresh on touch interfaces with a small pill-shaped progress indicator.
- Modal entrance: 180 ms fade, slight upward movement, and scale from `0.985` to `1`.
- Standard hover/focus transitions: about `160–180ms`.

## 9. Authentication page

Center a login card up to `420px` wide on a pale gray background. Add a soft indigo radial gradient in the top-left. The card uses the standard white surface, border, 8 px radius, and shadow. Center a `70 × 70px` TESCON logo above the form.

## 10. Responsive behavior

At widths below approximately `1180px`:

- Collapse the application shell to one column.
- Place the sidebar above content.
- Convert sidebar navigation into an auto-fitting grid of items.
- Stack KPI cards, analytics columns, table headers, and page-heading controls.
- Make search and table tools full width.
- Make date/time segments vertical.
- Use auto-fitting module cards with a minimum width near `150px`.

At phone widths near `720px`, make detail layouts one column, widen chat bubbles to about 92%, and allow modals to use nearly the full viewport.

## 11. Reusable component inventory

Implement these primitives before building screens:

- `AppShell`, `Sidebar`, `TopBar`, `PageHeading`
- `Button`, `IconButton`, `SearchInput`, `Avatar`
- `Card`, `MetricCard`, `ModuleCountCard`, `ChartCard`
- `TablePanel`, `RecordRow`, `StatusBadge`, `Pagination`
- `Modal`, `FormGrid`, `TextField`, `SelectField`, `TextArea`, `Checkbox`
- `DateTimePicker`, `ImageUploader`, `GalleryUploader`
- `EmptyState`, `Skeleton`, `Notice/Toast`, `ConfirmDialog`

## 12. Implementation rule of thumb

Keep content pages data-driven. Define each module with its label, icon, fields, status options, and allowed actions, then render the shared records and editor templates. This preserves the same visual system across every admin module and makes it easy to adapt the design to a different backend.
