# Traffic_Queue_Modelling-_SH1_Greenlane_Interchange
Queuing theory analysis of peak-hour traffic congestion at SH1 Greenlane Interchange, Auckland, using real-world traffic camera data and M/M/1 &amp; M/M/2 models simulated in SAS.

## 📌 Overview

This project applies **queuing theory** to model and analyse traffic congestion at the **SH1 Greenlane Interchange ramp** in Auckland, New Zealand, during morning peak hours (8:00–8:02am, 14 May 2024). Real traffic snapshots from the Waka Kotahi NZ Transport Agency camera were used to calculate arrival and service rates, which were then used to fit an **M/M/1 queuing model**, identify bottlenecks, and propose an improved **M/M/2 solution** — validated through SAS simulation.

---

## 📂 Repository Structure

```
├── 1.jpg        # Traffic snapshot — 8:01:03 am (original)
├── 1_1.jpg      # Traffic snapshot — 8:01:03 am (annotated, cars highlighted)
├── 2.jpg        # Traffic snapshot — 8:01:46 am (original)
├── 2_2.jpg      # Traffic snapshot — 8:01:46 am (annotated, cars highlighted)
└── SAS_code.sas # Simulation code (M/M/2 model)
```

---

## 📊 Data Collection

- **Camera**: SH1 Greenlane Interchange — Waka Kotahi NZTA Camera 137
- **Date/Time**: 14 May 2024, 8:01:03 am and 8:01:46 am
- **Method**: Two sequential snapshots taken 43 seconds apart during peak hour; 5 reference cars visible in both images were used to calculate cars served and new arrivals

| Snapshot | Time | Cars in System | Cars in Queue |
|---|---|---|---|
| Picture 1 | 8:01:03 am | 23 | 21 |
| Picture 2 | 8:01:46 am | 21 | 19 |

**Calculated Parameters:**

| Parameter | Value |
|---|---|
| Time interval | 43 sec = 0.72 min |
| Reference cars (seen in both images) | 5 |
| Cars served | 18 |
| New arrivals | 16 |
| Arrival rate λ | 22.5 cars/min |
| Service rate μ | 25.35 cars/min |

---

## ⚙️ Queuing Model

### M/M/1 Model (Existing System)

- **M** — Poisson/Markovian arrival process
- **M** — Exponential/Markovian service times
- **1** — Single server (both lanes treated as one queue)
- **Queue discipline**: FIFO (First In, First Out)
- **Calling population**: Infinite

**M/M/1 Results:**

| Metric | Value | Description |
|---|---|---|
| ρ (Utilisation) | 0.88 | 88% — system near capacity |
| P₀ | 0.12 | 12% probability of empty system |
| L | 7.33 | Expected vehicles in system |
| Lq | 6.45 | Expected vehicles in queue |
| W | 0.35 min (21 sec) | Expected time in system |
| Wq | 0.28 min (17 sec) | Expected wait time in queue |

⚠️ System is in **steady state** (ρ < 1), but utilisation is high — indicating significant congestion risk during sustained peak hours.

---

## 💡 Proposed Solution — M/M/2 Model

Instead of treating both lanes as a single server, allow **2 vehicles per lane** to pass on each green light — effectively creating **two parallel servers**.

**M/M/2 Results:**

| Metric | M/M/1 | M/M/2 | Improvement |
|---|---|---|---|
| ρ | 0.88 | **0.44** | **−50%** |
| P₀ | 0.12 | **0.85** | +608% |
| L | 7.33 | **1.95** | **−73%** |
| Lq | 6.45 | **1.07** | **−83%** |
| W | 0.35 min | **0.086 min** | **−75%** |
| Wq | 0.28 min | **0.047 min** | **−83%** |

✅ No infrastructure changes required — only updated lane markings and signage.

---

## 🖥️ SAS Simulation

The M/M/2 model was simulated in SAS over 20 iterations using Poisson arrivals (λ = 22.5) and Exponential service times (μ = 25.35). Only steady-state iterations (ρ < 1) were retained.

```sas
DATA X;
  CALL streaminit(123);
  DO i = 1 to 20;
    lamda = rand("Poisson", 22.5);
    mu    = rand("EXPONENTIAL", 25.35);
    rho   = lamda / (2 * mu);
    P     = 1 / (1 + (rho**2 / (2*(1 - rho))));
    Lq    = (((lamda/mu)**2 * rho) / (2*(1-rho)**2)) * P;
    Wq    = Lq / lamda;
    W     = Wq + (1/mu);
    L     = Lq + (lamda/mu);
    IF rho <= 1 THEN OUTPUT;
  END;
RUN;

proc means data=X; var rho P Lq Wq W L; run;
```

**Simulation Summary (8 steady-state iterations):**

| Metric | Mean | Std Dev | Min | Max |
|---|---|---|---|---|
| ρ | 0.308 | 0.175 | 0.137 | 0.566 |
| P₀ | 0.906 | 0.109 | 0.730 | 0.989 |
| Lq | 0.386 | 0.587 | 0.007 | 1.406 |
| Wq | 0.014 | 0.021 | 0.0003 | 0.053 |
| W | 0.041 | 0.032 | 0.014 | 0.101 |
| L | 1.001 | 0.925 | 0.282 | 2.538 |

---

## 🔧 Requirements

- **SAS** (Base SAS + PROC SGPLOT)
- Traffic camera snapshots from [Waka Kotahi NZTA](https://www.journeys.nzta.govt.nz/traffic-cameras/auckland/)

---

## 📄 References

- Waka Kotahi NZ Transport Agency. (2024). *Traffic cameras — Auckland*. https://www.journeys.nzta.govt.nz/traffic-cameras/auckland/
- Gross, D., & Harris, C. M. (1998). *Fundamentals of Queueing Theory* (3rd ed.). Wiley.
