<!-- components/ReportTable.vue -->
<template>
  <!-- **Add the wrapper div here for vertical scrolling** -->
  <div class="report-table-scroll-wrapper-vertical">
    <table>
      <thead>
        <tr>
          <th v-for="column in columns" :key="column.key">
            {{ column.label }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(row, rowIndex) in data" :key="rowIndex">
          <td v-for="column in columns" :key="column.key">
            {{ getCellValue(row, column.key) }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
  <!-- **End of wrapper div** -->
</template>

<script>
export default {
  props: {
    columns: {
      type: Array, // Array of { key: string, label: string, formatter: Function }
      required: true,
    },
    data: {
      type: Array,
      required: true,
    },
  },
  methods: {
    getCellValue(row, key) {
      const column = this.columns.find((col) => col.key === key);
      if (column && column.formatter) {
        return column.formatter(row[key], row); // Use formatter if available
      }
      return row[key]; // Otherwise, just return the value
    },
  },
};
</script>

<style scoped>
/* **Apply max-height and overflow-y: auto; to the wrapper div for vertical scrolling** */
.report-table-scroll-wrapper-vertical {
  width: 100%; /* Ensure it takes the full width of its container */
  max-height: 400px; /* **Set a maximum height for the scrollable area** - Adjust this value as needed */
  overflow-y: auto; /* **THIS IS THE KEY PROPERTY FOR VERTICAL SCROLLING** */
  -webkit-overflow-scrolling: touch; /* Smooth scrolling on iOS */
  border: 1px solid #ddd; /* Optional: Add a border around the scrollable area */
  margin-top: 20px; /* Optional: Add some spacing above the scrollable area */
}

/* Basic table styling */
table {
  /* Do NOT set a height on the table itself if you want the wrapper to control scrolling */
  /* Remove margin-top if you added it to the wrapper */
  width: 100%; /* Table should take 100% of the wrapper's width */
  border-collapse: collapse;
  /* Remove any overflow styles from the table */
}

/* Existing th and td styles */
th,
td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
}
th {
  background-color: #f2f2f2;
}
</style>
