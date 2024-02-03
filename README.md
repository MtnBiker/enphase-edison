# README

My attempt at viewing solar panel production which uses Enphase inverters. I am in Southern California and So Cal Edison (SCE) provides electricity otherwise. Just got in on NEM 2.0. Enphase and SCE both provide downloadable data. Our panels were installed Sept. 2023.

Beta, most of what is implemented works. The TODO list is long and evolving.

### Some setup notes

Rails 7.1.2, Ruby 3.3.0. Current at time of initial build
Look at Gemfile for added gems
Bootstrap for formatting

Postgres, but if views are supported I assume other databases will work. I originally implemented with Materialized Views but that is overkill for the limited data in this project.

Postgres timezone: America/Los_Angeles

Time and Date are middle of the period, e.g., per day is reported as noon.

Migrations need to be sorted because of false starts, but I think I've commented out all the false starts

Implementation notes is a partial log of trials and tribulations.

I installed Tailwind to try some formatting but so far haven't used it.

## Importing data

Data for both is in local time, but coded differently. 23 hours on day on start of DST and 25 hours on day of end of DST

Data for both are every 15 min. Up to 3/22/2023 SCE was hourly and column Received (to_sce) was added on 3/23. Enphase started in 10/12-13/2023, then off until 11/03/2023

### Importing Enphase data

Enphase provides data a month at a time. (Others have dug in deeper and tried to get data more directly from the Enphase hardware.)

From Enphase web page, hamburger, System, Reports: mail
File downloaded: <account_no>\_monthly_energy_report.csv and I rename with date added, eg. <account_no>\_monthly_energy_report2024.01.csv
Change header in downloaded file to: `datetime,enphase` (from `Date/Time,Energy Produced (Wh)`)
Import Enphase on any web page

### Importing SCE (aka Edison) data

SCE provides up to ~13 months of past data in 15-minute intervals. The data supplied changed in 2023; had to do with solar production, but happened before we were connected.

From SCE site, Data Sharing and Download from left menu, click Download, click > for account, Select dates—I'm doing month at time in general and CSV, click Download. I got two files—did I click twice? But if you overlap previous downloads the app won't allow duplicates.

In the downloaded file (or a copy of it) Delete initial headers, double quotes and empty lines (get two returns with empty line and replace with a single return).

Button on bottom of pages in this app to Import

2024.02.01 Materialized Views not auto updating

Note about downloaded SCE data:
SCE data is day by day in two parts: delivered and received so difficult to parse. See energy.rb
SCE is in kWh and is converted to Wh on adding to database. Enphase is in Wh, so had to pick one or the other and since data by the quarter hour or hour is <= 1 kWh, wWh is fractional, but wH is a "whole number" so bit easier to read

### License

No idea what I should do. Use at your own risk.
