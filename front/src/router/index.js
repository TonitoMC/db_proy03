import { createRouter, createWebHistory } from 'vue-router';
import HoursWorkedReport from '../views/HoursWorkedReport.vue';
import OvertimeReport from '../views/OvertimeReport.vue'
import StaffWorkloadReport from '../views/StaffWorkloadReport.vue';
import StaffPreferenceReport from '../views/StaffPreferenceReport.vue';
import LeaveAnalysisReport from '../views/LeaveAnalysisReport.vue';
import WorkByMonth from '../views/WorkByMonth.vue'
const routes = [
  {
    path: '/',
    redirect: '/reports/work-hours'
  },
  {
    path: '/reports/work-hours',
    name: 'WorkHoursReport',
    component: HoursWorkedReport
  },
  {
    path: '/reports/overtime',
    name: 'OvertimeReport',
    component: OvertimeReport
  },
  {
    path: '/reports/workload',
    name: 'WorkloadReport',
    component: StaffWorkloadReport
  },
  {
    path: '/reports/staff-preference',
    name: 'StaffPreferenceReport',
    component: StaffPreferenceReport
  },
  {
    path: '/reports/leave',
    name: 'StaffLeaveReport',
    component: LeaveAnalysisReport
  },
  {
    path: '/reports/monthly-shifts',
    name: 'MonthlyShiftAssignmentsReport',
    component: WorkByMonth
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
