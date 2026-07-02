import { Download, FileSpreadsheet, FileText, PieChart, Users, AlertTriangle } from 'lucide-react';
import '../styles/Pages.css';

const reportCards = [
  { icon: PieChart, title: 'Weekly Collection Summary', description: 'Collection volume and route performance.', csvData: [['Date', 'Collections'], ['2026-06-01', '120']] },
  { icon: Users, title: 'Worker Performance Metrics', description: 'Field productivity and task completion.', csvData: [['Worker', 'Tasks'], ['Ravi', '24']] },
  { icon: AlertTriangle, title: 'Hazard Zone Analysis', description: 'Critical hotspots and response metrics.', csvData: [['Zone', 'Incidents'], ['Zone A', '6']] },
  { icon: FileText, title: 'Monthly Environmental Impact', description: 'Waste reduction and sustainability summary.', csvData: [['Month', 'Impact'], ['June', 'High']] }
];

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

const Reports = () => {
  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Reports & Analytics</h2>
          <p className="header-subtitle">Download operational and compliance reports.</p>
        </div>
      </div>
      <div className="reports-grid">
        {reportCards.map(({ icon: Icon, title, description, csvData }) => (
          <div key={title} className="panel-card report-card">
            <div className="report-card-top">
              <div className="report-icon"><Icon size={20} /></div>
              <div>
                <h3>{title}</h3>
                <p>{description}</p>
              </div>
            </div>
            <div className="report-actions">
              <button className="secondary-btn" onClick={() => window.alert('PDF will be available once backend endpoint is connected.')}> <Download size={16} /> PDF</button>
              <button className="primary-btn" onClick={() => downloadCsv(csvData, title)}><FileSpreadsheet size={16} /> CSV</button>
            </div>
          </div>
        ))}
      </div>
      <div className="panel-card">
        <h3>Recent Automated Exports</h3>
        <table className="data-table">
          <thead>
            <tr>
              <th>Export Name</th>
              <th>Type</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Zone 1 Monthly Audit</td>
              <td>PDF</td>
              <td>Completed</td>
            </tr>
            <tr>
              <td>Worker Timesheets Q2</td>
              <td>CSV</td>
              <td>Completed</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Reports;
