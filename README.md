# BDAirways Flight Fare Predictor

Web app for the IEEE paper "A Multi-Target Machine Learning Analysis of Predictability in Bangladeshi Domestic Flight Booking Data".

**Live demo:** https://bd-domastic--airline.web.app

## What it does
- Estimates the total fare for a domestic flight in Bangladesh
- Shows the paper's results: best model per target, train vs test, chi-square, and comparison with other studies

## Key results
- Total Fare: Random Forest, test R² = 0.890
- Departure Airport: XGBoost, F1 = 0.688
- Cabin Class, Airline, Booking Source: not reliably predictable

## Note
Fare estimates come from a linear model (R² = 0.875). The paper's best model is a Random Forest (R² = 0.890).

## Tech
Flutter (web), Firebase Hosting, Cloud Firestore

## Authors
Md. Akash Sheikh. Supervisor: Md. Tarek Habib. Independent University, Bangladesh.
