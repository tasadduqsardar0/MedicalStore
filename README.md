# Tariq Medical Store

A Flutter (Material 3) pharmacy management front-end application for **Tariq Medical Store**, Main Bazaar, Hujra Shah Muqeem.

## Features & Modules
- **Authentication & Access**: First-run owner setup, one-time recovery code, login, password reset with recovery code regeneration, and inactivity auto-logout.
- **Dashboard & Notifications**: Today's sales, owner-only today's profit, low stock and near-expiry counts, recent sales, and notification alerts (`All`, `Stock`, `Expiry`).
- **Inventory Management**: Medicines catalog, categories, batch tracking with expiry enforcement, FEFO stock deduction, packs + loose unit formatting (`StockRules`), stock adjustments, disposal, generic substitutes search, stock audit, and barcode shelf labels.
- **Billing & Sales**: Fast POS checkout with optional customer name (`Walk-in Customer` default), pack/loose unit selection, flat discounts, Cash / Card / Split payments, 80 mm receipt preview, held bills, sales history, invoice detail, sales returns, and barcode scanner.
- **Purchasing & Suppliers (Owner Only)**: Suppliers list & ledger, purchase orders (`PO-2001`), Goods Received Notes (GRN), purchase returns, and supplier payments.
- **Prescriptions & Controlled Drugs**: Prescriptions (`RX-5001`), doctors directory, and automatic Controlled Drug Register entries.
- **Finance, Reports & Settings (Owner Only)**: Cash register open/close, daily closing summary, expenses, profit & loss, sales/purchase/stock/expiry/profit/staff performance reports, staff user management, store settings, backup/restore UI, activity log, and Developer Tools (role switcher & demo data loader).

## Architecture
- `lib/core/` — Theme, colors, stock rules, formatters, validators, and `RoleGuard`
- `lib/data/` — Models and abstract + in-memory mock repositories (`Mock*Repository`)
- `lib/providers/` — State management using `Provider`
- `lib/widgets/` — Reusable UI components (`AppDrawer`, `AlertChip`, `EmptyState`, etc.)
- `lib/screens/` — Module-organized screens

## Verification
```bash
dart analyze lib test
flutter test
flutter build apk --release
```
