<template>
  <div>
    <header>
      <h1>Hospital Reporting</h1>
      <nav>
        <router-link to="/reports/work-hours">Work Hours Report</router-link> |
        <router-link to="/reports/overtime">Overtime Report</router-link> |
        <router-link to="/reports/workload">Workload Report</router-link> |
        <router-link to="/reports/staff-preference"
          >Shift Preference Report</router-link
        >
        |
        <router-link to="/reports/leave">Leave Request Report</router-link> |
        <router-link to="/reports/monthly-shifts"
          >Shifts by Month Report</router-link
        >
      </nav>
    </header>

    <main>
      <router-view></router-view>
    </main>
  </div>
</template>

<script>
export default {
  name: "App",
};
</script>

<style>
body {
  margin: 0;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

#app {
  text-align: center;
  margin-top: 10px;
}
h1 {
  font-size: 3rem;
}

header {
  background-color: #fff;
  padding: 10px 20px;
  margin-bottom: 10px;
}

nav a {
  font-weight: bold;
  color: #2c3e50;
  margin: 0 10px;
  text-decoration: none;
}

nav a.router-link-exact-active {
  color: #42b983;
}

main {
  padding: 0 20px;
  margin-bottom: 20px;
}

footer {
  margin-top: 30px;
  padding: 10px 20px;
  background-color: #f8f8f8;
  border-top: 1px solid #eee;
  font-size: 0.9rem;
  color: #555;
}

.report-container {
  padding: 20px;
  max-width: 1000px;
  margin: 0 auto;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  align-items: center;
}

.report-title {
  text-align: center;
  color: #333;
  margin-bottom: 20px;
}

.filters-section {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 20px;
  padding: 15px;
  background-color: #f9f9f9;
  border: 1px solid #ddd;
  border-radius: 8px;
  justify-content: center;
  align-items: flex-end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  flex-basis: auto;
}

.filter-label {
  font-weight: bold;
  margin-bottom: 5px;
  color: #555;
  font-size: 0.9rem;
}

.filter-input {
  padding: 6px 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
  height: 30px;
  font-size: 0.9rem;
  min-width: 100px;
  box-sizing: border-box;
  background-color: #fff;
  color: #333;
}

.filter-input.select-input {
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
  background-color: #fff;
  color: #333;
}

.generate-button {
  padding: 8px 15px;
  background-color: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s ease;
  align-self: flex-end;
}

.generate-button:hover {
  background-color: #368e61;
}

.status-message {
  text-align: center;
  margin-top: 20px;
  font-size: 1.1rem;
  color: #555;
}

.error-message {
  color: #d9534f;
  font-weight: bold;
}

.report-table {
  margin-top: 20px;
  width: 100%;
  border-collapse: collapse;
}

.report-table th,
.report-table td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}

.report-table th {
  background-color: #f2f2f2;
  font-weight: bold;
}

.export-buttons {
  text-align: center;
  margin-bottom: 20px;
}

.export-button {
  padding: 10px 15px;
  margin: 0 5px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.3s ease;
}

.csv-button {
  background-color: #5cb85c;
  color: white;
}

.csv-button:hover {
  background-color: #4cae4c;
}

.pdf-button {
  background-color: #d9534f;
  color: white;
}

.pdf-button:hover {
  background-color: #c9302c;
}

.report-data-title {
  text-align: center;
  margin-top: 30px;
  margin-bottom: 15px;
  color: #333;
}

@media (max-width: 768px) {
  .filters-section {
    flex-direction: column;
    align-items: stretch;
  }

  .filter-group {
    width: 100%;
  }
}
</style>
