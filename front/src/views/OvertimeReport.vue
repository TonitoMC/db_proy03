<!-- views/OvertimeReportView.vue -->
<template>
  <div class="report-container">
    <h2 class="report-title">Overtime Report</h2>

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
        <label for="minOvertime" class="filter-label"
          >Min Overtime Hours:</label
        >
        <input
          type="number"
          id="minOvertime"
          v-model.number="minOvertime"
          class="filter-input"
        />
      </div>

      <div class="filter-group">
        <label for="maxOvertime" class="filter-label"
          >Max Overtime Hours:</label
        >
        <input
          type="number"
          id="maxOvertime"
          v-model.number="maxOvertime"
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
import { fetchOvertimeReport } from "../api/reportService";
import ReportTable from "../components/ReportTable.vue";
import { exportToCsv, exportTableToPdf } from "../utils/exportUtils";

export default {
  name: "OvertimeReportView",
  components: {
    ReportTable,
  },
  setup() {
    const startDate = ref("");
    const endDate = ref("");
    const role = ref("");
    const department = ref("");
    const minOvertime = ref(null);
    const maxOvertime = ref(null);

    const roleOptions = ref([
      { value: "Nurse", text: "Nurse" },
      { value: "Doctor", text: "Doctor" },
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

    const reportData = ref([]);
    const loading = ref(false);
    const error = ref(null);

    const columns = [
      { key: "staff_name", label: "Staff Name" },
      { key: "role_name", label: "Role" },
      { key: "department_name", label: "Department" },
      {
        key: "total_overtime",
        label: "Total Overtime Hours",
        formatter: (value) => (value !== null ? value.toFixed(2) : "N/A"),
      },
    ];

    const fetchReport = async () => {
      loading.value = true;
      error.value = null;
      reportData.value = [];

      const filters = {};
      if (role.value) filters.role = role.value;
      if (department.value) filters.department = department.value;
      if (minOvertime.value !== null && minOvertime.value !== "")
        filters.min_overtime_hours = minOvertime.value;
      if (maxOvertime.value !== null && maxOvertime.value !== "")
        filters.max_overtime_hours = maxOvertime.value;

      if (!startDate.value || !endDate.value) {
        error.value = "Please provide a start and end date.";
        loading.value = false;
        return;
      }

      try {
        const data = await fetchOvertimeReport(
          startDate.value,
          endDate.value,
          filters,
        );
        reportData.value = data;
      } catch (err) {
        error.value = "Failed to fetch overtime report: " + err.message;
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
        "overtime_report.pdf",
        "Overtime Report",
      );
    };

    const handleExportCsv = () => {
      if (reportData.value.length === 0) {
        alert("No data to export to CSV.");
        return;
      }
      exportToCsv(columns, reportData.value, "overtime_report.csv");
    };

    return {
      startDate,
      endDate,
      role,
      department,
      minOvertime,
      maxOvertime,
      reportData,
      loading,
      error,
      columns,
      fetchReport,
      handleExportPdf,
      handleExportCsv,
      roleOptions,
      departmentOptions,
    };
  },
};
</script>

<style scoped></style>
