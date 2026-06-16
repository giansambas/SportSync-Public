# SportSync: A Cross-Platform Mobile Court Booking Application with Automated Payment Processing

## Overview

SportSync is a cross-platform mobile application developed to simplify and modernize the sports court reservation process. The platform allows users to discover sports facilities, view real-time court availability, reserve court schedules, and complete secure online payments through a single application.

The system eliminates the need for manual booking methods such as phone calls, social media messages, and manual payment verification by integrating real-time synchronization and automated payment processing. SportSync is designed for sports facilities, court operators, and players seeking a more efficient and convenient booking experience.

---

## Key Features

### User Authentication

* Secure Google Sign-In authentication
* User account and session management
* Personalized booking records

### Court Discovery

* Browse available sports courts
* View court details and pricing information
* Display court locations through Google Maps
* Real-time court availability monitoring

### Court Booking

* Select preferred court, date, and time slot
* Create reservations instantly
* Automatic slot validation before booking

### Payment Processing

* Secure online payments through PayMongo
* Support for GCash, Maya, and Card Payments
* Automated transaction verification
* Automatic booking confirmation upon successful payment

### Real-Time Synchronization

* Live availability updates using Firebase Firestore
* Prevention of double-booking conflicts
* Instant synchronization across all users

### Booking History

* View previous bookings
* Monitor upcoming reservations
* Access booking details and payment status

---

## Technology Stack

### Frontend

* Flutter
* Dart

### Backend

* Firebase Authentication
* Firebase Cloud Firestore
* Firebase Cloud Functions

### Payment Gateway

* PayMongo

### Maps and Location Services

* Google Maps API

### Development Tools

* Visual Studio Code
* Xcode
* Cursor
* Android Studio
* GitHub

---

## System Workflow

Court Discovery → Court Selection → Booking Creation → Payment Processing → Payment Verification → Booking Confirmation → Booking History

The system automatically synchronizes booking information in real time to ensure accurate court availability and prevent duplicate reservations.

---

## Installation Guide

### Clone the Repository

```bash
git clone <repository-url>
cd sportsync
```

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

Add the Firebase configuration files:

```text
google-services.json
GoogleService-Info.plist
```

### Run the Application

```bash
flutter run
```

---

## User Roles

### User

The user can:

* Sign in using Google Authentication
* Browse sports courts
* View court availability
* Create bookings
* Complete online payments
* View booking history
* Access court locations through Google Maps

---

## Database Collections

### users

Stores user account information and authentication details.

### courts

Stores court information, schedules, pricing, and availability.

### bookings

Stores reservation records, booking status, and user bookings.

### payments

Stores payment transaction records and payment status.

---

## Future Enhancements

* Court owner management portal
* Push notification support
* Booking reminders
* Facility analytics dashboard
* Multi-sport facility management
* Enhanced reporting and export features

---

## Developers

GMA - Matthew Danielle S. Jariol, Gian Edward J. Sambas, Astin John D. Tabora

System Analysis and Design

2026
