<template>
  <div class="report-container">
    <h2 class="report-title">Work By Month Report</h2>

    <div class="filters-section">
      <div class="filter-group">
        <label for="startMonth" class="filter-label">Start Month:</label>
        <input
          type="month"
          id="startMonth"
          v-model="startMonth"
          class="filter-input"
        />
      </div>

      <div class="filter-group">
        <label for="endMonth" class="filter-label">End Month:</label>
        <input
          type="month"
          id="endMonth"
          v-model="endMonth"
          class="filter-input"
        />
      </div>

      <div class="filter-group">
        <label for="role" class="filter-label">Role:</label>
        <select id="role" v-model="role" class="filter-input select-input">
          <option value="">--Select Role--</option>
          <option
            v-for="roleOption in roleOptions"
            :key="roleOption.value"
            :value="roleOption.value"
          >
            {{ roleOption.text }}
          </option>
        </select>
      </div>

      <div class="filter-group">
        <label for="department" class="filter-label">Department:</label>
        <select
          id="department"
          v-model="department"
          class="filter-input select-input"
        >
          <option value="">--Select Department--</option>
          <option
            v-for="deptOption in departmentOptions"
            :key="deptOption.value"
            :value="deptOption.value"
          >
            {{ deptOption.text }}
          </option>
        </select>
      </div>

      <div class="filter-group">
        <label for="shiftType" class="filter-label">Shift Type:</label>
        <select
          id="shiftType"
          v-model="shiftType"
          class="filter-input select-input"
        >
          <option value="">--Select Shift Type--</option>
          <option value="regular">Regular</option>
          <option value="on-call">On-Call</option>
        </select>
      </div>

      <div class="filter-group">
        <label for="shiftTime" class="filter-label">Shift Time:</label>
        <select
          id="shiftTime"
          v-model="shiftTime"
          class="filter-input select-input"
        >
          <option value="">--Select Shift Time--</option>
          <option
            v-for="shiftTimeOption in shiftTimeOptions"
            :key="shiftTimeOption.value"
            :value="shiftTimeOption.value"
          >
            {{ shiftTimeOption.text }}
          </option>
        </select>
      </div>

      <button @click="fetchReport" class="generate-button">
        Generate Report
      </button>
    </div>

    <div v-if="loading" class="status-message">Loading...</div>
    <div v-if="error">{{ error }}</div>

    <h3 v-if="reportData.length > 0" class="report-data-title">
      Raw Monthly Shift Data
    </h3>
    <ReportTable
      v-if="reportData.length > 0"
      :columns="columns"
      :data="reportData"
      class="report-table"
    />
    <div v-if="reportData.length > 0" class="chart-container">
      <h3 class="report-data-title">Monthly Shift Assignments</h3>
      <Bar
        v-if="chartData.labels.length > 0"
        :data="chartData"
        :options="chartOptions"
        :width="400"
        :height="400"
      />
      <p v-else>Processing chart data...</p>
    </div>
    <div v-else-if="!loading && !error" class="status-message">
      No data found for the selected criteria.
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import { fetchMonthlyShiftAssignmentsReport } from "../api/reportService";
import ReportTable from "../components/ReportTable.vue";

import { Bar } from "vue-chartjs";
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
} from "chart.js";

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
);

