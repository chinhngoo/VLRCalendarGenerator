# 📅 VLR Calendar Generator

Automated iCalendar (ICS) feed generator for professional Valorant tournaments and teams' upcoming matches, sourced directly from [vlr.gg](https://www.vlr.gg).

[**👉 Visit the Home Page**](https://chinhngoo.github.io/VLRCalendarGenerator/)

The calendars regenerate **twice a day**.

### Quick Start
* **Subscribe:** Click any calendar link on the home page to add it to your preferred app.
* **Refresh Rate:** 
  * **Apple Calendar:** We recommend choosing at least a **Daily** refresh.
  * **Google Calendar:** Refreshes automatically every 8–24h (controlled by Google).

---

### Preview

| Subscribe to Feeds | Calendar View |
| :--- | :--- |
| <img width="540" alt="Subscription Preview" src="https://github.com/user-attachments/assets/841dc42b-c09f-4ede-87ac-d84cbfa454f8" /> | <img width="406" alt="Calendar Integration" src="https://github.com/user-attachments/assets/d997f5c5-61e4-471c-b70f-3033a5b9202d" /> |

---

## 🛠 Usage

Run the generator locally using the Swift Package Manager:

```bash
swift run vlr-calendar-generator [OPTIONS]
```

### Options

* **`-v, --verbose`** Enable verbose logging for detailed debugging.
* **`--pages <pages>`** Number of pages to scrape from vlr.gg (Default: `5`).
* **`--output-dir <output-dir>`** Directory for generated files (Default: `./Publish`).
* **`-h, --help`** Show help information.
