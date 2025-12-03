# Sandwich Shop App – Requirements

This document describes the features and tests for the Sandwich Shop app for Worksheet 6.  
It is updated as part of Prompt-Driven Development (PDD).

---

## Feature: Profile Screen (Worksheet 6 – Exercise 1)

### Description
Add a new screen where users can enter and/or view their personal details.  
This is a simple UI-only feature – no authentication or data persistence is required.

### Functional Requirements
- Create a new screen called `ProfileScreen`.
- The screen must contain three input fields:
  - **Name**
  - **Email**
  - (Optional) **Favourite sandwich**
- Add a **Save** button.
- Behaviour when Save is pressed:
  - If **Name** OR **Email** is empty → show an **error SnackBar**.
  - If both **Name** AND **Email** are filled → show a **success SnackBar**.  
    (Data is only stored in local state for this session.)
- Add a button at the bottom of the **OrderScreen** that navigates to `ProfileScreen`.

### Widget Tests Required
- Test that `ProfileScreen` renders all input fields and the Save button.
- Test that saving with empty Name/Email shows an error SnackBar.
- Test that saving with valid Name and Email shows a success SnackBar.
- Test that tapping the Profile button on `OrderScreen` opens `ProfileScreen`.

### AI Prompt Used
