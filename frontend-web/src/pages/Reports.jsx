import { useState } from 'react';
import { Download, FileSpreadsheet, FileText, PieChart, Users, AlertTriangle } from 'lucide-react';
import api from '../services/axiosConfig';
import '../styles/Pages.css';

const downloadCsv = (csvData, title) => {
  const csvContent = csvData.map((row) => row.join(',')).join('\n');
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${title.toLowerCase().replace(/\s+/g, '-')}.csv`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

const fetchWorkerPerformanceCsv = async () => {
  const response = await api.get('/workers/report/performance');
  const workers = response.data.data || [];
  const header = ['Worker Name', 'Zone', 'Status', 'Complaints Completed', 'Average Rating', 'Joined Date'];
  const rows = workers.map((w) => [w.name, w.zone || '—', w.status, w.complaints_completed, w.average_rating, w.joined_date]);
  return [header, ...rows];
};

const fetchWeeklyCollectionCsv = async () => {
  const response = await api.get('/admin/stats/weekly');
  const days = response.data.data || [];
  const header = ['Day', 'Complaints', 'Resolved', 'Pending'];
  const rows = days.map((d) => [d.day, d.Complaints, d.Resolved, d.Pending]);
  return [header, ...rows];
};

const fetchHazardZoneCsv = async () => {
  const response = await api.get('/admin/stats/by-zone');
  const zones = response.data.data || [];
  const header = ['Zone / Category', 'Complaint Count'];
  const rows = zones.map((z) => [z.zone, z.value]);
  return [header, ...rows];
};

const fetchMonthlyImpactCsv = async () => {
  const response = await api.get('/admin/stats/monthly');
  const months = response.data.data || [];
  const header = ['Month', 'Complaints', 'Resolved'];
  const rows = months.map((m) => [m.month, m.complaints, m.resolved]);
  return [header, ...rows];
};

const reportConfigs = [
  { icon: Users, title: 'Worker Performance Metrics', description: 'Field productivity and task completion.', fetchCsv: fetchWorkerPerformanceCsv },
  { icon: PieChart, title: 'Weekly Collection Summary', description: 'Collection volume and route performance.', fetchCsv: fetchWeeklyCollectionCsv },
  { icon: AlertTriangle, title: 'Hazard Zone Analysis', description: 'Critical hotspots and response metrics.', fetchCsv: fetchHazardZoneCsv },
  { icon: FileText, title: 'Monthly Environmental Impact', description: 'Waste reduction and sustainability summary.', fetchCsv: fetchMonthlyImpactCsv },
];

const Reports = () => {
  const [loadingTitle, setLoadingTitle] = useState(null);
  // Live session log — resets on page refresh (no backend storage needed
  // for this small, purely cosmetic "recent exports" feed).
  const [recentExports, setRecentExports] = useState([]);

  const handleDownload = async (config) => {
    setLoadingTitle(config.title);
    try {
      const csvData = await config.fetchCsv();
      downloadCsv(csvData, config.title);
      setRecentExports((prev) => [
        { name: config.title, type: 'CSV', status: 'Completed', time: new Date().toLocaleTimeString() },
        ...prev,
      ].slice(0, 10)); // keep only the 10 most recent
    } catch (err) {
      setRecentExports((prev) => [
        { name: config.title, type: 'CSV', status: 'Failed', time: new Date().toLocaleTimeString() },
        ...prev,
      ].slice(0, 10));
      window.alert(`Failed to fetch ${config.title} data. Please try again.`);
    } finally {
      setLoadingTitle(null);
    }
  };

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Reports & Analytics</h2>
          <p className="header-subtitle">Download operational and compliance reports.</p>
        </div>
      </div>
      <div className="reports-grid">
        {reportConfigs.map((config) => {
          const Icon = config.icon;
          const isLoading = loadingTitle === config.title;
          return (
            <div key={config.title} className="panel-card report-card">
              <div className="report-card-top">
                <div className="report-icon"><Icon size={20} /></div>
                <div>
                  <h3>{config.title}</h3>
                  <p>{config.description}</p>
                </div>
              </div>
              <div className="report-actions">
                <button className="secondary-btn" onClick={() => window.alert('PDF will be available once backend endpoint is connected.')}> <Download size={16} /> PDF</button>
                <button className="primary-btn" onClick={() => handleDownload(config)} disabled={isLoading}>
                  <FileSpreadsheet size={16} /> {isLoading ? 'Loading...' : 'CSV'}
                </button>
              </div>
            </div>
          );
        })}
      </div>
      <div className="panel-card">
        <h3>Recent Automated Exports</h3>
        {recentExports.length === 0 ? (
          <div className="empty-state">No exports yet this session. Download a report above to see it here.</div>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Export Name</th>
                <th>Type</th>
                <th>Status</th>
                <th>Time</th>
              </tr>
            </thead>
            <tbody>
              {recentExports.map((exp, idx) => (
                <tr key={idx}>
                  <td>{exp.name}</td>
                  <td>{exp.type}</td>
                  <td>{exp.status}</td>
                  <td>{exp.time}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default Reports;