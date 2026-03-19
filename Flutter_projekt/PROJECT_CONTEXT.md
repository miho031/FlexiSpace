# 📱 Project: Coworking Space Management App

## 🧾 Overview

This is a Flutter mobile application for managing a small coworking space.

The goal of the app is to:

- Allow members to reserve workspaces and meeting rooms
- Provide real-time availability of spaces
- Enable admins to manage reservations, users, and spaces
- Provide access to WiFi credentials and door access via QR code

---

## 🧱 Tech Stack

Frontend:

- Flutter

Backend:

- Supabase (PostgreSQL + Auth + Realtime)

State Management:

- Riverpod

Routing:

- go_router

---

## 🧩 Architecture

We are using a **Clean Architecture with feature-based structure**:

Layers:

- Presentation (UI)
- Application (state management with Riverpod)
- Domain (models and business logic)
- Data (Supabase repositories)

---

## 📂 Project Structure

lib/
core/
router/
theme/
utils/
widgets/

features/
auth/
spaces/
reservations/
admin/
profile/
guests/
resources/

---

## 👥 User Roles

### Member

- Register and login
- View spaces
- Make reservations
- View own reservations
- View WiFi credentials
- Generate QR code for door access
- Register guests

### Admin

- Manage users
- Approve/reject reservations
- Manage spaces
- View all reservations
- Monitor usage

---

## 🗄 Database Schema (Supabase)

Tables:

### profiles

- id (uuid)
- full_name
- role (member | admin)
- membership_active (boolean)

### spaces

- id
- name
- type (desk | office | meeting_room)
- capacity
- is_active

### reservations

- id
- user_id
- space_id
- start_time
- end_time
- status (pending | approved | rejected)

### resources

- id
- name
- type (wifi | printer | scanner)
- access_value

### guests

- id
- member_id
- guest_name
- visit_date
- approved

---

## ⚙️ Business Rules

- A user can only see their own reservations
- Admins can see and manage all data
- Reservations must not overlap (for approved bookings)
- Reservation must have valid time range (end > start)
- New reservations are created with status = "pending"
- Admin must approve reservation before it becomes active

---

## 🔄 Realtime Features

- Reservations should update in real-time using Supabase streams
- UI should automatically refresh when reservation status changes

---

## 🔐 Authentication

- Supabase Auth (email + password)
- On signup → create profile in `profiles` table
- Role-based access (member vs admin)

---

## 📱 Features to Implement

### Authentication

- Login
- Register
- Logout

### Spaces

- List all available spaces
- Show availability status

### Reservations

- Create reservation (date + time)
- Prevent overlapping bookings
- View personal reservations
- Real-time updates

### Admin Panel

- Approve/reject reservations
- Manage spaces (CRUD)
- Manage users

### Resources

- Show WiFi credentials
- Show printer/scanner info

### QR Code

- Generate QR code for door access
- Based on user ID or membership token

---

## 🎯 Coding Guidelines

- Use Riverpod for all state management
- Do not call Supabase directly from UI
- Use repository pattern for data access
- Keep UI clean and simple
- Separate logic from presentation

---

## 🚫 Avoid

- Using setState for global logic
- Mixing UI and database calls
- Hardcoding data
- Skipping validation

---

## ✅ Goal

Build a clean, scalable prototype suitable for a university project,
with emphasis on:

- good architecture
- working features
- clear UI
- real-time functionality
