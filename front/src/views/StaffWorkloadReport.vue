<template>
  <div class="report-container">
    <h2 class="report-title">Staff Workload and On-Call Analysis</h2>

    <div class="filters-section">
      <div class="filter-group">
        <label for="startDate" class="filter-label">Start Date:</label>
        <input
          type="date"
          id="startDate"
          v-model="startDate"
          class="filter-input"
        />
      </div>

      <div class="filter-group">
        <label for="endDate" class="filter-label">End Date:</label>
        <input
          type="date"
          id="endDate"
          v-model="endDate"
          class="filter-input"
        />
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
        <label for="minTotalShifts" class="filter-label"
          >Min Total Shifts:</label
        >
        <input
          type="number"
          id="minTotalShifts"
          v-model.number="minTotalShifts"
          class="filter-input"
        />
      </div>

      <div class="filter-group">
        <label for="maxTotalShifts" class="filter-label"
          >Max Total Shifts:</label
        >
        <input
          type="number"
          id="maxTotalShifts"
          v-model.number="maxTotalShifts"
          class="filter-input"
        />
      </div>

      <div class="filter-group">
        <label for="minOnCallShifts" class="filter-label"
          >Min On-Call Shifts:</label
        >
        <input
          type="number"
          id="minOnCallShifts"
          v-model.number="minOnCallShifts"
          class="filter-input"
        />
      </div>

      <div class="filter-group">
        <label for="maxOnCallShifts" class="filter-label"
          >Max On-Call Shifts:</label
        >
        <input
          type="number"
          id="maxOnCallShifts"
          v-model.number="maxOnCallShifts"
          class="filter-input"
        />
      </div>

      <button @click="fetchReport" class="generate-button">
        Generate Report
      </button>
    </div>

    <div v-if="reportData.length > 0" class="export-buttons">
      <button @click="handleExportCsv" class="export-button csv-button">
        Export to CSV
      </button>
      <button @click="handleExportPdf" class="export-button pdf-button">
        Export to PDF
      </button>
    </div>

    <div v-if="loading" class="status-message">Loading...</div>
    <div v-if="error" class="status-message error-message">{{ error }}</div>

    <ReportTable
      v-if="reportData.length > 0"
      :columns="columns"
      :data="reportData"
      class="report-table"
    />

    <div v-else-if="!loading && !error" class="status-message">
      No data found for the selected criteria.
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import { fetchStaffWorkloadReport } from "../api/reportService";
import ReportTable from "../components/ReportTable.vue";
import { exportTableToPdf, exportToCsv } from "../utils/exportUtils";

export default {
  name: "StaffWorkloadReportView",
  components: {
    ReportTable,
  },
  setup() {
    const startDate = ref("");
    const endDate = ref("");
    const department = ref("");
    const minTotalShifts = ref(null);
    const maxTotalShifts = ref(null);
    const minOnCallShifts = ref(null);
    const maxOnCallShifts = ref(null);

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

    const reportData = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const columns = [
      { key: "staff_name", label: "Staff Name" },
      { key: "role_name", label: "Role" },
      { key: "departments", label: "Departments" },
      { key: "total_shifts_assigned", label: "Total Shifts" },
      { key: "on_call_shifts_assigned", label: "On-Call Shifts" },
      {
        key: "on_call_percentage",
        label: "On-Call %",
        formatter: (value) => (value !== null ? value.toFixed(2) + "%" : "N/A"),
      },
    ];

    const fetchReport = async () => {
      loading.value = true;
      error.value = null;
      reportData.value = [];

      const filters = {};
      if (department.value) filters.department = department.value;

      if (minTotalShifts.value !== null && minTotalShifts.value !== "")
        filters.min_total_shifts = minTotalShifts.value;
      if (maxTotalShifts.value !== null && maxTotalShifts.value !== "")
        filters.max_total_shifts = maxTotalShifts.value;
      if (minOnCallShifts.value !== null && minOnCallShifts.value !== "")
        filters.min_on_call_shifts = minOnCallShifts.value;
      if (maxOnCallShifts.value !== null && maxOnCallShifts.value !== "")
        filters.max_on_call_shifts = maxOnCallShifts.value;

      if (!startDate.value || !endDate.value) {
        error.value = "Please provide a start and end date.";
        loading.value = false;
        return;
      }

      try {
        const data = await fetchStaffWorkloadReport(
          startDate.value,
          endDate.value,
          filters,
        );
        reportData.value = data;
      } catch (err) {
        error.value = "Failed to fetch staff workload report: " + err.message;
        console.error(err);
      } finally {
        loading.value = false;
      }
    };

    onMounted(() => {
      const today = new Date();
      const firstDayOfYear = new Date(today.getFullYear(), 0, 1);
      const lastDayOfYear = new Date(today.getFullYear(), 11, 31);

      startDate.value = firstDayOfYear.toISOString().split("T")[0];
      endDate.value = lastDayOfYear.toISOString().split("T")[0];

      fetchReport();
    });

    const handleExportPdf = () => {
      if (reportData.value.length === 0) {
        alert("No data to export to PDF.");
        return;
      }
      exportTableToPdf(
        columns,
        reportData.value,
        "staff_workload_report.pdf",
        "Staff Workload and On-Call Analysis",
      );
    };

    const handleExportCsv = () => {
      if (reportData.value.length === 0) {
        alert("No data to export to CSV.");
        return;
      }
      exportToCsv(columns, reportData.value, "workload_report.csv");
    };

    return {
      startDate,
      endDate,
      department,
      minTotalShifts,
      maxTotalShifts,
      minOnCallShifts,
      maxOnCallShifts,
      reportData,
      loading,
      error,
      columns,
      fetchReport,
      handleExportPdf,
      handleExportCsv,
      departmentOptions,
    };
  },
};
</script>

<style scoped></style>