export default {
  name: "WorkByMonthView",
  components: {
    ReportTable,
    Bar,
  },
  setup() {
    const startMonth = ref("");
    const endMonth = ref("");
    const role = ref("");
    const department = ref("");
    const shiftType = ref("");
    const shiftTime = ref("");

    const roleOptions = ref([
      { value: "Nurse", text: "Nurse" },
      { value: "Doctor", text: "Doctor" },
      { value: "Resident", text: "Resident" },
    ]);

    const departmentOptions = ref([
      { value: "Emergency Medicine", text: "Emergency Medicine" },
      { value: "Internal Medicine", text: "Internal Medicine" },
      { value: "Cardiology", text: "Cardiology" },
      { value: "Pediatrics", text: "Pediatrics" },
      { value: "Obstetrics and Gynecology", text: "Obstetrics and Gynecology" },
      { value: "Neurology", text: "Neurology" },
      { value: "General Surgery", text: "General Surgery" },
      { value: "Orthopedics", text: "Orthopedics" },
      { value: "Anesthesiology", text: "Anesthesiology" },
      { value: "Radiology", text: "Radiology" },
      { value: "Pathology", text: "Pathology" },
      { value: "Psychiatry", text: "Psychiatry" },
      { value: "Dermatology", text: "Dermatology" },
      { value: "Oncology", text: "Oncology" },
      { value: "Endocrinology", text: "Endocrinology" },
      { value: "Urology", text: "Urology" },
      { value: "Nephrology", text: "Nephrology" },
      { value: "Gastroenterology", text: "Gastroenterology" },
      { value: "Hematology", text: "Hematology" },
      { value: "Ophthalmology", text: "Ophthalmology" },
      { value: "Rheumatology", text: "Rheumatology" },
      { value: "Otolaryngology", text: "Otolaryngology" },
      { value: "Plastic Surgery", text: "Plastic Surgery" },
      { value: "Pulmonology", text: "Pulmonology" },
      { value: "Infectious Diseases", text: "Infectious Diseases" },
    ]);

    const shiftTimeOptions = ref([
      { value: "Morning", text: "Morning" },
      { value: "Afternoon", text: "Afternoon" },
      { value: "Overnight", text: "Overnight" },
      { value: "Long Day", text: "Long Day" },
      { value: "Long Night", text: "Long Night" },
    ]);

    const reportData = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const chartData = ref({ labels: [], datasets: [] });
    const chartOptions = ref({
      responsive: false,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
        },
        title: {
          display: true,
          text: "Monthly Shift Assignments",
        },
      },
      scales: {
        x: {
          title: {
            display: true,
            text: "Month (YYYY-MM)",
          },
        },
        y: {
          title: {
            display: true,
            text: "Total Shifts",
          },
          beginAtZero: true,
        },
      },
    });

    const columns = [
      { key: "assignment_year", label: "Year" },
      { key: "assignment_month", label: "Month" },
      { key: "assignment_month_year", label: "Month (YYYY-MM)" },
      { key: "total_shifts", label: "Total Shifts" },
    ];

    const fetchReport = async () => {
      loading.value = true;
      error.value = null;
      reportData.value = [];
      chartData.value = { labels: [], datasets: [] };

      const startDate = startMonth.value ? `${startMonth.value}-01` : "";
      let endDate = "";
      if (endMonth.value) {
        const [year, month] = endMonth.value.split("-").map(Number);
        const lastDay = new Date(year, month, 0).getDate();
        endDate = `${endMonth.value}-${lastDay}`;
      }

      const filters = {};
      if (role.value) filters.role = role.value;
      if (department.value) filters.department = department.value;
      if (shiftType.value) filters.shift_type = shiftType.value;
      if (shiftTime.value) filters.shift_time = shiftTime.value;

      if (!startMonth.value || !endMonth.value) {
        error.value = "Please provide a start and end month.";
        loading.value = false;
        return;
      }

      try {
        const data = await fetchMonthlyShiftAssignmentsReport(
          startDate,
          endDate,
          filters,
        );
        if (Array.isArray(data)) {
          reportData.value = data;
          const labels = data.map((item) => item.assignment_month_year);
          const shiftsData = data.map((item) => item.total_shifts);

          chartData.value = {
            labels: labels,
            datasets: [
              {
                label: "Total Shifts",
                backgroundColor: "#42A5F5",
                data: shiftsData,
              },
            ],
          };
        } else {
          console.warn(
            "Backend returned data for Monthly Shift Assignments that is not an array:",
            data,
          );
          reportData.value = [];
          chartData.value = { labels: [], datasets: [] };
        }
      } catch (err) {
        error.value =
          "Failed to fetch monthly shift assignments report: " + err.message;
        console.error(err);
        reportData.value = [];
        chartData.value = { labels: [], datasets: [] };
      } finally {
        loading.value = false;
      }
    };

    onMounted(() => {
      const today = new Date();
      const currentYear = today.getFullYear();
      const currentMonth = String(today.getMonth() + 1).padStart(2, "0");

      startMonth.value = `${currentYear}-01`;
      endMonth.value = `${currentYear}-${currentMonth}`;

      fetchReport();
    });

    return {
      startMonth,
      endMonth,
      role,
      department,
      shiftType,
      shiftTime,
      reportData,
      loading,
      error,
      columns,
      fetchReport,
      roleOptions,
      departmentOptions,
      shiftTimeOptions,
      chartData,
      chartOptions,
    };
  },
};
</script>

<style scoped>
.chart-container {
  align-self: center;
  justify-self: center;
}
</style>
