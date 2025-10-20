# retail_demand
🧠 AI Retail Demand Forecasting System

An intelligent retail demand forecasting platform powered by AI, built to help businesses predict demand trends, optimize inventory, and gain actionable insights — all in real time.

---

🚀 Features

- 📈 AI-Powered Forecasting: Uses XGBoost to predict future retail demand with high accuracy.  
- 📊 Dynamic Visualizations: Interactive charts and tables for prediction results.  
- ☁️ Seamless Cloud Integration: Upload and store CSV data via Supabase Storage.  
- ⚡ Real-Time Insights: Get dynamic market summaries and forecast accuracy reports.  
- 📱 Cross-Platform App: Built with Flutter for smooth mobile experience.  
- 🧩 Fast & Scalable Backend: Powered by FastAPI with RESTful endpoints.

---

🧰 Tech Stack

| Layer | Technology |
|-------|-------------|
| Frontend | Flutter (Riverpod, FL Chart) |
| Backend | FastAPI (Python) |
| Machine Learning | XGBoost |
| Database / Storage | Supabase |
| Deployment | Supabase + FastAPI Cloud |
| Language | Dart / Python |

---

🧮 How It Works

1. Upload CSV Data – Users upload retail data through the Flutter app.  
2. Predict Demand – The backend (FastAPI + XGBoost) processes and forecasts future demand.  
3. Display Insights – Results are visualized in the app with charts, tables, and accuracy metrics.  

---

🧠 AI Model

The prediction engine uses XGBoost, trained on historical retail datasets to forecast product demand.  
The model returns:
- Actual values  
- Predicted values  
- Associated dates  
- Forecast accuracy (MAPE)

---

 🧱 Project Structure

bash
├── flutter_app/
│   ├── lib/
│   ├── screens/
│   ├── providers/
│   └── widgets/
├── backend/
│   ├── main.py          # FastAPI app
│   ├── model.py         # XGBoost loading & prediction
│   ├── utils/
│   └── routes/
└── README.md

## Getting Started


This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
