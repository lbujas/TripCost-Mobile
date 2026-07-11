# TripCost

TripCost is a Flutter mobile application that helps drivers estimate the total cost of travelling across Europe.

The application combines fuel costs, motorway tolls, vignettes and ferry prices into a single calculation, allowing users to compare travel scenarios before starting their journey.

**Google Play**

https://play.google.com/store/apps/details?id=pl.tripcost.app

---

## Features

- Fuel cost calculation based on vehicle consumption
- Current fuel prices for multiple European countries
- Toll roads and motorway fees
- European vignette support
- Ferry pricing
- One-way and round-trip calculations
- Vehicle management
- Multi-currency support
- Multi-language interface
- Automatic data updates from a custom backend API

---

## Technology Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Mobile application |
| Dart | Programming language |
| FastAPI | Backend API |
| REST API | Data exchange |
| Hive | Local storage |
| JSON | Data source |
| Git | Version control |

---

## Project Structure

```
lib
├── core
├── data
├── domain
├── presentation
├── services
├── widgets
└── utils
```

The project follows a layered architecture separating business logic, data access and presentation.

---

## Supported Languages

- Polish
- English
- German
- Croatian
- Czech
- Slovak
- Hungarian

---

## Backend

TripCost uses a custom backend hosted on a VPS.

The backend provides:

- fuel prices
- vignette data
- toll information
- ferry data
- application updates

---

## Screenshots

Screenshots will be added soon.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/lbujas/TripCost-Mobile.git
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## Roadmap

Planned improvements:

- route optimisation
- additional ferry operators
- more European toll systems
- Apple CarPlay / Android Auto improvements
- travel statistics

---

## Author

Łukasz Bujas

Flutter Developer

GitHub: https://github.com/lbujas