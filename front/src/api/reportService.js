const API_BASE_URL = 'http://localhost:8080/reports'; // Your backend URL


export const fetchMonthlyShiftAssignmentsReport = async (startDate, endDate, filters = {}) => {
  const params = new URLSearchParams({
    start_date: startDate,
    end_date: endDate,
    ...filters,
  });
  const response = await fetch(`${API_BASE_URL}/monthly-shifts?${params.toString()}`); // Assuming endpoint is /reports/monthly-shifts

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Error fetching monthly shift assignments report: ${response.status} ${response.statusText} - ${errorBody}`);
  }
  return response.json();
};
export const fetchLeaveAnalysisReport = async (startDate, endDate, filters = {}) => {
  const params = new URLSearchParams({
    start_date: startDate,
    end_date: endDate,
    ...filters,
  });
  const response = await fetch(`${API_BASE_URL}/leave-analysis?${params.toString()}`);
  if (!response.ok) {
    throw new Error(`Error fetching leave analysis report: ${response.statusText}`);
  }
  return response.json();
};

export const fetchStaffWorkloadReport = async (startDate, endDate, filters = {}) => {
  const params = new URLSearchParams({
    start_date: startDate,
    end_date: endDate,
    ...filters,
  });
  const response = await fetch(`${API_BASE_URL}/oncall-analysis?${params.toString()}`);
  if (!response.ok) {
    throw new Error(`Error fetching staff workload report: ${response.statusText}`);
  }
  return response.json();
};

export const fetchOvertimeReport = async (startDate, endDate, filters = {}) => {
  const params = new URLSearchParams({
    start_date: startDate,
    end_date: endDate,
    ...filters,
  });
  const response = await fetch(`${API_BASE_URL}/overtime?${params.toString()}`);
  if (!response.ok) {
    throw new Error(`Error fetching overtime report: ${response.statusText}`);
  }
  return response.json();
};

export const fetchStaffPreferenceReport = async (startDate, endDate, filters = {}) => {
  const params = new URLSearchParams({
    start_date: startDate,
    end_date: endDate,
    ...filters,
  });
  const response = await fetch(`${API_BASE_URL}/shift-preference?${params.toString()}`);
  if (!response.ok) {
    throw new Error(`Error fetching staff preference report: ${response.statusText}`);
  }
  return response.json();
};

export const fetchHoursWorkedReport = async (startDate, endDate, filters = {}) => {
  const params = new URLSearchParams({
    start_date: startDate,
    end_date: endDate,
    ...filters,
  });
  const response = await fetch(`${API_BASE_URL}/work-hours?${params.toString()}`);
  if (!response.ok) {
    throw new Error(`Error fetching hours worked report: ${response.statusText}`);
  }
  return response.json();
};
