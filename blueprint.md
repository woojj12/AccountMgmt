# Personal Allowance Management App Blueprint

## Overview

This document outlines the plan and features for a personal allowance management application built with Flutter. The app allows users to track their income and expenses locally on their device.

## Core Features (Version 1)

*   **Data Storage:** All transaction data is stored locally on the device using an SQLite database. No internet connection or user login is required.
*   **Transaction Recording:** Users can add, edit, and view income and expense transactions.
*   **Dashboard:** The main screen displays a summary of the user's financial status, including:
    *   Current Balance (Total Income - Total Expenses)
    *   Total Income (cumulative)
    *   Total Expenses (cumulative)
*   **Transaction History:** A chronological list of all recorded transactions is displayed on the main screen.
*   **Categorization:** Transactions are categorized for better financial tracking.

## Style and Design

*   **Theme:** Uses Material 3 design principles for a modern and clean look.
*   **Color Coding:**
    *   Income amounts are displayed in a shade of **green**.
    *   Expense amounts are displayed in a shade of **red**.
*   **Layout:** A simple and intuitive single-screen layout with clear information hierarchy and floating action buttons for quick access to core actions.

## Current Development Plan

**Objective:** Build the initial version of the Personal Allowance Management App.

**Steps:**

1.  **Project Setup:**
    *   Add necessary dependencies: `sqflite` (database), `provider` (state management), `intl` (date formatting). (Completed)

2.  **Database and Model:**
    *   Create a `transaction.dart` model file to define the structure of a transaction (id, type, amount, category, date, description).
    *   Create a `database_helper.dart` file to manage all SQLite database operations (initialize DB, create table, CRUD operations).

3.  **State Management:**
    *   Create a `transaction_provider.dart` file.
    *   This provider will use the `DatabaseHelper` to interact with the database.
    *   It will manage the state of the transaction list, total income, total expense, and balance.
    *   It will notify listeners (the UI) of any data changes.

4.  **User Interface (UI):**
    *   **Update `main.dart`:**
        *   Set up `ChangeNotifierProvider` to make the `TransactionProvider` available to the widget tree.
        *   Build the main screen (`MyHomePage`).
        *   Design the summary card widget to display balance, income, and expenses.
        *   Create the transaction list view using `ListView.builder`.
        *   Implement the two Floating Action Buttons for adding income and expenses.
    *   **Create `add_edit_transaction_dialog.dart`:**
        *   Build a reusable dialog widget for both adding and editing transactions.
        *   The dialog will contain a form with fields for amount, category, date (using a date picker), and notes.

5.  **Integration and Logic:**
    *   Connect the UI to the `TransactionProvider` to display and update data.
    *   Implement the logic to show the add/edit dialog when buttons or list items are pressed.
    *   Ensure the summary and transaction list update automatically when a transaction is saved or modified.
    *   Format dates and currency appropriately.

